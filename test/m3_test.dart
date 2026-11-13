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
import 'package:pawdian/core/storage/photo_store.dart';
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
import 'package:sqlite3/sqlite3.dart' show sqlite3;

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
      await File(p.join(docsA.path, kPhotoDirName, 'cat.jpg'))
          .writeAsBytes([1, 2, 3]);

      final db = memoryDatabase();
      final petId = await PetRepository(db).create(
        const PetsCompanion(name: Value('Mochi'), species: Value(Species.cat)),
      );
      final recordId = await RecordRepository(db)
          .quickLog(petId, RecordType.vomit);
      await AttachmentRepository(db).add(recordId, 'lab.jpg');
      await WeightRepository(db)
          .add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4200);

      final serviceA = BackupService(documentsDir: docsA, tempDir: tmp);
      final file = await serviceA.createBackup(
        db,
        now: DateTime(2026, 11, 9, 8, 5),
      );
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
      expect(
        (await PetRepository(restored).watchAll().first).single.name,
        'Mochi',
      );
      expect(
        await RecordRepository(restored).watchAll(petId).first,
        hasLength(1),
      );
      expect(
        await AttachmentRepository(restored).forRecord(recordId),
        hasLength(1),
      );
      expect(
        await WeightRepository(restored).watchForPet(petId).first,
        hasLength(1),
      );
    });

    test('rejects other files and newer backups', () async {
      final service = BackupService(documentsDir: tmp, tempDir: tmp);
      final notZip = await File(p.join(tmp.path, 'x.pawdian'))
          .writeAsString('hi');
      await expectLater(
        service.readBackup(notZip, currentSchema: 3),
        throwsA(
          isA<BackupException>().having(
            (e) => e.reason,
            'reason',
            BackupFailure.invalid,
          ),
        ),
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
        throwsA(
          isA<BackupException>().having(
            (e) => e.reason,
            'reason',
            BackupFailure.invalid,
          ),
        ),
      );
      await expectLater(
        service.readBackup(
          await zipWith({'app': 'pawdian', 'format': 1, 'schemaVersion': 9}),
          currentSchema: 3,
        ),
        throwsA(
          isA<BackupException>().having(
            (e) => e.reason,
            'reason',
            BackupFailure.tooNew,
          ),
        ),
      );
    });

    /// A real database file made by the app, for building test archives.
    Future<Uint8List> validDatabaseBytes() async {
      final db = memoryDatabase();
      await PetRepository(db).create(
        const PetsCompanion(name: Value('Mochi'), species: Value(Species.cat)),
      );
      final out = p.join(
        tmp.path,
        'valid-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      await db.customStatement('VACUUM INTO ?', [out]);
      await db.close();
      return File(out).readAsBytes();
    }

    Future<File> zipFile(String name, List<ArchiveFile> files) async {
      final archive = Archive();
      for (final f in files) {
        archive.addFile(f);
      }
      return File(p.join(tmp.path, name))
          .writeAsBytes(ZipEncoder().encode(archive));
    }

    ArchiveFile manifest() => ArchiveFile.string(
      'manifest.json',
      jsonEncode({'app': 'pawdian', 'format': 1, 'schemaVersion': 3}),
    );

    test('ignores entries outside the photo folders', () async {
      final docs = await Directory(p.join(tmp.path, 'docs')).create();
      final service = BackupService(documentsDir: docs, tempDir: tmp);
      final file = await zipFile('evil.pawdian', [
        manifest(),
        ArchiveFile.bytes('database.sqlite', await validDatabaseBytes()),
        ArchiveFile.bytes('../evil.txt', Uint8List(1)),
        ArchiveFile.bytes('pet_photos/../../evil2.txt', Uint8List(1)),
        ArchiveFile.bytes('pet_photos/..', Uint8List(1)),
        ArchiveFile.bytes('attachments/ok.jpg', Uint8List(1)),
      ]);
      await service.applyBackup(
        await service.readBackup(file, currentSchema: 3),
      );
      expect(File(p.join(tmp.path, 'evil.txt')).existsSync(), isFalse);
      expect(File(p.join(tmp.path, 'evil2.txt')).existsSync(), isFalse);
      expect(
        File(p.join(docs.path, 'attachments', 'ok.jpg')).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(docs.path, '.restore-staging')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(docs.path, '.restore-rollback')).existsSync(),
        isFalse,
      );
    });

    test(
      'rejects broken or foreign databases and keeps current data',
      () async {
        final docs = await Directory(p.join(tmp.path, 'docs')).create();
        await File(p.join(docs.path, kDatabaseFileName))
            .writeAsString('current');
        final service = BackupService(documentsDir: docs, tempDir: tmp);

        Future<void> expectInvalid(String name, Uint8List db) async {
          final file = await zipFile(name, [
            manifest(),
            ArchiveFile.bytes('database.sqlite', db),
          ]);
          await expectLater(
            service.readBackup(file, currentSchema: 3),
            throwsA(
              isA<BackupException>().having(
                (e) => e.reason,
                'reason',
                BackupFailure.invalid,
              ),
            ),
          );
        }

        // Not a database at all.
        await expectInvalid(
          'garbage.pawdian',
          Uint8List.fromList(List.filled(4096, 7)),
        );

        // A database with a trigger that Pawdian never creates.
        final valid = await validDatabaseBytes();
        final withTrigger = File(p.join(tmp.path, 'trigger.sqlite'));
        await withTrigger.writeAsBytes(valid);
        final raw = sqlite3.open(withTrigger.path);
        raw.execute(
          'CREATE TRIGGER wipe AFTER INSERT ON care_records BEGIN DELETE FROM pets; END',
        );
        raw.close();
        await expectInvalid('trigger.pawdian', await withTrigger.readAsBytes());

        // A database from some other app.
        final other = File(p.join(tmp.path, 'other.sqlite'));
        final otherDb = sqlite3.open(other.path);
        otherDb.execute(
          'CREATE TABLE notes (id INTEGER); PRAGMA user_version = 1;',
        );
        otherDb.close();
        await expectInvalid('other.pawdian', await other.readAsBytes());

        // A database from a newer app version.
        final newer = File(p.join(tmp.path, 'newer.sqlite'));
        await newer.writeAsBytes(valid);
        final newerDb = sqlite3.open(newer.path);
        newerDb.userVersion = 9;
        newerDb.close();
        final newerFile = await zipFile('newer.pawdian', [
          manifest(),
          ArchiveFile.bytes('database.sqlite', await newer.readAsBytes()),
        ]);
        await expectLater(
          service.readBackup(newerFile, currentSchema: 3),
          throwsA(
            isA<BackupException>().having(
              (e) => e.reason,
              'reason',
              BackupFailure.tooNew,
            ),
          ),
        );

        // Nothing was touched.
        expect(
          await File(p.join(docs.path, kDatabaseFileName)).readAsString(),
          'current',
        );
      },
    );

    test('rejects oversized entries (zip bomb)', () async {
      final service = BackupService(documentsDir: tmp, tempDir: tmp);
      // 300 MB of zeros compresses to a few hundred KB.
      final bomb = ArchiveFile.bytes(
        'pet_photos/big.jpg',
        Uint8List(300 * 1024 * 1024),
      );
      final file = await zipFile('bomb.pawdian', [
        manifest(),
        ArchiveFile.bytes('database.sqlite', await validDatabaseBytes()),
        bomb,
      ]);
      expect(await file.length(), lessThan(10 * 1024 * 1024));
      await expectLater(
        service.readBackup(file, currentSchema: 3),
        throwsA(isA<BackupException>()),
      );
    });

    test('photo store never touches files outside its folder', () async {
      final folder = await Directory(p.join(tmp.path, 'photos')).create();
      final outside = await File(p.join(tmp.path, 'secret.txt'))
          .writeAsString('keep');
      final store = PhotoStore(folder);
      for (final bad in [
        '../secret.txt',
        '..',
        '.',
        '',
        'a/b.jpg',
        r'..\secret.txt',
        'x\u0000.jpg',
      ]) {
        expect(PhotoStore.isSafeName(bad), isFalse, reason: bad);
        expect(store.fileFor(bad), isNull, reason: bad);
        await store.delete(bad);
      }
      expect(outside.existsSync(), isTrue);
      expect(PhotoStore.isSafeName('3f1c-uuid.jpg'), isTrue);
    });

    test('old backup files are removed from the temp folder', () async {
      final docs = await Directory(p.join(tmp.path, 'docs')).create();
      final service = BackupService(documentsDir: docs, tempDir: tmp);
      final db = memoryDatabase();
      addTearDown(db.close);
      final first = await service.createBackup(db, now: DateTime(2026, 1, 1));
      final second = await service.createBackup(db, now: DateTime(2026, 1, 2));
      expect(first.existsSync(), isFalse);
      expect(second.existsSync(), isTrue);
    });
  });

  test('CSV: formula-like text is neutralised', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final petId = await PetRepository(db).create(
      const PetsCompanion(
        name: Value('=cmd|calc'),
        species: Value(Species.dog),
      ),
    );
    await RecordRepository(db).create(
      petId,
      RecordDraft(
        type: RecordType.vomit,
        occurredAt: DateTime(2026, 11, 2, 9),
        notes: '=HYPERLINK("http://x","y")',
      ),
    );
    final csv = buildCsv(
      pets: await PetRepository(db).watchAll().first,
      records: await RecordRepository(db).watchAll(petId).first,
      weights: const [],
      l: en,
      unit: WeightUnit.kg,
    );
    final row = csv.substring(1).trim().split('\r\n')[1];
    expect(row, startsWith("'=cmd|calc,"));
    expect(row, contains('"\'=HYPERLINK(""http://x"",""y"")"'));
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
    await WeightRepository(db)
        .add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4200);
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
      RecordDraft(
        type: RecordType.vomit,
        occurredAt: now,
        severity: Severity.mild,
      ),
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
    expect(symptoms.map((r) => r.type).toSet(), {
      RecordType.vomit,
      RecordType.poop,
    });
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
    var texts = nextReminderTexts(
      await reminders.watchSchedulable().first,
      now,
      en,
    );
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
    texts = nextReminderTexts(
      await reminders.watchSchedulable().first,
      now,
      en,
    );
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
