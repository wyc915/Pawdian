import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class RecordRepository {
  RecordRepository(this._db);

  final AppDatabase _db;

  Stream<List<CareRecord>> watchRecent(String petId, {int limit = 20}) {
    final q = _db.select(_db.careRecords)
      ..where((r) => r.petId.equals(petId) & r.deletedAt.isNull())
      ..orderBy([(r) => OrderingTerm.desc(r.occurredAt)])
      ..limit(limit);
    return q.watch();
  }
}

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(appDatabaseProvider)),
);

final recentRecordsProvider = StreamProvider.family<List<CareRecord>, String>(
  (ref, petId) => ref.watch(recordRepositoryProvider).watchRecent(petId),
);
