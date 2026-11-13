import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/core/notifications/background_actions.dart';
import 'package:pawdian/core/notifications/notification_gateway.dart';
import 'package:pawdian/core/settings/app_language.dart';
import 'package:pawdian/core/settings/app_settings.dart';
import 'package:pawdian/core/storage/file_cleanup.dart';
import 'package:pawdian/core/storage/photo_store.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/records/data/attachment_repository.dart';
import 'package:pawdian/features/records/data/record_repository.dart';
import 'package:pawdian/features/reminders/data/reminder_repository.dart';
import 'package:pawdian/features/report/report_builder.dart';
import 'package:pawdian/features/templates/care_templates.dart';
import 'package:pawdian/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

final zh = lookupAppLocalizations(const Locale('zh'));

void main() {
  setUpAll(initializeDateFormatting);

  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('pawdian5'));
  tearDown(() => tmp.delete(recursive: true));

  Future<String> addPet(AppDatabase db, [String name = 'Mochi']) =>
      PetRepository(db).create(
        PetsCompanion(name: Value(name), species: const Value(Species.dog)),
      );

  group('notification buttons', () {
    test(
      'done, snooze and tomorrow update the reminder; a tap does not',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final repo = ReminderRepository(db);
        final petId = await addPet(db);
        final ruleId = await repo.create(
          petId,
          ReminderDraft(
            type: ReminderType.medication,
            startDate: DateTime(2026, 11, 10),
            times: const [540],
            unit: RepeatUnit.day,
          ),
          now: DateTime(2026, 11, 9),
        );
        final now = DateTime(2026, 11, 10, 9, 5);

        expect(
          await applyNotificationAction(repo, null, ruleId, now: now),
          isFalse,
        );

        expect(
          await applyNotificationAction(
            repo,
            NotificationActions.snooze,
            ruleId,
            now: now,
          ),
          isTrue,
        );
        expect(
          (await repo.get(ruleId))!.snoozedUntil,
          now.add(const Duration(hours: 1)),
        );

        await applyNotificationAction(
          repo,
          NotificationActions.tomorrow,
          ruleId,
          now: now,
        );
        expect(
          (await repo.get(ruleId))!.snoozedUntil,
          now.add(const Duration(days: 1)),
        );

        await applyNotificationAction(
          repo,
          NotificationActions.done,
          ruleId,
          now: now,
        );
        expect(await db.select(db.careRecords).get(), hasLength(1));
        expect((await repo.get(ruleId))!.nextDueAt, DateTime(2026, 11, 11, 9));
      },
    );
  });

  group('unused file cleanup', () {
    test(
      'removes files of deleted pets and records, keeps live and new ones',
      () async {
        final db = memoryDatabase();
        addTearDown(db.close);
        final photos = PhotoStore(
          await Directory(p.join(tmp.path, 'pet_photos')).create(),
        );
        final attachments = PhotoStore(
          await Directory(p.join(tmp.path, 'attachments')).create(),
        );
        final old = DateTime(2026, 11, 1);
        Future<void> put(PhotoStore store, String name, {DateTime? at}) async {
          final f = await File(p.join(store.directory.path, name))
              .writeAsBytes([1]);
          await f.setLastModified(at ?? old);
        }

        final pets = PetRepository(db);
        final live = await addPet(db, 'Live');
        final gone = await addPet(db, 'Gone');
        await (db.update(db.pets)..where((t) => t.id.equals(live))).write(
          const PetsCompanion(photoFile: Value('live.jpg')),
        );
        await (db.update(db.pets)..where((t) => t.id.equals(gone))).write(
          const PetsCompanion(photoFile: Value('gone.jpg')),
        );
        final records = RecordRepository(db);
        final keepRecord = await records.quickLog(live, RecordType.vomit);
        final deletedRecord = await records.quickLog(live, RecordType.vomit);
        final goneRecord = await records.quickLog(gone, RecordType.vomit);
        final att = AttachmentRepository(db);
        await att.add(keepRecord, 'keep.jpg');
        await att.add(deletedRecord, 'deleted-record.jpg');
        await att.add(goneRecord, 'gone-pet.jpg');
        await records.softDelete(deletedRecord);
        await pets.softDelete(gone);

        await put(photos, 'live.jpg');
        await put(photos, 'gone.jpg');
        await put(photos, 'stray.jpg');
        await put(attachments, 'keep.jpg');
        await put(attachments, 'deleted-record.jpg');
        await put(attachments, 'gone-pet.jpg');
        final now = DateTime(2026, 11, 13, 12);
        await put(
          attachments,
          'just-picked.jpg',
          at: now.subtract(const Duration(minutes: 5)),
        );

        final deleted = await FileCleanup(db)
            .run(photos: photos, attachments: attachments, now: now);
        expect(deleted, 4);
        List<String> names(PhotoStore s) =>
            s.directory.listSync().map((e) => p.basename(e.path)).toList()
              ..sort();
        expect(names(photos), ['live.jpg']);
        expect(names(attachments), ['just-picked.jpg', 'keep.jpg']);
      },
    );
  });

  group('quick log order', () {
    late ProviderContainer container;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });
    tearDown(() => container.dispose());

    test('reordering changes the buttons and survives a restart', () async {
      final notifier = container.read(quickLogTypesProvider.notifier);
      final before = container.read(quickLogTypesProvider);
      final order = notifier.order;
      expect(order, kQuickLogTypes);

      // Move a hidden type (cough) to the front and show it; move the
      // first visible one (feeding) to the end.
      expect(before, isNot(contains(RecordType.cough)));
      await notifier.reorder(order.indexOf(RecordType.cough), 0);
      await notifier.toggle(RecordType.cough, true);
      await notifier.reorder(
        notifier.order.indexOf(RecordType.feeding),
        order.length - 1,
      );
      final after = container.read(quickLogTypesProvider);
      expect(after.first, RecordType.cough);
      expect(after.last, RecordType.feeding);
      expect(after, hasLength(before.length + 1));

      final prefs = await SharedPreferences.getInstance();
      final restarted = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(restarted.dispose);
      expect(restarted.read(quickLogTypesProvider), after);
    });
  });

  test('vet report splits long tables across pages', () async {
    final font = ByteData.sublistView(
      await File('assets/fonts/NotoSansTC-Subset.ttf').readAsBytes(),
    );
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await addPet(db, '麻糬');
    final records = RecordRepository(db);
    final now = DateTime(2026, 11, 9, 12);
    for (var i = 0; i < 120; i++) {
      await records.create(
        petId,
        RecordDraft(
          type: RecordType.vomit,
          occurredAt: now.subtract(Duration(hours: i * 6)),
          severity: Severity.mild,
          notes: '第 $i 次，吃草後嘔吐',
        ),
      );
    }
    final bytes = await buildVetReport(
      data: ReportData(
        pet: (await PetRepository(db).get(petId))!,
        records: await records.watchAll(petId).first,
        weights: const [],
        from: now.subtract(const Duration(days: 90)),
        to: now,
      ),
      l: zh,
      unit: WeightUnit.kg,
      fontData: font,
      now: now,
    );
    final text = latin1.decode(bytes);
    final pages = RegExp(r'/Type\s*/Page(?![s\w])').allMatches(text).length;
    expect(pages, greaterThan(2));
  });

  test('subset font still covers the characters the app uses', () async {
    // Every character of the Chinese UI strings (used in PDF headings).
    final arb = await File('lib/l10n/app_zh.arb').readAsString();
    final strings = (jsonDecode(arb) as Map<String, dynamic>).entries
        .where((e) => !e.key.startsWith('@'))
        .map((e) => e.value as String)
        .join();
    final font = await File('assets/fonts/NotoSansTC-Subset.ttf').readAsBytes();
    final cmap = _cmapCodepoints(ByteData.sublistView(font));
    final missing = {
      for (final r in strings.runes)
        if (r > 0x7F &&
            !cmap.contains(r) &&
            !'{}'.contains(String.fromCharCode(r)))
          String.fromCharCode(r),
    };
    // Emoji are not drawn in the PDF; everything else must be present.
    missing.removeWhere(
      (c) => c.runes.first > 0xFFFF || c.runes.first >= 0x1F000,
    );
    expect(missing, isEmpty);
    for (final c in '麻糬狗貓疫苗驅蟲'.runes) {
      expect(cmap.contains(c), isTrue);
    }
  });

  test('US core vaccines repeat every 3 years, Taiwan yearly', () {
    int coreInterval(CareRegion r) => templatesFor(
      r,
      Species.dog,
    ).firstWhere((t) => t.key == 'coreDog').interval;
    expect(coreInterval(CareRegion.us), 3);
    expect(coreInterval(CareRegion.tw), 1);
    expect(
      templatesFor(
        CareRegion.tw,
        Species.cat,
      ).firstWhere((t) => t.key == 'rabies').unit,
      RepeatUnit.year,
    );
  });
}

/// Code points in a TrueType font's format-4 / format-12 cmap.
Set<int> _cmapCodepoints(ByteData f) {
  final numTables = f.getUint16(4);
  var cmapOffset = -1;
  for (var i = 0; i < numTables; i++) {
    final rec = 12 + i * 16;
    final tag = String.fromCharCodes([
      for (var j = 0; j < 4; j++) f.getUint8(rec + j),
    ]);
    if (tag == 'cmap') cmapOffset = f.getUint32(rec + 8);
  }
  final out = <int>{};
  final n = f.getUint16(cmapOffset + 2);
  for (var i = 0; i < n; i++) {
    final sub = cmapOffset + f.getUint32(cmapOffset + 4 + i * 8 + 4);
    final format = f.getUint16(sub);
    if (format == 12) {
      final groups = f.getUint32(sub + 12);
      for (var g = 0; g < groups; g++) {
        final start = f.getUint32(sub + 16 + g * 12);
        final end = f.getUint32(sub + 20 + g * 12);
        for (var c = start; c <= end; c++) {
          out.add(c);
        }
      }
    } else if (format == 4) {
      final segX2 = f.getUint16(sub + 6);
      for (var s = 0; s < segX2; s += 2) {
        final end = f.getUint16(sub + 14 + s);
        final start = f.getUint16(sub + 16 + segX2 + s);
        for (var c = start; c <= end && c != 0xFFFF; c++) {
          out.add(c);
        }
      }
    }
  }
  return out;
}
