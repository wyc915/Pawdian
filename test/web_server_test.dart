import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/reminders/domain/notification_planner.dart';
import 'package:pawdian/server/push_service.dart';
import 'package:pawdian/server/server.dart';
import 'package:pawdian/server/web_push.dart';
import 'package:pawdian/web/server_api.dart';
import 'package:pawdian/web/web_push.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  late Directory tmp;
  late PawdianServer server;
  late Uri base;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('pawdian_server');
    final web = await Directory('${tmp.path}/web').create();
    await File('${web.path}/index.html').writeAsString('<html>app</html>');
    await File('${web.path}/main.dart.js').writeAsString('// js');
    server = PawdianServer(
      dataDir: Directory('${tmp.path}/data'),
      webDir: web,
      port: 0,
      log: (_) {},
    );
    await server.start();
    base = Uri.parse('http://127.0.0.1:${server.boundPort}/');
  });

  tearDown(() async {
    await server.stop();
    await tmp.delete(recursive: true);
  });

  Future<AppDatabase> connect(ServerApi api) async {
    final socket = WebSocketChannel.connect(api.databaseSocket);
    await socket.ready;
    final connection = await connectToRemoteAndInitialize(
      socket.cast<String>().transform(jsonDocument),
      serialize: true,
    );
    return AppDatabase(connection);
  }

  test('passcode is required for the API, not for the web app', () async {
    expect(server.passcode, hasLength(8));
    expect((await http.get(base.resolve('/api/ping'))).statusCode, 401);
    expect(await ServerApi(base, 'wrongcode').ping(), isFalse);
    expect(await ServerApi(base, server.passcode).ping(), isTrue);

    final page = await http.get(base.resolve('/pets/123'));
    expect(page.statusCode, 200);
    expect(page.body, contains('app'), reason: 'unknown paths load the app');
    final js = await http.get(base.resolve('/main.dart.js'));
    expect(js.headers['content-type'], startsWith('text/javascript'));
    final sneaky = await http.get(base.resolve('/..%2Fdata%2Fpasscode.txt'));
    expect(sneaky.body, isNot(contains(server.passcode)));
  });

  test('too many wrong passcodes are slowed down', () async {
    for (var i = 0; i < 10; i++) {
      await ServerApi(base, 'wrong$i').ping();
    }
    final res = await http.get(
      base.resolve('/api/ping'),
      headers: {'X-Pawdian-Token': server.passcode},
    );
    expect(res.statusCode, 429);
  });

  test('two clients share one database on the server', () async {
    // Two clients on purpose: like two phones using the same server.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final api = ServerApi(base, server.passcode);
    final a = await connect(api);
    final b = await connect(api);
    addTearDown(() async {
      await a.close();
      await b.close();
    });

    final seen = PetRepository(b).watchAll().firstWhere((l) => l.isNotEmpty);
    await PetRepository(a).create(
      const PetsCompanion(name: Value('麻糬'), species: Value(Species.dog)),
    );
    expect((await seen.timeout(const Duration(seconds: 5))).single.name, '麻糬');

    // The data is in the SQLite file on the server.
    final raw = sqlite3.open(server.databaseFile.path);
    addTearDown(raw.close);
    expect(raw.select('SELECT name FROM pets').single['name'], '麻糬');
  });

  test('photos are stored on the server', () async {
    final api = ServerApi(base, server.passcode);
    await api.putFile('pet_photos', 'abc.jpg', [1, 2, 3]);
    expect(
      File('${server.dataDir.path}/pet_photos/abc.jpg').readAsBytesSync(),
      [1, 2, 3],
    );
    final img = await http.get(api.fileUrl('pet_photos', 'abc.jpg'));
    expect(img.bodyBytes, [1, 2, 3]);
    expect(img.headers['content-type'], 'image/jpeg');
    await api.deleteFile('pet_photos', 'abc.jpg');
    expect(
      File('${server.dataDir.path}/pet_photos/abc.jpg').existsSync(),
      isFalse,
    );

    // Only the two photo folders and plain file names are accepted.
    final bad = await http.put(
      base.resolve('/api/files/../passcode.txt'),
      headers: {'X-Pawdian-Token': server.passcode},
      body: [1],
    );
    expect(bad.statusCode, 404);
    final other = await http.get(
      base.resolve('/api/files/push/vapid.json'),
      headers: {'X-Pawdian-Token': server.passcode},
    );
    expect(other.statusCode, 404);
  });

  test('push subscription and schedule are stored by the server', () async {
    final api = ServerApi(base, server.passcode);
    expect(b64urlDecode(await api.pushKey()), hasLength(65));
    final ua = P256KeyPair.generate();
    await api.subscribe({
      'endpoint': 'https://web.push.apple.com/abc',
      'keys': {
        'p256dh': b64url(ua.publicKey),
        'auth': 'BTBZMqHH6r4Tts7J_aSIgg',
      },
    });
    expect(
      server.push.subscriptions.single.endpoint,
      'https://web.push.apple.com/abc',
    );

    await uploadSchedule(api, [
      PlannedNotification(
        at: DateTime(2030, 1, 1, 9),
        title: '麻糬：用藥',
        body: '時間到了',
        ruleId: 'r1',
      ),
    ]);
    expect(server.push.items.single.title, '麻糬：用藥');
    expect(server.push.items.single.at, DateTime(2030, 1, 1, 9).toUtc());
  });

  test('daily snapshot copies the database once a day', () async {
    final db = sqlite3.open(server.databaseFile.path);
    db.execute('CREATE TABLE IF NOT EXISTS t (x)');
    db.close();
    server.snapshot(now: DateTime(2026, 11, 14));
    server.snapshot(now: DateTime(2026, 11, 14, 18));
    final snaps = Directory('${server.dataDir.path}/snapshots').listSync();
    expect(
      snaps.map((f) => f.path.split(Platform.pathSeparator).last),
      contains('pawdian-20261114.sqlite'),
    );
    expect(snaps, hasLength(1));
  });

  group('push service', () {
    test(
      'sends due reminders encrypted, once, and drops expired devices',
      () async {
        final ua = P256KeyPair.generate();
        final auth = b64urlDecode('BTBZMqHH6r4Tts7J_aSIgg');
        final requests = <http.Request>[];
        var status = 201;
        final service = PushService(
          Directory('${tmp.path}/push'),
          subject: 'mailto:noreply@pawdian.app',
          client: MockClient((req) async {
            requests.add(req);
            return http.Response('', status);
          }),
          log: (_) {},
        );
        service.subscribe(
          PushSubscription(
            'https://web.push.apple.com/device',
            b64url(ua.publicKey),
            b64url(auth),
          ),
        );
        final now = DateTime.utc(2026, 11, 14, 9);
        service.replaceSchedule([
          PushItem(
            at: now.subtract(const Duration(minutes: 2)),
            title: 'Due',
            body: 'b',
            ruleId: 'r1',
          ),
          PushItem(
            at: now.subtract(const Duration(hours: 2)),
            title: 'Old',
            body: 'b',
            ruleId: 'r2',
          ),
          PushItem(
            at: now.add(const Duration(hours: 1)),
            title: 'Later',
            body: 'b',
            ruleId: 'r3',
          ),
        ]);

        expect(await service.tick(now: now), 1);
        final req = requests.single;
        expect(req.headers['Content-Encoding'], 'aes128gcm');
        final jwt = RegExp(r'vapid t=([^,]+),')
            .firstMatch(req.headers['Authorization']!)!
            .group(1)!;
        expect(verifyVapidJwt(jwt, service.vapid.publicKey), isTrue);
        final msg = jsonDecode(
          utf8.decode(
            decryptPayload(body: req.bodyBytes, ua: ua, authSecret: auth),
          ),
        );
        expect(msg['title'], 'Due');
        expect(msg['url'], '/?rule=r1');

        // Re-uploading the same schedule does not send it again.
        service.replaceSchedule([
          PushItem(
            at: now.subtract(const Duration(minutes: 2)),
            title: 'Due',
            body: 'b',
            ruleId: 'r1',
          ),
          PushItem(
            at: now.add(const Duration(hours: 1)),
            title: 'Later',
            body: 'b',
            ruleId: 'r3',
          ),
        ]);
        expect(await service.tick(now: now), 0);

        // The push service says the device is gone: forget it.
        status = 410;
        await service.tick(now: now.add(const Duration(hours: 1, seconds: 5)));
        expect(service.subscriptions, isEmpty);

        // Everything survives a restart.
        final again = PushService(
          Directory('${tmp.path}/push'),
          subject: 'x',
          log: (_) {},
        );
        expect(b64url(again.vapid.publicKey), b64url(service.vapid.publicKey));
        expect(again.items.where((i) => i.sent), isNotEmpty);
      },
    );
  });
}
