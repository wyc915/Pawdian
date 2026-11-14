import '../core/notifications/notification_gateway.dart';
import '../features/reminders/domain/notification_planner.dart';
import 'server_api.dart';

/// Notification gateway of the web edition: reminders are planned by the
/// app as usual, uploaded to the home server, and the server sends them to
/// the phone with Web Push.
abstract class WebPushGateway implements NotificationGateway {
  /// Whether this browser can receive Web Push at all.
  bool get supported;

  /// On iPhone, Web Push only works after "Add to Home Screen".
  bool get needsInstall;

  /// Sends a test notification to every subscribed device.
  Future<int> sendTest(String title, String body);
}

/// The planned notifications in the format the server stores.
List<Map<String, Object?>> scheduleJson(List<PlannedNotification> planned) => [
  for (final p in planned)
    {
      'at': p.at.toUtc().millisecondsSinceEpoch,
      'title': p.title,
      'body': p.body,
      'ruleId': p.ruleId,
    },
];

/// Uploads the schedule; shared by the web implementation and tests.
Future<void> uploadSchedule(ServerApi api, List<PlannedNotification> planned) =>
    api.putSchedule(scheduleJson(planned));
