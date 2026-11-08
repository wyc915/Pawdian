import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Pets, ReminderRules, CareRecords, WeightEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pawdian'));

  /// v1: pets, reminder_rules, care_records (M1)
  /// v2: weight_entries; care_records severity / vet fields (M2)
  @override
  int get schemaVersion => 2;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
