import 'package:sqlite3/common.dart';

/// Backup files are not restored in the browser; the web edition keeps its
/// data on the home server instead.
CommonDatabase openSqliteReadOnly(String path) =>
    throw UnsupportedError('Restoring a backup file is not available on web');
