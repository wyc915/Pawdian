import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/common.dart' as sqlite;

import '../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// File name drift_flutter uses inside the app documents directory.
const kDatabaseFileName = 'pawdian.sqlite';

@DriftDatabase(
  tables: [Pets, ReminderRules, CareRecords, WeightEntries, Attachments],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'pawdian',
              native: const DriftNativeOptions(setup: _setupConnection),
            ),
      );

  /// Notification buttons write from a background isolate with their own
  /// connection; wait for the other connection's lock instead of failing.
  static void _setupConnection(sqlite.CommonDatabase db) =>
      db.execute('PRAGMA busy_timeout = 5000');

  /// v1: pets, reminder_rules, care_records (M1)
  /// v2: weight_entries; care_records severity / vet fields (M2)
  /// v3: attachments (M3)
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(weightEntries);
        await m.addColumn(careRecords, careRecords.severity);
        await m.addColumn(careRecords, careRecords.vetClinic);
        await m.addColumn(careRecords, careRecords.diagnosis);
        await m.addColumn(careRecords, careRecords.cost);
      }
      if (from < 3) {
        await m.createTable(attachments);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Invalidated after a backup is restored so every repository reopens the
/// replaced database file.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() async {
    try {
      await db.close();
    } catch (_) {
      // Already closed by the restore flow.
    }
  });
  return db;
});
