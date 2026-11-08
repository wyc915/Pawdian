import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';

const _uuid = Uuid();

/// Everything the user can set on a care record.
class RecordDraft {
  const RecordDraft({
    required this.type,
    required this.occurredAt,
    this.title = '',
    this.notes = '',
    this.severity,
    this.vetClinic = '',
    this.diagnosis = '',
    this.cost,
  });

  final RecordType type;
  final DateTime occurredAt;
  final String title;
  final String notes;
  final Severity? severity;
  final String vetClinic;
  final String diagnosis;
  final double? cost;

  CareRecordsCompanion toCompanion(DateTime now) => CareRecordsCompanion(
    type: Value(type),
    occurredAt: Value(occurredAt),
    title: Value(title.trim()),
    notes: Value(notes.trim()),
    severity: Value(type.hasSeverity ? severity : null),
    vetClinic: Value(type == RecordType.vetVisit ? vetClinic.trim() : ''),
    diagnosis: Value(type == RecordType.vetVisit ? diagnosis.trim() : ''),
    cost: Value(type == RecordType.vetVisit ? cost : null),
    updatedAt: Value(now),
  );
}

class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$CareRecordsTable, CareRecord> _forPet(String petId) =>
      _db.select(_db.careRecords)
        ..where((r) => r.petId.equals(petId) & r.deletedAt.isNull())
        ..orderBy([(r) => OrderingTerm.desc(r.occurredAt)]);

  Stream<List<CareRecord>> watchRecent(String petId, {int limit = 5}) =>
      (_forPet(petId)..limit(limit)).watch();

  Stream<List<CareRecord>> watchAll(String petId) => _forPet(petId).watch();

  Future<CareRecord?> get(String id) => (_db.select(
    _db.careRecords,
  )..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();

  Future<String> create(String petId, RecordDraft draft, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.careRecords)
        .insert(
          draft.toCompanion(t).copyWith(
            id: Value(id),
            petId: Value(petId),
            createdAt: Value(t),
          ),
        );
    return id;
  }

  /// One-tap log "now" from the quick-log buttons.
  Future<String> quickLog(String petId, RecordType type, {DateTime? now}) {
    final t = now ?? DateTime.now();
    return create(petId, RecordDraft(type: type, occurredAt: t), now: t);
  }

  Future<void> update(String id, RecordDraft draft) =>
      (_db.update(_db.careRecords)..where((r) => r.id.equals(id))).write(
        draft.toCompanion(DateTime.now()),
      );

  Future<void> softDelete(String id) {
    final now = DateTime.now();
    return (_db.update(_db.careRecords)..where((r) => r.id.equals(id))).write(
      CareRecordsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(appDatabaseProvider)),
);

final recentRecordsProvider = StreamProvider.family<List<CareRecord>, String>(
  (ref, petId) => ref.watch(recordRepositoryProvider).watchRecent(petId),
);

final allRecordsProvider = StreamProvider.family<List<CareRecord>, String>(
  (ref, petId) => ref.watch(recordRepositoryProvider).watchAll(petId),
);
