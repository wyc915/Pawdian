// Stores push subscriptions and the reminder schedule, and sends Web Push
// messages when reminders are due. Pure Dart (runs in the home server).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'web_push.dart';

/// One planned notification, uploaded by the app.
class PushItem {
  PushItem({
    required this.at,
    required this.title,
    required this.body,
    required this.ruleId,
    this.sent = false,
  });

  factory PushItem.fromJson(Map<String, dynamic> j) => PushItem(
    at: DateTime.fromMillisecondsSinceEpoch((j['at'] as num).toInt(), isUtc: true),
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
    ruleId: j['ruleId'] as String? ?? '',
    sent: j['sent'] == true,
  );

  final DateTime at;
  final String title;
  final String body;
  final String ruleId;
  bool sent;

  String get key => '$ruleId@${at.millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() => {
    'at': at.millisecondsSinceEpoch,
    'title': title,
    'body': body,
    'ruleId': ruleId,
    'sent': sent,
  };
}

class PushSubscription {
  PushSubscription(this.endpoint, this.p256dh, this.auth);

  factory PushSubscription.fromJson(Map<String, dynamic> j) {
    final keys = j['keys'] as Map<String, dynamic>;
    return PushSubscription(
      j['endpoint'] as String,
      keys['p256dh'] as String,
      keys['auth'] as String,
    );
  }

  final String endpoint;
  final String p256dh;
  final String auth;

  Map<String, dynamic> toJson() => {
    'endpoint': endpoint,
    'keys': {'p256dh': p256dh, 'auth': auth},
  };
}

/// How late a missed notification may still be sent (e.g. the server was
/// restarted a few minutes after the reminder time).
const kPushGrace = Duration(minutes: 15);
const kMaxPushItems = 200;

class PushService {
  PushService(
    this.dir, {
    required this.subject,
    http.Client? client,
    this.log = print,
  }) : _client = client ?? http.Client() {
    dir.createSync(recursive: true);
    _loadKeys();
    _subs = _readList(_subsFile).map(PushSubscription.fromJson).toList();
    _items = _readList(_scheduleFile).map(PushItem.fromJson).toList();
  }

  final Directory dir;

  /// VAPID "sub" claim: a contact URL or mailto address for push services.
  final String subject;
  final http.Client _client;
  final void Function(String) log;

  late P256KeyPair vapid;
  late List<PushSubscription> _subs;
  late List<PushItem> _items;
  Timer? _timer;

  File get _keyFile => File('${dir.path}/vapid.json');
  File get _subsFile => File('${dir.path}/subscriptions.json');
  File get _scheduleFile => File('${dir.path}/schedule.json');

  List<PushSubscription> get subscriptions => List.unmodifiable(_subs);
  List<PushItem> get items => List.unmodifiable(_items);
  String get publicKey => b64url(vapid.publicKey);

  void _loadKeys() {
    if (_keyFile.existsSync()) {
      final j = jsonDecode(_keyFile.readAsStringSync()) as Map<String, dynamic>;
      vapid = P256KeyPair.fromPrivate(b64urlDecode(j['privateKey'] as String));
    } else {
      vapid = P256KeyPair.generate();
      _write(_keyFile, {'privateKey': b64url(vapid.privateKey)});
    }
  }

  static List<Map<String, dynamic>> _readList(File f) {
    if (!f.existsSync()) return [];
    try {
      return (jsonDecode(f.readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static void _write(File f, Object json) {
    final tmp = File('${f.path}.tmp');
    tmp.writeAsStringSync(jsonEncode(json), flush: true);
    tmp.renameSync(f.path);
  }

  void subscribe(PushSubscription sub) {
    _subs.removeWhere((s) => s.endpoint == sub.endpoint);
    _subs.add(sub);
    _write(_subsFile, _subs.map((s) => s.toJson()).toList());
  }

  void unsubscribe(String endpoint) {
    _subs.removeWhere((s) => s.endpoint == endpoint);
    _write(_subsFile, _subs.map((s) => s.toJson()).toList());
  }

  /// Replaces the schedule, keeping the "sent" mark of items already sent.
  void replaceSchedule(List<PushItem> next) {
    final sent = {for (final i in _items) if (i.sent) i.key};
    _items = [
      for (final i in next.take(kMaxPushItems))
        i..sent = i.sent || sent.contains(i.key),
    ]..sort((a, b) => a.at.compareTo(b.at));
    _saveSchedule();
  }

  void _saveSchedule() =>
      _write(_scheduleFile, _items.map((i) => i.toJson()).toList());

  void start({Duration every = const Duration(seconds: 20)}) {
    _timer?.cancel();
    _timer = Timer.periodic(every, (_) => tick());
    tick();
  }

  void stop() => _timer?.cancel();

  /// Sends everything that is due. Returns how many items were sent.
  Future<int> tick({DateTime? now}) async {
    final t = (now ?? DateTime.now()).toUtc();
    var sent = 0;
    var changed = false;
    for (final item in _items) {
      if (item.sent || item.at.isAfter(t)) continue;
      item.sent = true;
      changed = true;
      if (t.difference(item.at) > kPushGrace) continue; // too old, skip
      await sendToAll({
        'title': item.title,
        'body': item.body,
        'tag': '${item.ruleId}-${item.at.millisecondsSinceEpoch}',
        'url': '/?rule=${Uri.encodeQueryComponent(item.ruleId)}',
      });
      sent++;
    }
    // Forget items older than a day.
    final before = _items.length;
    _items.removeWhere((i) => t.difference(i.at) > const Duration(days: 1));
    if (changed || before != _items.length) _saveSchedule();
    return sent;
  }

  /// Sends [message] to every subscribed device; drops expired ones.
  Future<int> sendToAll(Map<String, Object?> message) async {
    var ok = 0;
    for (final sub in [..._subs]) {
      try {
        final status = await send(sub, message);
        if (status >= 200 && status < 300) {
          ok++;
        } else if (status == 404 || status == 410) {
          log('Push subscription expired, removing it.');
          unsubscribe(sub.endpoint);
        } else {
          log('Push failed with HTTP $status.');
        }
      } catch (e) {
        log('Push failed: $e');
      }
    }
    return ok;
  }

  Future<int> send(PushSubscription sub, Map<String, Object?> message) async {
    final body = encryptPayload(
      payload: utf8.encode(jsonEncode(message)),
      uaPublic: b64urlDecode(sub.p256dh),
      authSecret: b64urlDecode(sub.auth),
    );
    final res = await _client.post(
      Uri.parse(sub.endpoint),
      headers: {
        'Authorization': vapidAuthorization(
          endpoint: sub.endpoint,
          vapid: vapid,
          subject: subject,
        ),
        'Content-Encoding': 'aes128gcm',
        'Content-Type': 'application/octet-stream',
        'TTL': '86400',
        'Urgency': 'high',
      },
      body: body,
    );
    return res.statusCode;
  }
}
