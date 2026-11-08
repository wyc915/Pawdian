import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n_labels.dart';

/// One row on a pet's timeline: a care record or a weight entry.
sealed class TimelineItem {
  const TimelineItem();

  DateTime get at;
  RecordCategory get category;
}

class RecordItem extends TimelineItem {
  const RecordItem(this.record);

  final CareRecord record;

  @override
  DateTime get at => record.occurredAt;

  @override
  RecordCategory get category => record.type.category;
}

class WeightItem extends TimelineItem {
  const WeightItem(this.entry);

  final WeightEntry entry;

  @override
  DateTime get at => entry.measuredAt;

  @override
  RecordCategory get category => RecordCategory.weight;
}

/// Merges records and weights newest first, then applies the category
/// filter and a case-insensitive text search over titles and notes.
List<TimelineItem> buildTimeline({
  required List<CareRecord> records,
  required List<WeightEntry> weights,
  required AppLocalizations l,
  RecordCategory? category,
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  bool matches(TimelineItem item) {
    if (category != null && item.category != category) return false;
    if (q.isEmpty) return true;
    final haystack = switch (item) {
      RecordItem(:final record) => [
        recordDisplayTitle(l, record),
        record.notes,
        record.diagnosis,
        record.vetClinic,
      ],
      WeightItem(:final entry) => [l.categoryWeight, entry.notes],
    }.join('\n').toLowerCase();
    return haystack.contains(q);
  }

  final items = <TimelineItem>[
    for (final r in records) RecordItem(r),
    for (final w in weights) WeightItem(w),
  ].where(matches).toList()..sort((a, b) => b.at.compareTo(a.at));
  return items;
}

/// Entries whose time falls within the last [days] days (inclusive of now).
List<WeightEntry> weightsWithin(
  List<WeightEntry> weights,
  DateTime now,
  int? days,
) {
  if (days == null) return weights;
  final from = now.subtract(Duration(days: days));
  return weights.where((w) => !w.measuredAt.isBefore(from)).toList();
}
