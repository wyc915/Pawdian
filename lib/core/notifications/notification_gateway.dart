import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminders/domain/notification_planner.dart';
import '../../l10n/app_localizations.dart';

/// Notification action ids.
abstract final class NotificationActions {
  static const done = 'done';
  static const snooze = 'snooze1h';
  static const tomorrow = 'tomorrow';
}

/// Thin wrapper over the platform so tests can use a fake.
abstract class NotificationGateway {
  Future<void> init(void Function(NotificationResponse) onResponse);

  /// The notification (and action) that cold-started the app, if any.
  Future<NotificationResponse?> launchResponse();

  Future<bool> notificationsEnabled();
  Future<bool> requestNotifications();
  Future<bool> canScheduleExact();
  Future<void> requestExact();

  /// Replaces every pending notification with [planned].
  Future<void> replaceAll(List<PlannedNotification> planned, AppLocalizations l);
}

class LocalNotificationGateway implements NotificationGateway {
  static const _channelId = 'care_reminders';

  final _plugin = FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> init(void Function(NotificationResponse) onResponse) async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone lookup failed, using UTC: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        // Monochrome status-bar icon (res/drawable/ic_stat_paw.xml).
        android: AndroidInitializationSettings('@drawable/ic_stat_paw'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: onResponse,
    );
  }

  @override
  Future<NotificationResponse?> launchResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse;
  }

  @override
  Future<bool> notificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? true;

  @override
  Future<bool> requestNotifications() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  @override
  Future<void> requestExact() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> replaceAll(
    List<PlannedNotification> planned,
    AppLocalizations l,
  ) async {
    await _plugin.cancelAll();
    if (planned.isEmpty) return;
    final mode = await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l.notifChannelName,
        channelDescription: l.notifChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
            NotificationActions.done,
            l.notifActionDone,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            NotificationActions.snooze,
            l.notifActionSnooze,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            NotificationActions.tomorrow,
            l.notifActionTomorrow,
            showsUserInterface: true,
          ),
        ],
      ),
    );
    for (var i = 0; i < planned.length; i++) {
      final p = planned[i];
      await _plugin.zonedSchedule(
        id: i,
        scheduledDate: tz.TZDateTime.from(p.at, tz.local),
        notificationDetails: details,
        androidScheduleMode: mode,
        title: p.title,
        body: p.body,
        payload: p.ruleId,
      );
    }
  }
}

final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => LocalNotificationGateway(),
);
