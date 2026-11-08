import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pawdian/core/database/app_database.dart';
import 'package:pawdian/core/domain/enums.dart';
import 'package:pawdian/features/pets/data/pet_repository.dart';
import 'package:pawdian/features/reminders/data/reminder_repository.dart';
import 'package:pawdian/features/reminders/domain/notification_planner.dart';
import 'package:pawdian/l10n/app_localizations.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late PetRepository pets;
  late ReminderRepository reminders;

  setUp(() {
    db = memoryDatabase();
    pets = PetRepository(db);
    reminders = ReminderRepository(db);
  });
  tearDown(() => db.close());

  Future<String> addPet([String name = 'Mochi']) => pets.create(
    PetsCompanion(name: Value(name), species: const Value(Species.dog)),
  );

  test('completing a monthly reminder writes a record and re-anchors', () async {
    final petId = await addPet();
    final ruleId = await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.heartworm,
        startDate: DateTime(2026, 11, 1),
        times: const [540],
        unit: RepeatUnit.month,
      ),
      now: DateTime(2026, 10, 30),
    );
    expect((await reminders.get(ruleId))!.nextDueAt, DateTime(2026, 11, 1, 9));

    final ok = await reminders.complete(ruleId, now: DateTime(2026, 11, 3, 18));
    expect(ok, isTrue);
    final rule = (await reminders.get(ruleId))!;
    expect(rule.nextDueAt, DateTime(2026, 12, 3, 9));

    final records = await db.select(db.careRecords).get();
    expect(records, hasLength(1));
    expect(records.single.type, RecordType.heartworm);
    expect(records.single.sourceReminderId, ruleId);
  });

  test('schedulable excludes archived pets, paused and finished rules', () async {
    final active = await addPet('A');
    final archived = await addPet('B');
    await pets.setArchived(archived, true);
    final draft = ReminderDraft(
      type: ReminderType.vaccine,
      startDate: DateTime(2027, 1, 1),
      times: const [540],
      unit: RepeatUnit.year,
    );
    await reminders.create(active, draft);
    await reminders.create(archived, draft);
    final paused = await reminders.create(active, draft);
    await reminders.updateFromDraft(
      paused,
      ReminderDraft(
        type: ReminderType.vaccine,
        startDate: DateTime(2027, 1, 1),
        times: const [540],
        unit: RepeatUnit.year,
        isActive: false,
      ),
    );
    final once = await reminders.create(
      active,
      ReminderDraft(
        type: ReminderType.checkup,
        startDate: DateTime(2027, 1, 1),
        times: const [540],
        unit: RepeatUnit.none,
      ),
    );
    await reminders.complete(once);

    final items = await reminders.watchSchedulable().first;
    expect(items, hasLength(1));
    expect(items.single.pet.name, 'A');
  });

  test('deleting a pet hides it and its reminders', () async {
    final petId = await addPet();
    await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.vaccine,
        startDate: DateTime(2027, 1, 1),
        times: const [540],
        unit: RepeatUnit.year,
      ),
    );
    await pets.softDelete(petId);
    expect(await pets.watchAll().first, isEmpty);
    expect(await reminders.watchSchedulable().first, isEmpty);
    expect(await pets.countActive(), 0);
  });

  test('planner: occurrences, early notice, snooze, cap', () async {
    final petId = await addPet();
    final now = DateTime(2026, 11, 8, 12);
    final daily = await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.medication,
        startDate: DateTime(2026, 11, 8),
        times: const [480, 1200],
        unit: RepeatUnit.day,
      ),
      now: now,
    );
    await reminders.create(
      petId,
      ReminderDraft(
        type: ReminderType.vaccine,
        startDate: DateTime(2026, 11, 20),
        times: const [540],
        unit: RepeatUnit.year,
        advanceNoticeDays: 7,
      ),
      now: now,
    );
    await reminders.snooze(daily, now.add(const Duration(hours: 1)));

    final l = lookupAppLocalizations(const Locale('en'));
    final items = await reminders.watchSchedulable().first;
    final planned = planNotifications(items, now, l);

    final med = planned.where((p) => p.ruleId == daily).toList();
    // Due 08:00 today is past; next 10 doses start tonight, plus the snooze.
    expect(med.first.at, DateTime(2026, 11, 8, 13));
    expect(med.first.body, l.notifBodySnoozed);
    expect(med.where((p) => p.body == l.notifBodyDue), hasLength(10));
    expect(
      med.where((p) => p.body == l.notifBodyDue).first.at,
      DateTime(2026, 11, 8, 20),
    );

    final vaccine = planned.where((p) => p.ruleId != daily).toList();
    expect(vaccine.map((p) => p.at), [
      DateTime(2026, 11, 13, 9),
      DateTime(2026, 11, 20, 9),
    ]);
    expect(vaccine.first.body, l.notifBodyAdvance(7));
    expect(vaccine.first.title, 'Mochi: Vaccine');

    expect(planNotifications(items, now, l, maxTotal: 5), hasLength(5));
  });
}
