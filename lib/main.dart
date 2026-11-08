import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/billing/billing.dart';
import 'core/notifications/notification_gateway.dart';
import 'core/notifications/notification_sync.dart';
import 'core/settings/app_language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date formats are also used outside widgets (notifications, home widget).
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  final gateway = container.read(notificationGatewayProvider);
  await gateway.init(
    (response) =>
        container.read(notificationResponseHandlerProvider).handle(response),
  );
  final launch = await gateway.launchResponse();

  runApp(
    UncontrolledProviderScope(container: container, child: const PawdianApp()),
  );

  // Handle the notification that cold-started the app once the UI exists,
  // and re-plan reminders in case the device rebooted or time zone changed.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (launch != null) {
      container.read(notificationResponseHandlerProvider).handle(launch);
    }
    container.read(reminderSchedulerProvider).scheduleSoon();
    // Start listening for purchases (including ones finished while the app
    // was closed) and re-check Pro ownership with Google Play.
    container.read(billingControllerProvider).refresh();
  });
}
