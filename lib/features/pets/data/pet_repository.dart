import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

const _uuid = Uuid();

class PetRepository {
  PetRepository(this._db);

  final AppDatabase _db;

  /// Non-deleted pets: active first (oldest first), then archived.
  Stream<List<Pet>> watchAll() {
    final q = _db.select(_db.pets)
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([
        (p) => OrderingTerm.asc(p.isArchived),
        (p) => OrderingTerm.asc(p.createdAt),
      ]);
    return q.watch();
  }

  Stream<Pet?> watch(String id) => (_db.select(
    _db.pets,
  )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).watchSingleOrNull();

  Future<Pet?> get(String id) => (_db.select(
    _db.pets,
  )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();

  Future<int> countActive() async {
    final count = _db.pets.id.count();
    final q = _db.selectOnly(_db.pets)
      ..addColumns([count])
      ..where(_db.pets.deletedAt.isNull() & _db.pets.isArchived.equals(false));
    return (await q.getSingle()).read(count) ?? 0;
  }

  /// Inserts a pet and returns its new id. [data] must contain name/species.
  Future<String> create(PetsCompanion data) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db
        .into(_db.pets)
        .insert(
          data.copyWith(
            id: Value(id),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return id;
  }

  Future<void> update(String id, PetsCompanion data) =>
      (_db.update(_db.pets)..where((p) => p.id.equals(id))).write(
        data.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> setArchived(String id, bool archived) =>
      update(id, PetsCompanion(isArchived: Value(archived)));

  /// Soft-deletes the pet together with its reminders and records.
  Future<void> softDelete(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.pets)..where((p) => p.id.equals(id))).write(
        PetsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (_db.update(_db.reminderRules)..where((r) => r.petId.equals(id)))
          .write(
            ReminderRulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      await (_db.update(_db.careRecords)..where((r) => r.petId.equals(id)))
          .write(
            CareRecordsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    });
  }
}

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepository(ref.watch(appDatabaseProvider)),
);

final petsProvider = StreamProvider<List<Pet>>(
  (ref) => ref.watch(petRepositoryProvider).watchAll(),
);

final petProvider = StreamProvider.family<Pet?, String>(
  (ref, id) => ref.watch(petRepositoryProvider).watch(id),
);
