import 'dart:async';

import 'package:drift/drift.dart' show DatabaseConnection;
// The drift remote protocol is marked experimental; the server and client
// are always built from the same commit, and test/web_server_test.dart
// covers the round trip.
// ignore: experimental_member_use
import 'package:drift/remote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../app.dart';
import '../core/billing/billing.dart';
import '../core/database/app_database.dart';
import '../core/notifications/notification_gateway.dart';
import '../core/notifications/notification_sync.dart';
import '../core/settings/app_language.dart';
import '../core/storage/photo_store.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/home_widget_sync.dart';
import '../l10n/app_localizations.dart';
import 'browser_stub.dart' if (dart.library.js_interop) 'browser_web.dart';
import 'server_api.dart';
import 'web_push_stub.dart'
    if (dart.library.js_interop) 'web_push_browser.dart';

const kPasscodeKey = 'server_passcode';

/// Origin the page was loaded from (the home server).
Uri get serverOrigin =>
    Uri.base.replace(path: '/', query: null, fragment: null);

/// Starts the web edition: data and reminders live on the home server.
Future<void> runWebEdition(SharedPreferences prefs) async {
  final saved = prefs.getString(kPasscodeKey);
  final api = saved == null ? null : ServerApi(serverOrigin, saved);
  if (api == null || !await api.ping()) {
    runApp(_PasscodeApp(prefs: prefs));
    return;
  }

  final DatabaseConnection connection;
  final WebSocketChannel socket;
  try {
    socket = WebSocketChannel.connect(api.databaseSocket);
    await socket.ready;
    connection = await connectToRemoteAndInitialize(
      socket.cast<String>().transform(jsonDocument),
      serialize: true,
    );
  } catch (_) {
    runApp(_PasscodeApp(prefs: prefs, failed: true));
    return;
  }

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      serverApiProvider.overrideWithValue(api),
      appDatabaseProvider.overrideWith((ref) {
        final db = AppDatabase(connection);
        ref.onDispose(db.close);
        return db;
      }),
      notificationGatewayProvider.overrideWithValue(createWebPushGateway(api)),
      billingGatewayProvider.overrideWithValue(_NoBillingGateway()),
      homeWidgetGatewayProvider.overrideWithValue(_NoHomeWidget()),
      photoStoreProvider.overrideWith(
        (ref) => RemoteImageStore(api, 'pet_photos'),
      ),
      attachmentStoreProvider.overrideWith(
        (ref) => RemoteImageStore(api, 'attachments'),
      ),
    ],
  );

  // iOS suspends the page in the background and drops the socket; reload
  // (which reconnects) as soon as the user comes back.
  unawaited(
    socket.sink.done.then((_) => whenVisible(reloadPage)),
  );

  final launch = await container.read(notificationGatewayProvider).launchResponse();
  runApp(
    UncontrolledProviderScope(container: container, child: const PawdianApp()),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (launch != null) {
      container.read(notificationResponseHandlerProvider).handle(launch);
    }
    container.read(reminderSchedulerProvider).scheduleSoon();
  });
}

class _NoBillingGateway implements BillingGateway {
  @override
  Stream<BillingEvent> get events => const Stream.empty();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<List<ProOffer>> loadOffers() async => const [];
  @override
  Future<void> buy(ProProduct product) async {}
  @override
  Future<Set<ProProduct>?> ownedProducts() async => null;
  @override
  void dispose() {}
}

class _NoHomeWidget implements HomeWidgetGateway {
  @override
  Future<void> show(WidgetTexts texts) async {}
}

/// Asks for the server passcode, checks it and reloads the app.
class _PasscodeApp extends StatelessWidget {
  const _PasscodeApp({required this.prefs, this.failed = false});

  final SharedPreferences prefs;
  final bool failed;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildLightTheme(),
    darkTheme: buildDarkTheme(),
    supportedLocales: kSupportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    localeListResolutionCallback: (locales, supported) => resolveAppLocale(
      locales?.isNotEmpty == true ? locales!.first : null,
    ),
    home: _PasscodePage(prefs: prefs, failed: failed),
  );
}

class _PasscodePage extends StatefulWidget {
  const _PasscodePage({required this.prefs, required this.failed});

  final SharedPreferences prefs;
  final bool failed;

  @override
  State<_PasscodePage> createState() => _PasscodePageState();
}

class _PasscodePageState extends State<_PasscodePage> {
  final _field = TextEditingController();
  late bool _error = widget.failed;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _field.text = widget.prefs.getString(kPasscodeKey) ?? '';
  }

  Future<void> _connect() async {
    final code = _field.text.trim().toLowerCase();
    if (code.isEmpty) return;
    setState(() => _busy = true);
    final ok = await ServerApi(serverOrigin, code).ping();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = true;
      });
      return;
    }
    await widget.prefs.setString(kPasscodeKey, code);
    reloadPage();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = context.paw;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: p.mint.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.pets, size: 44, color: p.mint.fg),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.webPasscodeTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.webPasscodeBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.subtle),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('web.passcode'),
                    controller: _field,
                    autofocus: true,
                    autocorrect: false,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _connect(),
                    decoration: InputDecoration(
                      labelText: l.webPasscodeField,
                      errorText: _error ? l.webPasscodeWrong : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _connect,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.webPasscodeConnect),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
