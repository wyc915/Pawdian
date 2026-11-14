import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'photo_store.dart';

/// Removes photo files that no live pet or record uses any more: photos of
/// deleted pets, attachments of deleted records, and files left over after
/// restoring an older backup.
///
/// Files younger than [minAge] are kept, because a photo is copied into the
/// folder a moment before its database row is written.
class FileCleanup {
  FileCleanup(this._db);

  final AppDatabase _db;

  static const minAge = Duration(hours: 1);

  /// Returns how many files were deleted.
  Future<int> run({
    required PhotoStore photos,
    required PhotoStore attachments,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();

    final livePhotos =
        await (_db.selectOnly(_db.pets)
              ..addColumns([_db.pets.photoFile])
              ..where(
                _db.pets.deletedAt.isNull() & _db.pets.photoFile.isNotNull(),
              ))
            .map((r) => r.read(_db.pets.photoFile)!)
            .get();

    final a = _db.attachments;
    final r = _db.careRecords;
    final p = _db.pets;
    final liveAttachments =
        await (_db.selectOnly(a).join([
                innerJoin(r, r.id.equalsExp(a.recordId)),
                innerJoin(p, p.id.equalsExp(r.petId)),
              ])
              ..addColumns([a.fileName])
              ..where(
                a.deletedAt.isNull() &
                    r.deletedAt.isNull() &
                    p.deletedAt.isNull(),
              ))
            .map((row) => row.read(a.fileName)!)
            .get();

    return await _sweep(photos.directory, livePhotos.toSet(), t) +
        await _sweep(attachments.directory, liveAttachments.toSet(), t);
  }

  Future<int> _sweep(Directory dir, Set<String> keep, DateTime now) async {
    if (!await dir.exists()) return 0;
    var deleted = 0;
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (keep.contains(name)) continue;
      try {
        final modified = await entity.lastModified();
        if (now.difference(modified) < minAge) continue;
        await entity.delete();
        deleted++;
      } catch (e) {
        debugPrint('Could not remove unused file $name: $e');
      }
    }
    return deleted;
  }
}

/// Runs the cleanup once, in the background after start-up.
Future<void> cleanUpUnusedFiles(Ref ref) async {
  try {
    await FileCleanup(ref.read(appDatabaseProvider)).run(
      photos: await ref.read(photoStoreProvider.future) as PhotoStore,
      attachments: await ref.read(attachmentStoreProvider.future) as PhotoStore,
    );
  } catch (e) {
    debugPrint('File cleanup failed: $e');
  }
}

final fileCleanupProvider = FutureProvider<void>(cleanUpUnusedFiles);
