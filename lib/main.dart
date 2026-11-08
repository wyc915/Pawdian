import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/notifications/notification_gateway.dart';
import 'core/notifications/notification_sync.dart';
import 'core/settings/app_language.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  });
}
