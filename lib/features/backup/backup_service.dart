import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_database.dart';
import '../../core/settings/app_language.dart';

/// Folders inside the documents directory that hold user files.
const kPhotoDirName = 'pet_photos';
const kAttachmentDirName = 'attachments';
const _userDirs = [kPhotoDirName, kAttachmentDirName];

const kBackupExtension = 'pawdian';
const _manifestName = 'manifest.json';
const _dbEntryName = 'database.sqlite';
const _formatVersion = 1;

class BackupException implements Exception {
  const BackupException(this.reason);

  final BackupFailure reason;
}

enum BackupFailure { invalid, tooNew }

/// Creates and restores `.pawdian` files: a zip with a manifest, a snapshot
/// of the database and the photo folders.
class BackupService {
  BackupService({required this.documentsDir, required this.tempDir});

  final Directory documentsDir;
  final Directory tempDir;

  File get databaseFile => File(p.join(documentsDir.path, kDatabaseFileName));

  /// Writes a backup of [db] plus photos and returns the file.
  Future<File> createBackup(AppDatabase db, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final work = await tempDir.createTemp('backup');
    try {
      // VACUUM INTO gives a consistent single-file copy even while open.
      final snapshot = File(p.join(work.path, _dbEntryName));
      await db.customStatement('VACUUM INTO ?', [snapshot.path]);

      final archive = Archive()
        ..addFile(
          ArchiveFile.string(
            _manifestName,
            jsonEncode({
              'app': 'pawdian',
              'format': _formatVersion,
              'schemaVersion': db.schemaVersion,
              'createdAt': t.toUtc().toIso8601String(),
            }),
          ),
        )
        ..addFile(
          ArchiveFile.bytes(_dbEntryName, await snapshot.readAsBytes()),
        );
      for (final dirName in _userDirs) {
        final dir = Directory(p.join(documentsDir.path, dirName));
        if (!await dir.exists()) continue;
        await for (final entity in dir.list()) {
          if (entity is File) {
            archive.addFile(
              ArchiveFile.bytes(
                '$dirName/${p.basename(entity.path)}',
                await entity.readAsBytes(),
              ),
            );
          }
        }
      }
      final stamp =
          '${t.year}${_two(t.month)}${_two(t.day)}-${_two(t.hour)}${_two(t.minute)}';
      final out = File(
        p.join(tempDir.path, 'Pawdian-backup-$stamp.$kBackupExtension'),
      );
      await out.writeAsBytes(ZipEncoder().encode(archive));
      return out;
    } finally {
      await work.delete(recursive: true);
    }
  }

  /// Checks [backup] and returns its decoded archive, or throws.
  Future<Archive> readBackup(File backup, {required int currentSchema}) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await backup.readAsBytes());
    } catch (_) {
      throw const BackupException(BackupFailure.invalid);
    }
    final manifestFile = archive.findFile(_manifestName);
    final dbFile = archive.findFile(_dbEntryName);
    if (manifestFile == null || dbFile == null) {
      throw const BackupException(BackupFailure.invalid);
    }
    final Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupException(BackupFailure.invalid);
    }
    if (manifest['app'] != 'pawdian') {
      throw const BackupException(BackupFailure.invalid);
    }
    final schema = manifest['schemaVersion'];
    final format = manifest['format'];
    if (schema is! int || format is! int) {
      throw const BackupException(BackupFailure.invalid);
    }
    if (schema > currentSchema || format > _formatVersion) {
      throw const BackupException(BackupFailure.tooNew);
    }
    return archive;
  }

  /// Replaces the database file and photo folders with [archive]'s content.
  /// The caller must close the open database first and reopen it after.
  Future<void> applyBackup(Archive archive) async {
    await databaseFile.parent.create(recursive: true);
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File('${databaseFile.path}$suffix');
      if (await f.exists()) await f.delete();
    }
    await databaseFile.writeAsBytes(archive.findFile(_dbEntryName)!.content);

    for (final dirName in _userDirs) {
      final dir = Directory(p.join(documentsDir.path, dirName));
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final parts = entry.name.split('/');
      // Only "<known dir>/<file>"; ignore anything else (no path traversal).
      if (parts.length != 2 || !_userDirs.contains(parts[0])) continue;
      final name = p.basename(parts[1]);
      if (name.isEmpty || name.startsWith('.')) continue;
      await File(
        p.join(documentsDir.path, parts[0], name),
      ).writeAsBytes(entry.content);
    }
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  return BackupService(
    documentsDir: await getApplicationDocumentsDirectory(),
    tempDir: await getTemporaryDirectory(),
  );
});

/// Last time the user created a backup file.
final lastBackupProvider = NotifierProvider<LastBackup, DateTime?>(
  LastBackup.new,
);

class LastBackup extends Notifier<DateTime?> {
  static const _key = 'last_backup_at';

  @override
  DateTime? build() {
    final ms = ref.read(sharedPreferencesProvider).getInt(_key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markNow() async {
    final now = DateTime.now();
    state = now;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(_key, now.millisecondsSinceEpoch);
  }
}
