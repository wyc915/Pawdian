import 'dart:isolate';
import 'dart:ui';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/reminders/data/reminder_repository.dart';
import '../database/app_database.dart';
import '../settings/app_language.dart';
import 'notification_gateway.dart';
import 'notification_sync.dart';

/// Name of the port the running app listens on, so a background action
/// (which uses its own database connection) can tell it to refresh.
const kDataChangedPortName = 'pawdian.data_changed';

/// Applies a notification button. Returns false for a plain tap (no action).
Future<bool> applyNotificationAction(
  ReminderRepository repo,
  String? actionId,
  String ruleId, {
  DateTime? now,
}) async {
  final t = now ?? DateTime.now();
  switch (actionId) {
    case NotificationActions.done:
      await repo.complete(ruleId, now: t);
    case NotificationActions.snooze:
      await repo.snooze(ruleId, t.add(const Duration(hours: 1)));
    case NotificationActions.tomorrow:
      await repo.snooze(ruleId, t.add(const Duration(days: 1)));
    default:
      return false;
  }
  return true;
}

/// Runs when a notification button is pressed, in a separate background
/// isolate, without opening the app.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  final ruleId = response.payload;
  if (ruleId == null || ruleId.isEmpty) return;
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  try {
    await container.read(notificationGatewayProvider).init((_) {});
    final handled = await applyNotificationAction(
      container.read(reminderRepositoryProvider),
      response.actionId,
      ruleId,
    );
    if (!handled) return;
    // Plan the next notifications and update the home screen widget.
    await container.read(reminderSchedulerProvider).resyncNow();
    IsolateNameServer.lookupPortByName(kDataChangedPortName)?.send('changed');
  } catch (e) {
    debugPrint('Background notification action failed: $e');
  } finally {
    await container.read(appDatabaseProvider).close();
    container.dispose();
  }
}

/// In the running app: refresh screens and notifications when a background
/// action changed the database.
ReceivePort listenForBackgroundChanges(ProviderContainer container) {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(kDataChangedPortName);
  IsolateNameServer.registerPortWithName(port.sendPort, kDataChangedPortName);
  port.listen((_) {
    final db = container.read(appDatabaseProvider);
    db.notifyUpdates({
      TableUpdate.onTable(db.reminderRules),
      TableUpdate.onTable(db.careRecords),
    });
    container.read(reminderSchedulerProvider).scheduleSoon();
  });
  return port;
}
