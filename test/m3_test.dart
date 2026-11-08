import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;
import 'package:pawdian/core/billing/billing.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/core/settings/app_language.dart';
import 'package:pawdian/core/settings/app_settings.dart';
import 'package:pawdian/core/widgets/home_widget_sync.dart';
import 'package:pawdian/features/backup/backup_service.dart';
import 'package:pawdian/features/backup/csv_export.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/records/data/attachment_repository.dart';
import 'package:pawdian/features/records/data/record_repository.dart';
import 'package:pawdian/features/reminders/data/reminder_repository.dart';
import 'package:pawdian/features/report/report_builder.dart';
import 'package:pawdian/features/weight/data/weight_repository.dart';
import 'package:pawdian/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

final en = lookupAppLocalizations(const Locale('en'));
final zh = lookupAppLocalizations(const Locale('zh'));

void main() {
  setUpAll(initializeDateFormatting);

  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('pawdian'));
  tearDown(() => tmp.delete(recursive: true));

  group('backup', () {
    test('round-trips database and photos into a fresh install', () async {
      final docsA = await Directory(p.join(tmp.path, 'a')).create();
      final docsB = await Directory(p.join(tmp.path, 'b')).create();
      await Directory(p.join(docsA.path, kPhotoDirName)).create();
      await File(
        p.join(docsA.path, kPhotoDirName, 'cat.jpg'),
      ).writeAsBytes([1, 2, 3]);

      final db = memoryDatabase();
      final petId = await PetRepository(db).create(
        const PetsCompanion(name: Value('Mochi'), species: Value(Species.cat)),
      );
      final recordId = await RecordRepository(db).quickLog(
        petId,
        RecordType.vomit,
      );
      await AttachmentRepository(db).add(recordId, 'lab.jpg');
      await WeightRepository(
        db,
      ).add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4200);

      final serviceA = BackupService(documentsDir: docsA, tempDir: tmp);
      final file = await serviceA.createBackup(db, now: DateTime(2026, 11, 9, 8, 5));
      await db.close();
      expect(p.basename(file.path), 'Pawdian-backup-20261109-0805.pawdian');

      final serviceB = BackupService(documentsDir: docsB, tempDir: tmp);
      final archive = await serviceB.readBackup(file, currentSchema: 3);
      await serviceB.applyBackup(archive);

      expect(
        await File(p.join(docsB.path, kPhotoDirName, 'cat.jpg')).readAsBytes(),
        [1, 2, 3],
      );
      final restored = AppDatabase(
        DatabaseConnection(
          NativeDatabase(serviceB.databaseFile),
          closeStreamsSynchronously: true,
        ),
      );
      addTearDown(restored.close);
      expect((await PetRepository(restored).watchAll().first).single.name, 'Mochi');
      expect(await RecordRepository(restored).watchAll(petId).first, hasLength(1));
      expect(await AttachmentRepository(restored).forRecord(recordId), hasLength(1));
      expect(await WeightRepository(restored).watchForPet(petId).first, hasLength(1));
    });

    test('rejects other files and newer backups', () async {
      final service = BackupService(documentsDir: tmp, tempDir: tmp);
      final notZip = await File(p.join(tmp.path, 'x.pawdian')).writeAsString('hi');
      await expectLater(
        service.readBackup(notZip, currentSchema: 3),
        throwsA(isA<BackupException>().having((e) => e.reason, 'reason', BackupFailure.invalid)),
      );

      Future<File> zipWith(Map<String, Object> manifest) async {
        final archive = Archive()
          ..addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)))
          ..addFile(ArchiveFile.bytes('database.sqlite', Uint8List(1)));
        final f = File(p.join(tmp.path, '${manifest.hashCode}.pawdian'));
        return f.writeAsBytes(ZipEncoder().encode(archive));
      }

      await expectLater(
        service.readBackup(
          await zipWith({'app': 'other', 'format': 1, 'schemaVersion': 1}),
          currentSchema: 3,
        ),
        throwsA(isA<BackupException>().having((e) => e.reason, 'reason', BackupFailure.invalid)),
      );
      await expectLater(
        service.readBackup(
          await zipWith({'app': 'pawdian', 'format': 1, 'schemaVersion': 9}),
          currentSchema: 3,
        ),
        throwsA(isA<BackupException>().having((e) => e.reason, 'reason', BackupFailure.tooNew)),
      );
    });

    test('ignores entries outside the photo folders', () async {
      final docs = await Directory(p.join(tmp.path, 'docs')).create();
      final archive = Archive()
        ..addFile(
          ArchiveFile.string(
            'manifest.json',
            jsonEncode({'app': 'pawdian', 'format': 1, 'schemaVersion': 3}),
          ),
        )
        ..addFile(ArchiveFile.bytes('database.sqlite', Uint8List(1)))
        ..addFile(ArchiveFile.bytes('../evil.txt', Uint8List(1)))
        ..addFile(ArchiveFile.bytes('pet_photos/../../evil2.txt', Uint8List(1)))
        ..addFile(ArchiveFile.bytes('attachments/ok.jpg', Uint8List(1)));
      await BackupService(documentsDir: docs, tempDir: tmp).applyBackup(archive);
      expect(File(p.join(tmp.path, 'evil.txt')).existsSync(), isFalse);
      expect(File(p.join(tmp.path, 'evil2.txt')).existsSync(), isFalse);
      expect(File(p.join(docs.path, 'attachments', 'ok.jpg')).existsSync(), isTrue);
    });
  });

  test('CSV: BOM, escaping, chronological order', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await PetRepository(db).create(
      const PetsCompanion(name: Value('Mochi'), species: Value(Species.dog)),
    );
    await RecordRepository(db).create(
      petId,
      RecordDraft(
        type: RecordType.vomit,
        occurredAt: DateTime(2026, 11, 2, 9),
        notes: 'ate grass, "twice"',
      ),
    );
    await WeightRepository(
      db,
    ).add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4200);
    final csv = buildCsv(
      pets: await PetRepository(db).watchAll().first,
      records: await RecordRepository(db).watchAll(petId).first,
      weights: await WeightRepository(db).watchForPet(petId).first,
      l: en,
      unit: WeightUnit.kg,
    );
    expect(csv.startsWith('﻿'), isTrue);
    final lines = csv.substring(1).trim().split('\r\n');
    expect(lines, hasLength(3));
    expect(lines[1], contains('4.2 kg'));
    expect(lines[2], contains('"ate grass, ""twice"""'));
  });

  test('vet report renders Chinese PDF and groups records', () async {
    final font = ByteData.sublistView(
      await File('assets/fonts/NotoSansTC-Regular.ttf').readAsBytes(),
    );
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await PetRepository(db).create(
      PetsCompanion(
        name: const Value('麻糬'),
        species: const Value(Species.cat),
        birthDate: Value(DateTime(2022, 3, 1)),
      ),
    );
    final records = RecordRepository(db);
    final now = DateTime(2026, 11, 9, 12);
    await records.create(
      petId,
      RecordDraft(type: RecordType.vomit, occurredAt: now, severity: Severity.mild),
    );
    await records.create(
      petId,
      RecordDraft(type: RecordType.feeding, occurredAt: now),
    );
    await records.create(
      petId,
      RecordDraft(type: RecordType.poop, occurredAt: now, notes: '偏軟'),
    );
    await records.create(
      petId,
      RecordDraft(
        type: RecordType.vetVisit,
        occurredAt: now,
        vetClinic: '快樂動物醫院',
        diagnosis: '腸胃炎',
        cost: 1200,
      ),
    );
    final weights = WeightRepository(db);
    await weights.add(petId, measuredAt: DateTime(2026, 10, 1), grams: 4300);
    await weights.add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4100);

    final all = await records.watchAll(petId).first;
    final symptoms = recordsForSection(all, RecordCategory.symptom);
    expect(symptoms.map((r) => r.type).toSet(), {RecordType.vomit, RecordType.poop});
    expect(recordsForSection(all, RecordCategory.vet), hasLength(1));

    final bytes = await buildVetReport(
      data: ReportData(
        pet: (await PetRepository(db).get(petId))!,
        records: all,
        weights: await weights.watchForPet(petId).first,
        from: DateTime(2026, 8, 1),
        to: now,
      ),
      l: zh,
      unit: WeightUnit.kg,
      fontData: font,
      now: now,
    );
    expect(utf8.decode(bytes.sublist(0, 5), allowMalformed: true), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  test('widget texts: next reminder, overdue, empty', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await PetRepository(db).create(
      const PetsCompanion(name: Value('Mochi'), species: Value(Species.dog)),
    );
    final now = DateTime(2026, 11, 9, 12);
    final reminders = ReminderRepository(db);
    await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.vaccine,
        startDate: DateTime(2026, 11, 20),
        times: const [540],
        unit: RepeatUnit.year,
      ),
      now: now,
    );
    var texts = nextReminderTexts(await reminders.watchSchedulable().first, now, en);
    expect(texts.title, 'Mochi: Vaccine');
    expect(texts.subtitle, contains('Nov 20'));

    await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.medication,
        startDate: DateTime(2026, 11, 1),
        times: const [540],
        unit: RepeatUnit.none,
      ),
      now: now,
    );
    texts = nextReminderTexts(await reminders.watchSchedulable().first, now, en);
    expect(texts.title, 'Mochi: Medication');
    expect(texts.subtitle, startsWith('Overdue'));

    expect(nextReminderTexts(const [], now, zh).subtitle, '沒有即將到來的提醒');
  });

  group('billing', () {
    late ProviderContainer container;
    late FakeBillingGateway billing;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      billing = FakeBillingGateway();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          billingGatewayProvider.overrideWithValue(billing),
        ],
      );
    });
    tearDown(() => container.dispose());

    test('purchase unlocks Pro and is remembered', () async {
      container.read(billingControllerProvider);
      expect(container.read(isProProvider), isFalse);
      await billing.buy(ProProduct.yearly);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(isProProvider), isTrue);
      expect(
        container.read(sharedPreferencesProvider).getBool('pro_owned'),
        isTrue,
      );
    });

    test('refresh follows the store, but keeps cache when offline', () async {
      final controller = container.read(billingControllerProvider);
      billing.owned = {ProProduct.lifetime};
      expect(await controller.refresh(), isTrue);
      expect(container.read(isProProvider), isTrue);

      billing.owned = null; // offline
      expect(await controller.refresh(), isFalse);
      expect(container.read(isProProvider), isTrue);

      billing.owned = const {}; // subscription expired / refunded
      expect(await controller.refresh(), isTrue);
      expect(container.read(isProProvider), isFalse);
    });
  });
}
