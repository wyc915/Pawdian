import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_status.dart';
import 'core/notifications/notification_sync.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_language.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class PawdianApp extends ConsumerStatefulWidget {
  const PawdianApp({super.key});

  @override
  ConsumerState<PawdianApp> createState() => _PawdianAppState();
}

class _PawdianAppState extends ConsumerState<PawdianApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Permissions can change in system settings while the app is away.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationStatusProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final language = ref.watch(appLanguageProvider);
    return NotificationSync(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        locale: language.locale,
        supportedLocales: kSupportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: (locales, supported) => resolveAppLocale(
          locales?.isNotEmpty == true ? locales!.first : null,
        ),
        routerConfig: router,
      ),
    );
  }
}
