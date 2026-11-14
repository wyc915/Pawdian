import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/server/web_push.dart';

void main() {
  test('encrypts exactly like the RFC 8291 example', () {
    // RFC 8291, Appendix A.
    final asKeys = P256KeyPair.fromPrivate(
      b64urlDecode('yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw'),
    );
    expect(
      b64url(asKeys.publicKey),
      'BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8',
    );
    final body = encryptPayload(
      payload: utf8.encode('When I grow up, I want to be a watermelon'),
      uaPublic: b64urlDecode(
        'BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4',
      ),
      authSecret: b64urlDecode('BTBZMqHH6r4Tts7J_aSIgg'),
      asKeys: asKeys,
      salt: b64urlDecode('DGv6ra1nlYgDCS1FRnbzlw'),
    );
    expect(
      b64url(body),
      'DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN',
    );
  });

  test('round-trips a Chinese payload with random keys', () {
    final ua = P256KeyPair.generate();
    final auth = b64urlDecode('BTBZMqHH6r4Tts7J_aSIgg');
    final message = utf8.encode(jsonEncode({'title': '麻糬：用藥', 'body': '時間到了'}));
    final body = encryptPayload(
      payload: message,
      uaPublic: ua.publicKey,
      authSecret: auth,
    );
    expect(decryptPayload(body: body, ua: ua, authSecret: auth), message);
  });

  test('VAPID header carries a valid ES256 JWT for the push origin', () {
    final vapid = P256KeyPair.generate();
    final header = vapidAuthorization(
      endpoint: 'https://web.push.apple.com/QGuQyavXutnMH6dJ9Q',
      vapid: vapid,
      subject: 'mailto:noreply@pawdian.app',
      now: DateTime.utc(2026, 11, 14),
    );
    final m = RegExp(r'^vapid t=([^,]+), k=(.+)$').firstMatch(header)!;
    final jwt = m.group(1)!;
    expect(m.group(2), b64url(vapid.publicKey));
    expect(verifyVapidJwt(jwt, vapid.publicKey), isTrue);
    final claims = jsonDecode(utf8.decode(b64urlDecode(jwt.split('.')[1])));
    expect(claims['aud'], 'https://web.push.apple.com');
    expect(claims['sub'], 'mailto:noreply@pawdian.app');
    expect(verifyVapidJwt(jwt, P256KeyPair.generate().publicKey), isFalse);
  });
}
