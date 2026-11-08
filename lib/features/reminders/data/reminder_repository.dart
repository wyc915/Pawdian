import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../domain/recurrence.dart';

const _uuid = Uuid();

class ReminderWithPet {
  const ReminderWithPet(this.rule, this.pet);

  final ReminderRule rule;
  final Pet pet;
}

/// Everything the user can set on a reminder.
class ReminderDraft {
  const ReminderDraft({
    required this.type,
    required this.startDate,
    required this.times,
    required this.unit,
    this.title = '',
    this.interval = 1,
    this.advanceNoticeDays = 0,
    this.notes = '',
    this.isActive = true,
  });

  final ReminderType type;
  final String title;
  final DateTime startDate;
  final List<MinuteOfDay> times;
  final RepeatUnit unit;
  final int interval;
  final int advanceNoticeDays;
  final String notes;
  final bool isActive;

  Recurrence get recurrence => Recurrence(
    startDate: startDate,
    times: times,
    unit: unit,
    interval: interval,
  );
}

Recurrence recurrenceOf(ReminderRule rule) => Recurrence(
  startDate: rule.startDate,
  times: parseTimesOfDay(rule.timesOfDay),
  unit: rule.repeatUnit,
  interval: rule.repeatInterval,
);

class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Stream<List<ReminderRule>> watchForPet(String petId) {
    final q = _db.select(_db.reminderRules)
      ..where((r) => r.petId.equals(petId) & r.deletedAt.isNull())
      ..orderBy([
        (r) => OrderingTerm(
          expression: r.nextDueAt,
          nulls: NullsOrder.last,
        ),
      ]);
    return q.watch();
  }

  /// Active reminders with a pending occurrence on active pets, soonest first.
  Stream<List<ReminderWithPet>> watchSchedulable() {
    final r = _db.reminderRules;
    final p = _db.pets;
    final q = _db.select(r).join([innerJoin(p, p.id.equalsExp(r.petId))])
      ..where(
        r.deletedAt.isNull() &
            r.isActive.equals(true) &
            r.nextDueAt.isNotNull() &
            p.deletedAt.isNull() &
            p.isArchived.equals(false),
      )
      ..orderBy([OrderingTerm.asc(r.nextDueAt)]);
    return q.watch().map(
      (rows) => [
        for (final row in rows) ReminderWithPet(row.readTable(r), row.readTable(p)),
      ],
    );
  }

  Future<ReminderRule?> get(String id) => (_db.select(
    _db.reminderRules,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();

  Stream<ReminderRule?> watch(String id) => (_db.select(
    _db.reminderRules,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).watchSingleOrNull();

  ReminderRulesCompanion _fromDraft(ReminderDraft d, DateTime now) =>
      ReminderRulesCompanion(
        type: Value(d.type),
        title: Value(d.title.trim()),
        startDate: Value(d.recurrence.startDate),
        repeatUnit: Value(d.unit),
        repeatInterval: Value(d.recurrence.interval),
        timesOfDay: Value(encodeTimesOfDay(d.recurrence.times)),
        advanceNoticeDays: Value(d.advanceNoticeDays),
        isActive: Value(d.isActive),
        nextDueAt: Value(initialNextDue(d.recurrence, now)),
        snoozedUntil: const Value(null),
        notes: Value(d.notes.trim()),
        updatedAt: Value(now),
      );

  Future<String> create(String petId, ReminderDraft draft, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.reminderRules)
        .insert(
          _fromDraft(draft, t).copyWith(
            id: Value(id),
            petId: Value(petId),
            createdAt: Value(t),
          ),
        );
    return id;
  }

  Future<void> createAll(String petId, List<ReminderDraft> drafts) async {
    await _db.transaction(() async {
      for (final d in drafts) {
        await create(petId, d);
      }
    });
  }

  Future<void> updateFromDraft(String id, ReminderDraft draft, {DateTime? now}) =>
      (_db.update(_db.reminderRules)..where((r) => r.id.equals(id))).write(
        _fromDraft(draft, now ?? DateTime.now()),
      );

  Future<void> softDelete(String id) {
    final now = DateTime.now();
    return (_db.update(_db.reminderRules)..where((r) => r.id.equals(id))).write(
      ReminderRulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  /// Marks the current occurrence done: writes a care record and moves the
  /// reminder to its next occurrence. Returns false if nothing was pending.
  Future<bool> complete(String id, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    return _db.transaction(() async {
      final rule = await get(id);
      final due = rule?.nextDueAt;
      if (rule == null || due == null) return false;
      final result = completeOccurrence(
        recurrence: recurrenceOf(rule),
        currentDue: due,
        now: t,
      );
      await _db
          .into(_db.careRecords)
          .insert(
            CareRecordsCompanion.insert(
              id: _uuid.v4(),
              createdAt: t,
              updatedAt: t,
              petId: rule.petId,
              type: RecordType.fromReminder(rule.type),
              occurredAt: t,
              title: Value(rule.title),
              sourceReminderId: Value(rule.id),
            ),
          );
      await (_db.update(_db.reminderRules)..where((r) => r.id.equals(id)))
          .write(
            ReminderRulesCompanion(
              startDate: Value(result.startDate),
              nextDueAt: Value(result.nextDueAt),
              snoozedUntil: const Value(null),
              updatedAt: Value(t),
            ),
          );
      return true;
    });
  }

  Future<void> snooze(String id, DateTime until) =>
      (_db.update(_db.reminderRules)..where((r) => r.id.equals(id))).write(
        ReminderRulesCompanion(
          snoozedUntil: Value(until),
          updatedAt: Value(DateTime.now()),
        ),
      );
}

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(appDatabaseProvider)),
);

final schedulableRemindersProvider = StreamProvider<List<ReminderWithPet>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchSchedulable(),
);

final petRemindersProvider = StreamProvider.family<List<ReminderRule>, String>(
  (ref, petId) => ref.watch(reminderRepositoryProvider).watchForPet(petId),
);

final reminderProvider = StreamProvider.family<ReminderRule?, String>(
  (ref, id) => ref.watch(reminderRepositoryProvider).watch(id),
);
