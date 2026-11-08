import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../pets/data/pet_repository.dart';
import '../records/data/record_repository.dart';
import '../reminders/data/reminder_repository.dart';
import '../weight/data/weight_repository.dart';

/// Debug-only sample data for store screenshots and manual testing.
Future<void> loadDemoData(
  AppDatabase db, {
  DateTime? now,
  bool chinese = false,
}) async {
  String tr(String en, String zh) => chinese ? zh : en;
  final t = now ?? DateTime.now();
  final today = DateTime(t.year, t.month, t.day);
  DateTime daysAgo(int d, [int hour = 9]) =>
      DateTime(today.year, today.month, today.day - d, hour);

  final pets = PetRepository(db);
  final reminders = ReminderRepository(db);
  final records = RecordRepository(db);
  final weights = WeightRepository(db);

  final mochi = await pets.create(
    PetsCompanion(
      name: Value(tr('Mochi', '麻糬')),
      species: const Value(Species.dog),
      breed: Value(tr('Shiba Inu', '柴犬')),
      sex: const Value(Sex.female),
      neutered: const Value(true),
      birthDate: Value(DateTime(t.year - 3, 3, 10)),
      microchipId: const Value('900123456789012'),
      vetName: Value(tr('Happy Paws Clinic', '快樂動物醫院')),
    ),
  );
  final kiki = await pets.create(
    PetsCompanion(
      name: const Value('Kiki'),
      species: const Value(Species.cat),
      breed: Value(tr('British Shorthair', '英國短毛貓')),
      sex: const Value(Sex.male),
      birthDate: Value(DateTime(t.year - 1, 6, 1)),
    ),
  );

  Future<void> reminder(
    String petId,
    ReminderType type,
    DateTime start,
    RepeatUnit unit, {
    String title = '',
    int interval = 1,
    List<int> times = const [540],
  }) => reminders.create(
    petId,
    ReminderDraft(
      type: type,
      title: title,
      startDate: start,
      times: times,
      unit: unit,
      interval: interval,
      advanceNoticeDays: 1,
    ),
    now: t,
  );

  await reminder(mochi, ReminderType.heartworm, today, RepeatUnit.month);
  await reminder(
    mochi,
    ReminderType.medication,
    today,
    RepeatUnit.day,
    times: const [480, 1200],
  );
  await reminder(
    mochi,
    ReminderType.vaccine,
    today.add(const Duration(days: 3)),
    RepeatUnit.year,
    title: 'tpl:rabies',
  );
  await reminder(
    mochi,
    ReminderType.dewormExternal,
    today.add(const Duration(days: 5)),
    RepeatUnit.month,
  );
  await reminder(
    kiki,
    ReminderType.vaccine,
    today.add(const Duration(days: 2)),
    RepeatUnit.year,
    title: 'tpl:coreCat',
  );
  await reminder(
    kiki,
    ReminderType.dewormInternal,
    today.add(const Duration(days: 20)),
    RepeatUnit.month,
    interval: 3,
  );

  for (var i = 0; i < 8; i++) {
    await weights.add(
      mochi,
      measuredAt: daysAgo(170 - i * 24),
      grams: 8900 + (i * 70) + (i.isEven ? 0 : 40),
    );
    await weights.add(
      kiki,
      measuredAt: daysAgo(160 - i * 22),
      grams: 3600 + i * 90,
    );
  }

  await records.create(
    mochi,
    RecordDraft(type: RecordType.feeding, occurredAt: daysAgo(0, 8)),
  );
  await records.create(
    mochi,
    RecordDraft(type: RecordType.poop, occurredAt: daysAgo(0, 7)),
  );
  await records.create(
    mochi,
    RecordDraft(
      type: RecordType.vomit,
      occurredAt: daysAgo(1, 21),
      severity: Severity.mild,
      notes: tr('After eating grass', '吃草後吐'),
    ),
  );
  await records.create(
    mochi,
    RecordDraft(
      type: RecordType.vetVisit,
      occurredAt: daysAgo(12, 15),
      vetClinic: tr('Happy Paws Clinic', '快樂動物醫院'),
      diagnosis: tr('Mild gastritis, bland diet for 3 days', '輕微腸胃炎，清淡飲食 3 天'),
      cost: 1200,
    ),
  );
  await records.create(
    mochi,
    RecordDraft(
      type: RecordType.vaccine,
      occurredAt: daysAgo(40, 10),
      title: 'tpl:coreDog',
    ),
  );
  await records.create(
    kiki,
    RecordDraft(type: RecordType.water, occurredAt: daysAgo(0, 10)),
  );
}
