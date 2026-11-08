import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/app.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/notifications/notification_gateway.dart';
import 'package:pawdian/core/settings/app_language.dart';
import 'package:pawdian/features/reminders/domain/notification_planner.dart';
import 'package:pawdian/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppDatabase memoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

class FakeNotificationGateway implements NotificationGateway {
  List<PlannedNotification> scheduled = [];
  bool enabled = true;
  bool exact = true;

  @override
  Future<void> init(void Function(NotificationResponse) onResponse) async {}

  @override
  Future<NotificationResponse?> launchResponse() async => null;

  @override
  Future<bool> notificationsEnabled() async => enabled;

  @override
  Future<bool> requestNotifications() async => enabled;

  @override
  Future<bool> canScheduleExact() async => exact;

  @override
  Future<void> requestExact() async {}

  @override
  Future<void> replaceAll(
    List<PlannedNotification> planned,
    AppLocalizations l,
  ) async {
    scheduled = planned;
  }
}

class TestApp {
  TestApp(this.db, this.gateway, this.prefs);

  final AppDatabase db;
  final FakeNotificationGateway gateway;
  final SharedPreferences prefs;
}

Future<TestApp> pumpPawdian(
  WidgetTester tester, {
  Map<String, Object> prefsValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final db = memoryDatabase();
  final gateway = FakeNotificationGateway();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        notificationGatewayProvider.overrideWithValue(gateway),
      ],
      child: const PawdianApp(),
    ),
  );
  await tester.pumpAndSettle();
  return TestApp(db, gateway, prefs);
}

/// Lets debounce timers fire and the UI settle before the test ends.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}
