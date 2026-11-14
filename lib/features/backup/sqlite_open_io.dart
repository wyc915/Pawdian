import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens a SQLite file read-only (Android / desktop).
CommonDatabase openSqliteReadOnly(String path) =>
    sqlite3.open(path, mode: OpenMode.readOnly);
