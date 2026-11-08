import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

const _uuid = Uuid();

/// Free users may attach this many photos to one record.
const kFreeAttachmentsPerRecord = 1;

class AttachmentRepository {
  AttachmentRepository(this._db);

  final AppDatabase _db;

  Future<List<Attachment>> forRecord(String recordId) =>
      (_db.select(_db.attachments)
            ..where((a) => a.recordId.equals(recordId) & a.deletedAt.isNull())
            ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
          .get();

  Future<String> add(String recordId, String fileName) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _db
        .into(_db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            recordId: recordId,
            fileName: fileName,
          ),
        );
    return id;
  }

  Future<void> softDelete(String id) {
    final now = DateTime.now();
    return (_db.update(_db.attachments)..where((a) => a.id.equals(id))).write(
      AttachmentsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

final attachmentRepositoryProvider = Provider<AttachmentRepository>(
  (ref) => AttachmentRepository(ref.watch(appDatabaseProvider)),
);
