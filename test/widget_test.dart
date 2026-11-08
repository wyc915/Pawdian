import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/app.dart';
import 'package:pawdian/core/notifications/notification_sync.dart';
import 'package:pawdian/core/settings/app_language.dart';

import 'helpers.dart';

void main() {
  group('resolveAppLocale', () {
    test('any Chinese locale maps to Traditional Chinese', () {
      expect(resolveAppLocale(const Locale('zh', 'TW')), kZhHant);
      expect(resolveAppLocale(const Locale('zh', 'CN')), kZhHant);
      expect(
        resolveAppLocale(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'HK',
          ),
        ),
        kZhHant,
      );
    });

    test('other or missing locales fall back to English', () {
      expect(resolveAppLocale(const Locale('ja')), kEnglish);
      expect(resolveAppLocale(null), kEnglish);
    });
  });

  testWidgets('shows welcome and English tabs on first launch', (tester) async {
    await pumpPawdian(tester);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Pets'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Welcome to Pawdian'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('switching to Traditional Chinese updates UI and persists', (
    tester,
  ) async {
    final app = await pumpPawdian(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language.chineseTraditional')));
    await tester.pumpAndSettle();

    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('設定'), findsWidgets);
    expect(app.prefs.getString('app_language'), 'chineseTraditional');
    await settle(tester);
  });

  testWidgets('restores saved language on launch', (tester) async {
    await pumpPawdian(tester, prefsValues: {'app_language': 'chineseTraditional'});
    expect(find.text('首頁'), findsWidgets);
    expect(find.text('歡迎使用 Pawdian'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('add pet, apply suggested schedule, complete from home', (
    tester,
  ) async {
    final app = await pumpPawdian(tester, prefsValues: {'care_region': 'tw'});

    await tester.tap(find.byKey(const Key('home.addPet')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('petForm.name')), 'Mochi');
    await tester.tap(find.byKey(const Key('petForm.save')));
    await tester.pumpAndSettle();

    // Taiwan dog template: 6 suggestions, all selected by default.
    expect(find.text('Suggested schedule'), findsOneWidget);
    expect(find.text('Add 6 reminders'), findsOneWidget);
    await tester.tap(find.byKey(const Key('templates.apply')));
    await tester.pumpAndSettle();

    // Lands on the pet's detail page.
    expect(find.text('Mochi'), findsWidgets);
    expect(find.text('Rabies vaccine'), findsOneWidget);
    final rules = await app.db.select(app.db.reminderRules).get();
    expect(rules, hasLength(6));

    // Notifications are planned for the new reminders.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PawdianApp)),
    );
    container.read(reminderSchedulerProvider).scheduleSoon();
    await settle(tester);
    expect(app.gateway.scheduled, isNotEmpty);

    // Everything starts today, so the home screen lists it.
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mochi · Rabies vaccine'), findsOneWidget);

    await tester.tap(find.byTooltip('Done').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('as done'), findsOneWidget);
    expect(await app.db.select(app.db.careRecords).get(), hasLength(1));
    // Repeating reminders stay scheduled, just moved forward.
    final pending = await (app.db.select(
      app.db.reminderRules,
    )..where((r) => r.nextDueAt.isNotNull())).get();
    expect(pending, hasLength(6));
    await settle(tester);
  });

  testWidgets('free version is limited to one pet', (tester) async {
    await pumpPawdian(tester);
    await tester.tap(find.byKey(const Key('home.addPet')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('petForm.name')), 'Mochi');
    await tester.tap(find.byKey(const Key('petForm.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('templates.skip')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pets').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pets.add')));
    await tester.pumpAndSettle();
    expect(find.text('Pawdian Pro'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('quick log, weight and timeline on the pet page', (
    tester,
  ) async {
    // A phone-sized screen so the whole pet page fits.
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = await pumpPawdian(tester);
    await tester.tap(find.byKey(const Key('home.addPet')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('petForm.name')), 'Mochi');
    await tester.tap(find.byKey(const Key('petForm.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('templates.skip')));
    await tester.pumpAndSettle();

    // One-tap log on the pet page.
    await tester.tap(find.byKey(const Key('quickLog.vomit')));
    await tester.pumpAndSettle();
    expect(find.text('Logged Vomit for Mochi'), findsOneWidget);
    expect(await app.db.select(app.db.careRecords).get(), hasLength(1));

    // Let the snack bar time out so it does not cover the buttons below.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Weight (test device locale is en_US, so pounds).
    await tester.ensureVisible(find.byKey(const Key('petDetail.addWeight')));
    await tester.tap(find.byKey(const Key('petDetail.addWeight')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('weight.value')), 'abc');
    await tester.tap(find.byKey(const Key('weight.save')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid weight'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('weight.value')), '9.5');
    await tester.tap(find.byKey(const Key('weight.save')));
    await tester.pumpAndSettle();
    expect(find.text('Latest 9.5 lb'), findsOneWidget);

    // Timeline shows both, and filters.
    await tester.ensureVisible(find.byKey(const Key('petDetail.timeline')));
    await tester.tap(find.byKey(const Key('petDetail.timeline')));
    await tester.pumpAndSettle();
    expect(find.text('Vomit'), findsOneWidget);
    expect(find.text('Weight 9.5 lb'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('timeline.filter.weight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timeline.filter.weight')));
    await tester.pumpAndSettle();
    expect(find.text('Vomit'), findsNothing);
    expect(find.text('Weight 9.5 lb'), findsOneWidget);
    await settle(tester);
  });
}
