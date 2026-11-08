import 'dart:ui';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/records/data/record_repository.dart';
import 'package:pawdian/features/records/domain/timeline.dart';
import 'package:pawdian/features/weight/data/weight_repository.dart';
import 'package:pawdian/l10n/app_localizations.dart';
import 'package:pawdian/shared/units.dart';

import 'helpers.dart';

void main() {
  group('units', () {
    test('formats with up to two decimals', () {
      expect(formatWeight(4250, WeightUnit.kg), '4.25 kg');
      expect(formatWeight(4000, WeightUnit.kg), '4 kg');
      expect(formatWeight(4536, WeightUnit.lb), '10 lb');
    });
    test('parses input, accepting a comma', () {
      expect(parseWeightToGrams('4,2', WeightUnit.kg), 4200);
      expect(parseWeightToGrams('10', WeightUnit.lb), 4536);
      expect(parseWeightToGrams('', WeightUnit.kg), isNull);
      expect(parseWeightToGrams('-1', WeightUnit.kg), isNull);
      expect(parseWeightToGrams('abc', WeightUnit.kg), isNull);
      expect(parseWeightToGrams('500', WeightUnit.kg), isNull);
    });
  });

  group('repositories', () {
    late AppDatabase db;
    late String petId;

    setUp(() async {
      db = memoryDatabase();
      petId = await PetRepository(db).create(
        const PetsCompanion(name: Value('Mochi'), species: Value(Species.cat)),
      );
    });
    tearDown(() => db.close());

    test('quick log and vet-only fields', () async {
      final records = RecordRepository(db);
      await records.quickLog(petId, RecordType.vomit);
      final vetId = await records.create(
        petId,
        RecordDraft(
          type: RecordType.vetVisit,
          occurredAt: DateTime(2026, 11, 8, 10),
          vetClinic: 'Happy Vet',
          diagnosis: 'Hairball',
          cost: 1200,
          severity: Severity.severe, // ignored: vet visits have no severity
        ),
      );
      final vet = (await records.get(vetId))!;
      expect(vet.severity, isNull);
      expect(vet.cost, 1200);

      // Switching type clears vet-only fields.
      await records.update(
        vetId,
        RecordDraft(
          type: RecordType.cough,
          occurredAt: vet.occurredAt,
          vetClinic: 'Happy Vet',
          severity: Severity.mild,
        ),
      );
      final cough = (await records.get(vetId))!;
      expect(cough.vetClinic, '');
      expect(cough.cost, isNull);
      expect(cough.severity, Severity.mild);

      expect(await records.watchAll(petId).first, hasLength(2));
      await records.softDelete(vetId);
      expect(await records.watchAll(petId).first, hasLength(1));
    });

    test('weights are ordered oldest first', () async {
      final weights = WeightRepository(db);
      await weights.add(petId, measuredAt: DateTime(2026, 11, 1), grams: 4300);
      await weights.add(petId, measuredAt: DateTime(2026, 10, 1), grams: 4100);
      final list = await weights.watchForPet(petId).first;
      expect(list.map((w) => w.grams), [4100, 4300]);
    });

    test('timeline merges, filters and searches', () async {
      final records = RecordRepository(db);
      final weights = WeightRepository(db);
      await records.create(
        petId,
        RecordDraft(
          type: RecordType.vomit,
          occurredAt: DateTime(2026, 11, 8, 9),
          notes: 'after breakfast',
        ),
      );
      await records.create(
        petId,
        RecordDraft(type: RecordType.feeding, occurredAt: DateTime(2026, 11, 8, 8)),
      );
      await weights.add(petId, measuredAt: DateTime(2026, 11, 8, 12), grams: 4200);

      final l = lookupAppLocalizations(const Locale('en'));
      final r = await records.watchAll(petId).first;
      final w = await weights.watchForPet(petId).first;

      final all = buildTimeline(records: r, weights: w, l: l);
      expect(all.map((i) => i.at.hour), [12, 9, 8]);

      final symptoms = buildTimeline(
        records: r,
        weights: w,
        l: l,
        category: RecordCategory.symptom,
      );
      expect(symptoms, hasLength(1));

      final weightOnly = buildTimeline(
        records: r,
        weights: w,
        l: l,
        category: RecordCategory.weight,
      );
      expect(weightOnly.single, isA<WeightItem>());

      final search = buildTimeline(records: r, weights: w, l: l, query: 'BREAK');
      expect(search, hasLength(1));
      final byLabel = buildTimeline(records: r, weights: w, l: l, query: 'feed');
      expect(byLabel, hasLength(1));
    });
  });

  test('upgrades a v1 database without losing data', () async {
    final db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute('''
CREATE TABLE pets (id TEXT NOT NULL PRIMARY KEY, created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL, deleted_at INTEGER NULL, owner_id TEXT NULL,
  name TEXT NOT NULL, species TEXT NOT NULL, breed TEXT NOT NULL DEFAULT '',
  sex TEXT NOT NULL DEFAULT 'unknown', neutered INTEGER NULL,
  birth_date INTEGER NULL, birth_date_estimated INTEGER NOT NULL DEFAULT 0,
  microchip_id TEXT NOT NULL DEFAULT '', photo_file TEXT NULL,
  color TEXT NOT NULL DEFAULT '', notes TEXT NOT NULL DEFAULT '',
  vet_name TEXT NOT NULL DEFAULT '', vet_phone TEXT NOT NULL DEFAULT '',
  is_archived INTEGER NOT NULL DEFAULT 0);''');
            raw.execute('''
CREATE TABLE reminder_rules (id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL, owner_id TEXT NULL,
  pet_id TEXT NOT NULL REFERENCES pets (id), type TEXT NOT NULL,
  title TEXT NOT NULL DEFAULT '', start_date INTEGER NOT NULL,
  repeat_unit TEXT NOT NULL, repeat_interval INTEGER NOT NULL DEFAULT 1,
  times_of_day TEXT NOT NULL DEFAULT '09:00',
  advance_notice_days INTEGER NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1, next_due_at INTEGER NULL,
  snoozed_until INTEGER NULL, notes TEXT NOT NULL DEFAULT '');''');
            raw.execute('''
CREATE TABLE care_records (id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL, owner_id TEXT NULL,
  pet_id TEXT NOT NULL REFERENCES pets (id), type TEXT NOT NULL,
  occurred_at INTEGER NOT NULL, title TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '', source_reminder_id TEXT NULL);''');
            raw.execute(
              "INSERT INTO pets (id, created_at, updated_at, name, species) "
              "VALUES ('p1', 0, 0, 'Old', 'dog')",
            );
            raw.execute(
              "INSERT INTO care_records (id, created_at, updated_at, pet_id, "
              "type, occurred_at) VALUES ('r1', 0, 0, 'p1', 'vaccine', 0)",
            );
            raw.execute('PRAGMA user_version = 1');
          },
        ),
        closeStreamsSynchronously: true,
      ),
    );
    addTearDown(db.close);

    final records = await RecordRepository(db).watchAll('p1').first;
    expect(records.single.type, RecordType.vaccine);
    expect(records.single.severity, isNull);
    expect(records.single.vetClinic, '');

    await WeightRepository(db).add('p1', measuredAt: DateTime(2026), grams: 1);
    expect(await WeightRepository(db).watchForPet('p1').first, hasLength(1));
  });
}
