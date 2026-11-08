import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_gateway.dart';

class NotificationStatus {
  const NotificationStatus({required this.enabled, required this.exact});

  final bool enabled;
  final bool exact;

  bool get allGood => enabled && exact;
}

/// Invalidate after requesting permissions or when the app resumes.
final notificationStatusProvider = FutureProvider<NotificationStatus>((ref) async {
  final gateway = ref.watch(notificationGatewayProvider);
  return NotificationStatus(
    enabled: await gateway.notificationsEnabled(),
    exact: await gateway.canScheduleExact(),
  );
});

/// Asks for the notification permission (Android 13+) the first time the user
/// creates reminders. Exact alarms open a system screen, so they are only
/// requested from Settings or the home banner.
Future<void> requestNotificationPermission(WidgetRef ref) async {
  await ref.read(notificationGatewayProvider).requestNotifications();
  ref.invalidate(notificationStatusProvider);
}
