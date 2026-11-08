import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

const _uuid = Uuid();

class WeightRepository {
  WeightRepository(this._db);

  final AppDatabase _db;

  /// Oldest first, which is the order charts need.
  Stream<List<WeightEntry>> watchForPet(String petId) {
    final q = _db.select(_db.weightEntries)
      ..where((w) => w.petId.equals(petId) & w.deletedAt.isNull())
      ..orderBy([(w) => OrderingTerm.asc(w.measuredAt)]);
    return q.watch();
  }

  Future<String> add(
    String petId, {
    required DateTime measuredAt,
    required int grams,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.weightEntries)
        .insert(
          WeightEntriesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            petId: petId,
            measuredAt: measuredAt,
            grams: grams,
            notes: Value(notes.trim()),
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    required DateTime measuredAt,
    required int grams,
    String notes = '',
  }) => (_db.update(_db.weightEntries)..where((w) => w.id.equals(id))).write(
    WeightEntriesCompanion(
      measuredAt: Value(measuredAt),
      grams: Value(grams),
      notes: Value(notes.trim()),
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> softDelete(String id) {
    final now = DateTime.now();
    return (_db.update(_db.weightEntries)..where((w) => w.id.equals(id))).write(
      WeightEntriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

final weightRepositoryProvider = Provider<WeightRepository>(
  (ref) => WeightRepository(ref.watch(appDatabaseProvider)),
);

final petWeightsProvider = StreamProvider.family<List<WeightEntry>, String>(
  (ref, petId) => ref.watch(weightRepositoryProvider).watchForPet(petId),
);
