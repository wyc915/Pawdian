import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart' show Archive;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/database/app_database.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import 'backup_service.dart';
import 'csv_export.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(text)));

  Future<File> _create() async {
    final service = await ref.read(backupServiceProvider.future);
    final file = await service.createBackup(ref.read(appDatabaseProvider));
    await ref.read(lastBackupProvider.notifier).markNow();
    return file;
  }

  Future<void> _createAndShare() => _run(() async {
    final file = await _create();
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: p.basename(file.path)),
    );
  });

  Future<void> _createAndSave() => _run(() async {
    final l = AppLocalizations.of(context);
    final file = await _create();
    final saved = await FilePicker.saveFile(
      fileName: p.basename(file.path),
      bytes: await file.readAsBytes(),
    );
    if (saved != null && mounted) _snack(l.backupDone);
  });

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    final picked = await FilePicker.pickFiles();
    final path = picked.isEmpty ? null : picked.single.path;
    if (path == null || !mounted) return;
    final service = await ref.read(backupServiceProvider.future);
    final db = ref.read(appDatabaseProvider);
    final Archive archive;
    try {
      archive = await service.readBackup(
        File(path),
        currentSchema: db.schemaVersion,
      );
    } on BackupException catch (e) {
      _snack(
        e.reason == BackupFailure.tooNew ? l.backupTooNew : l.backupInvalid,
      );
      return;
    }
    if (!mounted) return;
    final ok = await confirmDialog(
      context,
      message: l.backupRestoreConfirm,
      confirmLabel: l.backupRestoreAction,
    );
    if (!ok) return;
    await _run(() async {
      await db.close();
      await service.applyBackup(archive);
      // Every repository depends on the database provider, so this reopens
      // (and migrates, if needed) the restored file everywhere.
      ref.invalidate(appDatabaseProvider);
      if (mounted) _snack(l.backupRestored);
    });
  }

  Future<void> _exportCsv() async {
    final l = AppLocalizations.of(context);
    if (!ref.read(isProProvider)) {
      await showProDialog(context, l.proCsv);
      return;
    }
    await _run(() async {
      final db = ref.read(appDatabaseProvider);
      final pets = await (db.select(
        db.pets,
      )..where((t) => t.deletedAt.isNull())).get();
      final records = await (db.select(
        db.careRecords,
      )..where((t) => t.deletedAt.isNull())).get();
      final weights = await (db.select(
        db.weightEntries,
      )..where((t) => t.deletedAt.isNull())).get();
      final csv = buildCsv(
        pets: pets,
        records: records,
        weights: weights,
        l: l,
        unit: ref.read(effectiveWeightUnitProvider),
      );
      final service = await ref.read(backupServiceProvider.future);
      final file = File(p.join(service.tempDir.path, 'Pawdian-export.csv'));
      await file.writeAsBytes(utf8.encode(csv));
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Pawdian-export.csv',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final last = ref.watch(lastBackupProvider);
    final stale =
        last == null || DateTime.now().difference(last).inDays > 30;
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (_busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.backupIntro),
            ),
            ListTile(
              leading: Icon(
                stale ? Icons.warning_amber : Icons.check_circle_outline,
                color: stale ? theme.colorScheme.error : null,
              ),
              title: Text(
                last == null
                    ? l.backupNever
                    : l.backupLast(formatDateTime(context, last)),
              ),
              subtitle: stale && last != null ? Text(l.backupStale) : null,
            ),
            const Divider(),
            ListTile(
              key: const Key('backup.share'),
              leading: const Icon(Icons.share_outlined),
              title: Text(l.backupCreateShare),
              onTap: _createAndShare,
            ),
            ListTile(
              key: const Key('backup.save'),
              leading: const Icon(Icons.save_alt),
              title: Text(l.backupCreateSave),
              onTap: _createAndSave,
            ),
            ListTile(
              key: const Key('backup.restore'),
              leading: const Icon(Icons.restore),
              title: Text(l.backupRestore),
              onTap: _restore,
            ),
            const Divider(),
            ListTile(
              key: const Key('backup.csv'),
              leading: const Icon(Icons.table_chart_outlined),
              title: Text(l.csvExport),
              subtitle: Text(l.csvExportHint),
              onTap: _exportCsv,
            ),
          ],
        ),
      ),
    );
  }
}
