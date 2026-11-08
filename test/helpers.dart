import 'dart:async';

import 'package:drift/drift.dart';
import 'package:pawdian/core/billing/billing.dart';
import 'package:pawdian/core/widgets/home_widget_sync.dart';
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

class FakeBillingGateway implements BillingGateway {
  final _events = StreamController<BillingEvent>.broadcast();
  List<ProOffer> offers = const [
    ProOffer(product: ProProduct.yearly, price: r'$14.99'),
    ProOffer(product: ProProduct.monthly, price: r'$2.99'),
    ProOffer(product: ProProduct.lifetime, price: r'$39.99'),
  ];

  /// What [ownedProducts] answers; null = store unreachable.
  Set<ProProduct>? owned = const {};
  final bought = <ProProduct>[];

  void emit(BillingEvent e) => _events.add(e);

  @override
  Stream<BillingEvent> get events => _events.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProOffer>> loadOffers() async => offers;

  @override
  Future<void> buy(ProProduct product) async {
    bought.add(product);
    _events.add(PurchaseSucceeded(product));
  }

  @override
  Future<Set<ProProduct>?> ownedProducts() async => owned;

  @override
  void dispose() => _events.close();
}

class FakeHomeWidgetGateway implements HomeWidgetGateway {
  WidgetTexts? last;

  @override
  Future<void> show(WidgetTexts texts) async => last = texts;
}

class TestApp {
  TestApp(this.db, this.gateway, this.prefs, this.billing, this.widget);

  final AppDatabase db;
  final FakeNotificationGateway gateway;
  final SharedPreferences prefs;
  final FakeBillingGateway billing;
  final FakeHomeWidgetGateway widget;
}

Future<TestApp> pumpPawdian(
  WidgetTester tester, {
  Map<String, Object> prefsValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final db = memoryDatabase();
  final gateway = FakeNotificationGateway();
  final billing = FakeBillingGateway();
  final homeWidget = FakeHomeWidgetGateway();
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        notificationGatewayProvider.overrideWithValue(gateway),
        billingGatewayProvider.overrideWithValue(billing),
        homeWidgetGatewayProvider.overrideWithValue(homeWidget),
      ],
      child: const PawdianApp(),
    ),
  );
  await tester.pumpAndSettle();
  return TestApp(db, gateway, prefs, billing, homeWidget);
}

/// Lets debounce timers fire and the UI settle before the test ends.
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}
