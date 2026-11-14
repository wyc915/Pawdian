// Pawdian home server: serves the web app and keeps the data on this PC.
//
//   flutter build web
//   dart run bin/pawdian_server.dart           # http://127.0.0.1:8790
//   tailscale serve --bg --https=9443 http://127.0.0.1:8790
//                                              # https://<pc>.<tailnet>.ts.net:9443
//
// Always pass --https=9443 to tailscale serve: other services on this PC
// already use 443, 8443 and 10443. Never use `tailscale funnel` (public) or
// `tailscale serve reset` (removes every service).
//
// Options: --port 8790  --host 127.0.0.1  --data <dir>  --web build/web
//          --contact mailto:you@example.com   (VAPID contact for push services)
import 'dart:io';

import 'package:pawdian/server/server.dart';

Future<void> main(List<String> args) async {
  String? opt(String name) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final home =
      Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
  final server = PawdianServer(
    dataDir: Directory(opt('data') ?? '$home${Platform.pathSeparator}PawdianData'),
    webDir: Directory(opt('web') ?? 'build/web'),
    host: opt('host') ?? '127.0.0.1',
    port: int.tryParse(opt('port') ?? '') ?? 8790,
    contact: opt('contact') ?? 'mailto:noreply@pawdian.app',
    log: (m) => stdout.writeln('[${DateTime.now().toIso8601String().substring(0, 19)}] $m'),
  );
  try {
    await server.start();
  } on SocketException catch (e) {
    stderr.writeln("Can't listen on ${server.host}:${server.port}: ${e.message}");
    stderr.writeln('Try another port, e.g. --port 8791, and point tailscale serve at it.');
    exit(1);
  }
  stdout
    ..writeln('Pawdian server on http://${server.host}:${server.boundPort}')
    ..writeln('Data folder: ${server.dataDir.absolute.path}')
    ..writeln('Passcode (enter it once on each device): ${server.passcode}')
    ..writeln('Press Ctrl+C to stop.');
  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
    exit(0);
  });
}
