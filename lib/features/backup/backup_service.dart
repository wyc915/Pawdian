import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../core/database/app_database.dart';
import '../../core/settings/app_language.dart';
import '../../core/storage/photo_store.dart';

/// Folders inside the documents directory that hold user files.
const kPhotoDirName = 'pet_photos';
const kAttachmentDirName = 'attachments';
const _userDirs = [kPhotoDirName, kAttachmentDirName];

const kBackupExtension = 'pawdian';
const _backupPrefix = 'Pawdian-backup-';
const _manifestName = 'manifest.json';
const _dbEntryName = 'database.sqlite';
const _formatVersion = 1;

/// Limits for files being restored, so a damaged or hostile file cannot
/// exhaust the phone's memory or storage (zip bomb).
const kMaxBackupBytes = 1024 * 1024 * 1024; // 1 GB on disk
const kMaxEntryBytes = 256 * 1024 * 1024; // 256 MB per file once unpacked
const kMaxUnpackedBytes = 2 * 1024 * 1024 * 1024; // 2 GB in total
const kMaxEntries = 20000;

/// Tables a restored database may contain. Anything else (views, triggers,
/// unknown tables) means the file was not made by Pawdian.
const _allowedTables = {
  'pets',
  'reminder_rules',
  'care_records',
  'weight_entries',
  'attachments',
};
const _requiredTables = {'pets', 'reminder_rules', 'care_records'};

class BackupException implements Exception {
  const BackupException(this.reason);

  final BackupFailure reason;

  @override
  String toString() => 'BackupException($reason)';
}

enum BackupFailure { invalid, tooNew }

/// A backup that passed every check, ready to be applied. Call [discard]
/// if the user cancels.
class ValidatedBackup {
  ValidatedBackup._(this.archive, this._database);

  final Archive archive;

  /// Checked copy of the backup's database, in the temp folder.
  final File _database;

  Future<void> discard() async {
    try {
      await _database.parent.delete(recursive: true);
    } catch (_) {
      // Temp files; the OS cleans them up eventually.
    }
  }
}

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
    await _deleteOldBackups();
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
        p.join(tempDir.path, '$_backupPrefix$stamp.$kBackupExtension'),
      );
      await out.writeAsBytes(ZipEncoder().encode(archive));
      return out;
    } finally {
      await work.delete(recursive: true);
    }
  }

  /// Earlier backup files left in the temp folder after sharing: each holds
  /// a full copy of the user's data, so keep only the newest one.
  Future<void> _deleteOldBackups() async {
    if (!await tempDir.exists()) return;
    await for (final entity in tempDir.list()) {
      final name = p.basename(entity.path);
      if (entity is File &&
          name.startsWith(_backupPrefix) &&
          name.endsWith('.$kBackupExtension')) {
        try {
          await entity.delete();
        } catch (_) {
          // Still being shared; try again next time.
        }
      }
    }
  }

  /// Checks [backup] (size, manifest, database integrity and structure) and
  /// returns it ready to apply, or throws [BackupException].
  Future<ValidatedBackup> readBackup(
    File backup, {
    required int currentSchema,
  }) async {
    if (await backup.length() > kMaxBackupBytes) {
      throw const BackupException(BackupFailure.invalid);
    }
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await backup.readAsBytes());
    } catch (_) {
      throw const BackupException(BackupFailure.invalid);
    }
    if (archive.length > kMaxEntries) {
      throw const BackupException(BackupFailure.invalid);
    }
    var total = 0;
    for (final entry in archive.files) {
      if (entry.size < 0 || entry.size > kMaxEntryBytes) {
        throw const BackupException(BackupFailure.invalid);
      }
      total += entry.size;
    }
    if (total > kMaxUnpackedBytes) {
      throw const BackupException(BackupFailure.invalid);
    }

    final manifestFile = archive.findFile(_manifestName);
    final dbFile = archive.findFile(_dbEntryName);
    if (manifestFile == null || dbFile == null) {
      throw const BackupException(BackupFailure.invalid);
    }
    final Map<String, dynamic> manifest;
    try {
      manifest =
          jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
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

    final work = await tempDir.createTemp('restore');
    final copy = File(p.join(work.path, _dbEntryName));
    try {
      final List<int> bytes;
      try {
        bytes = dbFile.content;
      } catch (_) {
        throw const BackupException(BackupFailure.invalid);
      }
      await copy.writeAsBytes(bytes);
      _checkDatabase(copy, currentSchema: currentSchema);
    } catch (_) {
      await work.delete(recursive: true);
      rethrow;
    }
    return ValidatedBackup._(archive, copy);
  }

  /// Opens [file] read-only and makes sure it is an intact Pawdian database
  /// that this version can open; a bad file would otherwise crash the app
  /// on every start after restoring.
  static void _checkDatabase(File file, {required int currentSchema}) {
    final Database db;
    try {
      db = sqlite3.open(file.path, mode: OpenMode.readOnly);
    } catch (_) {
      throw const BackupException(BackupFailure.invalid);
    }
    try {
      final check = db.select('PRAGMA quick_check');
      if (check.length != 1 || check.first.values.first != 'ok') {
        throw const BackupException(BackupFailure.invalid);
      }
      final version = db.userVersion;
      if (version > currentSchema) {
        throw const BackupException(BackupFailure.tooNew);
      }
      if (version < 1) throw const BackupException(BackupFailure.invalid);

      final tables = <String>{};
      for (final row in db.select(
        "SELECT type, name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%'",
      )) {
        final type = row['type'] as String?;
        final name = row['name'] as String?;
        if (type == 'index') continue;
        if (type != 'table' || !_allowedTables.contains(name)) {
          throw const BackupException(BackupFailure.invalid);
        }
        tables.add(name!);
      }
      if (!tables.containsAll(_requiredTables)) {
        throw const BackupException(BackupFailure.invalid);
      }
    } on BackupException {
      rethrow;
    } catch (_) {
      // "file is not a database" and similar errors.
      throw const BackupException(BackupFailure.invalid);
    } finally {
      db.close();
    }
  }

  /// Replaces the database file and photo folders with [backup]'s content.
  /// The caller must close the open database first and reopen it after.
  ///
  /// Everything is unpacked into a staging folder first, and the current
  /// data is only moved aside, so a failure part-way puts it back.
  Future<void> applyBackup(ValidatedBackup backup) async {
    await documentsDir.create(recursive: true);
    final staging = Directory(p.join(documentsDir.path, '.restore-staging'));
    final rollback = Directory(p.join(documentsDir.path, '.restore-rollback'));
    for (final d in [staging, rollback]) {
      if (await d.exists()) await d.delete(recursive: true);
      await d.create();
    }

    final dbNames = [
      for (final suffix in ['', '-wal', '-shm', '-journal'])
        '$kDatabaseFileName$suffix',
    ];
    final moved = <String>[]; // current data moved into rollback
    final placed = <String>[]; // restored data moved into place
    try {
      // 1. Unpack into staging.
      await backup._database.copy(p.join(staging.path, kDatabaseFileName));
      for (final dirName in _userDirs) {
        await Directory(p.join(staging.path, dirName)).create();
      }
      for (final entry in backup.archive.files) {
        if (!entry.isFile) continue;
        final parts = entry.name.split('/');
        // Only "<known dir>/<file>"; ignore anything else (no path traversal).
        if (parts.length != 2 || !_userDirs.contains(parts[0])) continue;
        if (!PhotoStore.isSafeName(parts[1])) continue;
        await File(p.join(staging.path, parts[0], parts[1]))
            .writeAsBytes(entry.content);
      }

      // 2. Move the current data aside.
      for (final name in [...dbNames, ..._userDirs]) {
        final from = p.join(documentsDir.path, name);
        final type = await FileSystemEntity.type(from);
        if (type == FileSystemEntityType.notFound) continue;
        if (type == FileSystemEntityType.directory) {
          await Directory(from).rename(p.join(rollback.path, name));
        } else {
          await File(from).rename(p.join(rollback.path, name));
        }
        moved.add(name);
      }

      // 3. Move the restored data in.
      await File(p.join(staging.path, kDatabaseFileName))
          .rename(databaseFile.path);
      placed.add(kDatabaseFileName);
      for (final dirName in _userDirs) {
        await Directory(p.join(staging.path, dirName))
            .rename(p.join(documentsDir.path, dirName));
        placed.add(dirName);
      }
    } catch (_) {
      // Put the previous data back exactly as it was.
      for (final name in placed) {
        final target = p.join(documentsDir.path, name);
        if (await FileSystemEntity.isDirectory(target)) {
          await Directory(target).delete(recursive: true);
        } else if (await File(target).exists()) {
          await File(target).delete();
        }
      }
      for (final name in moved) {
        final target = p.join(documentsDir.path, name);
        final saved = p.join(rollback.path, name);
        if (await FileSystemEntity.isDirectory(saved)) {
          await Directory(saved).rename(target);
        } else {
          await File(saved).rename(target);
        }
      }
      rethrow;
    } finally {
      for (final d in [staging, rollback]) {
        if (await d.exists()) await d.delete(recursive: true);
      }
      await backup.discard();
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
