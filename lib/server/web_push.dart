// Web Push for the home server (pure Dart, no Flutter imports).
//
// - VAPID (RFC 8292): an ES256-signed JWT identifies this server to the
//   browser's push service (Apple, Google, Mozilla).
// - Message encryption (RFC 8291, "aes128gcm"): the payload is encrypted for
//   the subscribing browser, so the push service cannot read it.
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

final _curve = ECCurve_prime256v1();

String b64url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List b64urlDecode(String s) {
  final padded = s.padRight((s.length + 3) ~/ 4 * 4, '=');
  return base64Url.decode(padded.replaceAll('+', '-').replaceAll('/', '_'));
}

SecureRandom _secureRandom() {
  final r = Random.secure();
  return FortunaRandom()
    ..seed(KeyParameter(Uint8List.fromList(
      List.generate(32, (_) => r.nextInt(256)),
    )));
}

Uint8List _bigIntBytes(BigInt v, int length) {
  final out = Uint8List(length);
  var x = v;
  for (var i = length - 1; i >= 0; i--) {
    out[i] = (x & BigInt.from(0xff)).toInt();
    x = x >> 8;
  }
  return out;
}

BigInt _bytesBigInt(List<int> bytes) =>
    bytes.fold(BigInt.zero, (a, b) => (a << 8) | BigInt.from(b));

/// A P-256 key pair stored as raw bytes (private: 32, public: 65 uncompressed).
class P256KeyPair {
  P256KeyPair(this.privateKey, this.publicKey);

  factory P256KeyPair.generate() {
    final gen = ECKeyGenerator()
      ..init(ParametersWithRandom(
        ECKeyGeneratorParameters(_curve),
        _secureRandom(),
      ));
    final pair = gen.generateKeyPair();
    final priv = pair.privateKey;
    final pub = pair.publicKey;
    return P256KeyPair(
      _bigIntBytes(priv.d!, 32),
      pub.Q!.getEncoded(false),
    );
  }

  factory P256KeyPair.fromPrivate(Uint8List privateKey) {
    final d = _bytesBigInt(privateKey);
    final q = (_curve.G * d)!;
    return P256KeyPair(privateKey, q.getEncoded(false));
  }

  final Uint8List privateKey;
  final Uint8List publicKey;

  ECPrivateKey get _priv => ECPrivateKey(_bytesBigInt(privateKey), _curve);
}

ECPublicKey _publicKey(Uint8List raw) =>
    ECPublicKey(_curve.curve.decodePoint(raw), _curve);

Uint8List _hmac(List<int> key, List<int> data) {
  final mac = HMac(SHA256Digest(), 64)..init(KeyParameter(Uint8List.fromList(key)));
  return mac.process(Uint8List.fromList(data));
}

/// Builds the `Authorization: vapid t=..., k=...` header value for [endpoint].
String vapidAuthorization({
  required String endpoint,
  required P256KeyPair vapid,
  required String subject,
  DateTime? now,
}) {
  final uri = Uri.parse(endpoint);
  final audience = '${uri.scheme}://${uri.host}${uri.hasPort && uri.port != 443 ? ':${uri.port}' : ''}';
  final t = now ?? DateTime.now();
  final header = b64url(utf8.encode(jsonEncode({'typ': 'JWT', 'alg': 'ES256'})));
  final claims = b64url(utf8.encode(jsonEncode({
    'aud': audience,
    'exp': t.add(const Duration(hours: 12)).millisecondsSinceEpoch ~/ 1000,
    'sub': subject,
  })));
  final signingInput = '$header.$claims';
  final signer = ECDSASigner(SHA256Digest())
    ..init(true, ParametersWithRandom(
      PrivateKeyParameter<ECPrivateKey>(vapid._priv),
      _secureRandom(),
    ));
  final sig = signer.generateSignature(
    Uint8List.fromList(utf8.encode(signingInput)),
  ) as ECSignature;
  final jws = Uint8List.fromList([
    ..._bigIntBytes(sig.r, 32),
    ..._bigIntBytes(sig.s, 32),
  ]);
  return 'vapid t=$signingInput.${b64url(jws)}, k=${b64url(vapid.publicKey)}';
}

/// Verifies a VAPID JWT signature (used by tests).
bool verifyVapidJwt(String jwt, Uint8List publicKey) {
  final parts = jwt.split('.');
  if (parts.length != 3) return false;
  final sig = b64urlDecode(parts[2]);
  if (sig.length != 64) return false;
  final verifier = ECDSASigner(SHA256Digest())
    ..init(false, PublicKeyParameter<ECPublicKey>(_publicKey(publicKey)));
  return verifier.verifySignature(
    Uint8List.fromList(utf8.encode('${parts[0]}.${parts[1]}')),
    ECSignature(_bytesBigInt(sig.sublist(0, 32)), _bytesBigInt(sig.sublist(32))),
  );
}

/// Encrypts [payload] for a subscription (RFC 8291). [asKeys] and [salt] are
/// random unless given (tests use fixed values from the RFC).
Uint8List encryptPayload({
  required List<int> payload,
  required Uint8List uaPublic,
  required Uint8List authSecret,
  P256KeyPair? asKeys,
  Uint8List? salt,
}) {
  final as = asKeys ?? P256KeyPair.generate();
  final rnd = Random.secure();
  final s = salt ?? Uint8List.fromList(List.generate(16, (_) => rnd.nextInt(256)));

  final agreement = ECDHBasicAgreement()..init(as._priv);
  final ecdhSecret = _bigIntBytes(
    agreement.calculateAgreement(_publicKey(uaPublic)),
    32,
  );

  // IKM = HKDF(auth_secret, ecdh_secret, "WebPush: info" || 0 || ua || as)
  final prkKey = _hmac(authSecret, ecdhSecret);
  final keyInfo = [
    ...utf8.encode('WebPush: info'), 0, ...uaPublic, ...as.publicKey, 1,
  ];
  final ikm = _hmac(prkKey, keyInfo);

  final prk = _hmac(s, ikm);
  final cek = _hmac(prk, [...utf8.encode('Content-Encoding: aes128gcm'), 0, 1])
      .sublist(0, 16);
  final nonce = _hmac(prk, [...utf8.encode('Content-Encoding: nonce'), 0, 1])
      .sublist(0, 12);

  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(cek), 128, nonce, Uint8List(0)));
  // A single record: payload followed by the 0x02 "last record" delimiter.
  final encrypted = cipher.process(Uint8List.fromList([...payload, 2]));

  final header = BytesBuilder()
    ..add(s)
    ..add([0, 0, 0x10, 0]) // record size 4096
    ..addByte(as.publicKey.length)
    ..add(as.publicKey);
  return Uint8List.fromList([...header.toBytes(), ...encrypted]);
}

/// Decrypts an aes128gcm body with the receiver's keys (used by tests).
Uint8List decryptPayload({
  required Uint8List body,
  required P256KeyPair ua,
  required Uint8List authSecret,
}) {
  final salt = body.sublist(0, 16);
  final idLen = body[20];
  final asPublic = body.sublist(21, 21 + idLen);
  final ciphertext = body.sublist(21 + idLen);
  final agreement = ECDHBasicAgreement()..init(ua._priv);
  final ecdhSecret = _bigIntBytes(
    agreement.calculateAgreement(_publicKey(asPublic)),
    32,
  );
  final prkKey = _hmac(authSecret, ecdhSecret);
  final ikm = _hmac(prkKey, [
    ...utf8.encode('WebPush: info'), 0, ...ua.publicKey, ...asPublic, 1,
  ]);
  final prk = _hmac(salt, ikm);
  final cek = _hmac(prk, [...utf8.encode('Content-Encoding: aes128gcm'), 0, 1])
      .sublist(0, 16);
  final nonce = _hmac(prk, [...utf8.encode('Content-Encoding: nonce'), 0, 1])
      .sublist(0, 12);
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(cek), 128, nonce, Uint8List(0)));
  final plain = cipher.process(ciphertext);
  final end = plain.lastIndexWhere((b) => b != 0);
  return plain.sublist(0, end); // drop the 0x02 delimiter
}
