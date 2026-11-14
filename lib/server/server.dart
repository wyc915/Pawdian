// Pawdian home server (pure Dart, no Flutter imports).
//
// - Serves the Flutter web build.
// - /api/db: the app's SQLite database over a WebSocket (drift remote
//   protocol), so the web app runs the same queries as the phone app while
//   the data stays in one file on this PC.
// - /api/files: pet photos and record attachments.
// - /api/push: Web Push subscriptions and the reminder schedule.
//
// Every /api request needs the passcode (header X-Pawdian-Token, or
// ?token= for WebSockets and images). The server listens on 127.0.0.1 only;
// `tailscale serve` is the way in from the phone.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
// The remote protocol is marked experimental; it is pinned by pubspec.lock
// and covered by test/web_server_test.dart.
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:stream_channel/stream_channel.dart';

import 'push_service.dart';

const kServerVersion = 1;
const kDatabaseFile = 'pawdian.sqlite';
const kFileDirs = {'pet_photos', 'attachments'};
const kMaxUpload = 20 * 1024 * 1024;
const kKeepSnapshots = 30;

final _safeName = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,200}$');

const _types = {
  'html': 'text/html; charset=utf-8',
  'js': 'text/javascript; charset=utf-8',
  'mjs': 'text/javascript; charset=utf-8',
  'json': 'application/json',
  'css': 'text/css; charset=utf-8',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
  'gif': 'image/gif',
  'heic': 'image/heic',
  'svg': 'image/svg+xml',
  'ico': 'image/x-icon',
  'wasm': 'application/wasm',
  'otf': 'font/otf',
  'ttf': 'font/ttf',
  'woff2': 'font/woff2',
  'txt': 'text/plain; charset=utf-8',
};

/// Files that must always be re-checked so an update reaches the phone.
const _noCache = {
  'index.html',
  'flutter_bootstrap.js',
  'push_sw.js',
  'manifest.json',
  'version.json',
};

class PawdianServer {
  PawdianServer({
    required this.dataDir,
    required this.webDir,
    this.host = '127.0.0.1',
    this.port = 8790,
    this.contact = 'mailto:noreply@pawdian.app',
    this.log = print,
  });

  final Directory dataDir;
  final Directory webDir;
  final String host;
  final int port;
  final String contact;
  final void Function(String) log;

  late final String passcode;
  late final DriftServer _db;
  late final PushService push;
  HttpServer? _http;
  Timer? _snapshotTimer;
  final _failures = <DateTime>[];

  File get databaseFile => File('${dataDir.path}/$kDatabaseFile');
  int get boundPort => _http!.port;

  Future<void> start() async {
    dataDir.createSync(recursive: true);
    for (final d in kFileDirs) {
      Directory('${dataDir.path}/$d').createSync(recursive: true);
    }
    passcode = _loadPasscode();
    _db = DriftServer(
      NativeDatabase(
        databaseFile,
        setup: (db) {
          db.execute('PRAGMA busy_timeout = 5000');
          db.execute('PRAGMA journal_mode = WAL');
        },
      ),
    );
    push = PushService(Directory('${dataDir.path}/push'), subject: contact, log: log);
    push.start();
    snapshot();
    _snapshotTimer = Timer.periodic(const Duration(hours: 1), (_) => snapshot());
    _http = await HttpServer.bind(host, port);
    _http!.listen((req) async {
      try {
        await _handle(req);
      } catch (e) {
        log('Request failed: ${req.method} ${req.uri.path}: $e');
        try {
          req.response.statusCode = HttpStatus.internalServerError;
          await req.response.close();
        } catch (_) {}
      }
    });
  }

  Future<void> stop() async {
    _snapshotTimer?.cancel();
    push.stop();
    await _http?.close(force: true);
    await _db.shutdown();
  }

  String _loadPasscode() {
    final f = File('${dataDir.path}/passcode.txt');
    if (f.existsSync()) {
      final v = f.readAsStringSync().trim();
      if (v.length >= 8) return v;
    }
    // 8 easy-to-type characters, e.g. "k7m2p9xq" (no 0/o/1/l).
    const chars = 'abcdefghijkmnpqrstuvwxyz23456789';
    final r = Random.secure();
    final v = List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
    f.writeAsStringSync(v);
    return v;
  }

  /// Copies the database to snapshots/pawdian-YYYYMMDD.sqlite once a day and
  /// keeps the newest [kKeepSnapshots].
  void snapshot({DateTime? now}) {
    if (!databaseFile.existsSync()) return;
    final t = now ?? DateTime.now();
    final dir = Directory('${dataDir.path}/snapshots')..createSync();
    String two(int v) => v.toString().padLeft(2, '0');
    final target = File(
      '${dir.path}/pawdian-${t.year}${two(t.month)}${two(t.day)}.sqlite',
    );
    if (target.existsSync()) return;
    try {
      final db = sqlite3.open(databaseFile.path);
      try {
        db.execute('PRAGMA busy_timeout = 5000');
        db.execute('VACUUM INTO ?', [target.path]);
      } finally {
        db.close();
      }
      final all = dir.listSync().whereType<File>().toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      for (final old in all.skip(kKeepSnapshots)) {
        old.deleteSync();
      }
      log('Snapshot saved: ${target.path}');
    } catch (e) {
      log('Snapshot failed: $e');
    }
  }

  bool _authorized(HttpRequest req) {
    final given =
        req.headers.value('x-pawdian-token') ?? req.uri.queryParameters['token'];
    if (given != null && _equals(given, passcode)) return true;
    final now = DateTime.now();
    _failures
      ..removeWhere((t) => now.difference(t) > const Duration(minutes: 1))
      ..add(now);
    return false;
  }

  static bool _equals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path;
    final res = req.response;
    res.headers
      ..set('X-Content-Type-Options', 'nosniff')
      ..set('Referrer-Policy', 'no-referrer');
    if (!path.startsWith('/api/')) return _static(req);

    if (_failures.length >= 10) {
      res.statusCode = HttpStatus.tooManyRequests;
      return res.close();
    }
    if (!_authorized(req)) {
      res.statusCode = HttpStatus.unauthorized;
      return res.close();
    }
    res.headers.set('Cache-Control', 'no-store');

    final parts = path.substring(5).split('/');
    switch ((req.method, parts)) {
      case ('GET', ['ping']):
        return _json(res, {'ok': true, 'version': kServerVersion});
      case ('GET', ['db']):
        if (!WebSocketTransformer.isUpgradeRequest(req)) {
          res.statusCode = HttpStatus.badRequest;
          return res.close();
        }
        final ws = await WebSocketTransformer.upgrade(req);
        final channel = StreamChannel<dynamic>(
          ws,
          ws,
        ).cast<String>().transform(jsonDocument);
        unawaited(_db.serve(channel, serialize: true));
        return;
      case (final m, ['files', final dir, final name])
          when kFileDirs.contains(dir) && _safeName.hasMatch(name):
        return _file(req, File('${dataDir.path}/$dir/$name'), m);
      case ('GET', ['push', 'key']):
        return _json(res, {'key': push.publicKey});
      case ('POST', ['push', 'subscribe']):
        final body = await _readJson(req) as Map<String, dynamic>;
        push.subscribe(PushSubscription.fromJson(body));
        return _json(res, {'ok': true});
      case ('POST', ['push', 'unsubscribe']):
        final body = await _readJson(req) as Map<String, dynamic>;
        push.unsubscribe(body['endpoint'] as String);
        return _json(res, {'ok': true});
      case ('PUT', ['push', 'schedule']):
        final body = await _readJson(req) as Map<String, dynamic>;
        push.replaceSchedule([
          for (final i in (body['items'] as List).cast<Map<String, dynamic>>())
            PushItem.fromJson(i),
        ]);
        return _json(res, {'ok': true, 'count': push.items.length});
      case ('POST', ['push', 'test']):
        final body = await _readJson(req) as Map<String, dynamic>;
        final sent = await push.sendToAll({
          'title': body['title'] ?? 'Pawdian',
          'body': body['body'] ?? '',
          'tag': 'test',
          'url': '/',
        });
        return _json(res, {'sent': sent, 'devices': push.subscriptions.length});
      default:
        res.statusCode = HttpStatus.notFound;
        return res.close();
    }
  }

  Future<void> _file(HttpRequest req, File file, String method) async {
    final res = req.response;
    switch (method) {
      case 'GET':
        if (!file.existsSync()) {
          res.statusCode = HttpStatus.notFound;
          return res.close();
        }
        res.headers
          ..contentType = _contentType(file.path)
          ..set('Cache-Control', 'private, max-age=31536000, immutable');
        await res.addStream(file.openRead());
        return res.close();
      case 'PUT':
        final bytes = await _readBytes(req, kMaxUpload);
        if (bytes == null) {
          res.statusCode = HttpStatus.requestEntityTooLarge;
          return res.close();
        }
        final tmp = File('${file.path}.part');
        await tmp.writeAsBytes(bytes, flush: true);
        await tmp.rename(file.path);
        return _json(res, {'ok': true});
      case 'DELETE':
        if (file.existsSync()) await file.delete();
        return _json(res, {'ok': true});
      default:
        res.statusCode = HttpStatus.methodNotAllowed;
        return res.close();
    }
  }

  Future<void> _static(HttpRequest req) async {
    final res = req.response;
    if (req.method != 'GET' && req.method != 'HEAD') {
      res.statusCode = HttpStatus.methodNotAllowed;
      return res.close();
    }
    var rel = Uri.decodeComponent(req.uri.path).replaceFirst(RegExp(r'^/+'), '');
    if (rel.isEmpty || rel.split('/').any((s) => s == '..' || s.startsWith('.'))) {
      rel = 'index.html';
    }
    var file = File('${webDir.path}/$rel');
    if (!file.existsSync()) {
      // Single-page app: unknown paths load the app.
      rel = 'index.html';
      file = File('${webDir.path}/index.html');
    }
    if (!file.existsSync()) {
      res.statusCode = HttpStatus.notFound;
      res.write('Web build not found. Run: flutter build web');
      return res.close();
    }
    res.headers.contentType = _contentType(file.path);
    final name = rel.split('/').last;
    // Always revalidate (cheap 304s) so a new build reaches the phone right
    // after `flutter build web`; only CanvasKit, which never changes within
    // a Flutter version, is cached for long.
    res.headers.set(
      'Cache-Control',
      rel.startsWith('canvaskit/') && !_noCache.contains(name)
          ? 'public, max-age=86400'
          : 'no-cache',
    );
    if (name == 'push_sw.js') res.headers.set('Service-Worker-Allowed', '/');
    final modified = file.lastModifiedSync().toUtc();
    res.headers.set(HttpHeaders.lastModifiedHeader, HttpDate.format(modified));
    final since = req.headers.ifModifiedSince;
    if (since != null &&
        !modified.isAfter(since.add(const Duration(seconds: 1)))) {
      res.statusCode = HttpStatus.notModified;
      return res.close();
    }
    if (req.method == 'HEAD') return res.close();
    await res.addStream(file.openRead());
    return res.close();
  }

  static ContentType _contentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ContentType.parse(_types[ext] ?? 'application/octet-stream');
  }

  static Future<void> _json(HttpResponse res, Object body) {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(body));
    return res.close();
  }

  static Future<List<int>?> _readBytes(HttpRequest req, int max) async {
    final out = BytesBuilder(copy: false);
    await for (final chunk in req) {
      out.add(chunk);
      if (out.length > max) return null;
    }
    return out.takeBytes();
  }

  static Future<Object?> _readJson(HttpRequest req) async {
    final bytes = await _readBytes(req, 2 * 1024 * 1024);
    return jsonDecode(utf8.decode(bytes ?? const []));
  }
}
