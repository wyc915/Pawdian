import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/units.dart';

String _cell(Object? v) {
  final s = v?.toString() ?? '';
  if (s.contains(RegExp(r'[",\n\r]'))) return '"${s.replaceAll('"', '""')}"';
  return s;
}

String _iso(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

/// One CSV with every record and weight of every (non-deleted) pet.
/// Starts with a UTF-8 BOM so Excel shows Chinese correctly.
String buildCsv({
  required List<Pet> pets,
  required List<CareRecord> records,
  required List<WeightEntry> weights,
  required AppLocalizations l,
  required WeightUnit unit,
}) {
  final petNames = {for (final p in pets) p.id: p.name};
  final rows = <List<Object?>>[
    [
      l.fieldName,
      l.reportColDate,
      l.fieldReminderType,
      l.fieldTitleOptional,
      l.fieldSeverity,
      l.fieldWeight,
      l.fieldVetName,
      l.fieldDiagnosis,
      l.fieldCost,
      l.fieldNotes,
    ],
  ];
  final entries = <(DateTime, List<Object?>)>[
    for (final r in records)
      if (petNames.containsKey(r.petId))
        (
          r.occurredAt,
          [
            petNames[r.petId],
            _iso(r.occurredAt),
            recordTypeLabel(l, r.type),
            r.title,
            r.severity == null ? '' : severityLabel(l, r.severity),
            '',
            r.vetClinic,
            r.diagnosis,
            r.cost,
            r.notes,
          ],
        ),
    for (final w in weights)
      if (petNames.containsKey(w.petId))
        (
          w.measuredAt,
          [
            petNames[w.petId],
            _iso(w.measuredAt),
            l.categoryWeight,
            '',
            '',
            formatWeight(w.grams, unit),
            '',
            '',
            '',
            w.notes,
          ],
        ),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  rows.addAll(entries.map((e) => e.$2));
  return '﻿${rows.map((r) => r.map(_cell).join(',')).join('\r\n')}\r\n';
}
