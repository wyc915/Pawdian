import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatting.dart';
import '../../../shared/l10n_labels.dart';

IconData recordIcon(RecordType t) => switch (t) {
  RecordType.vaccine => Icons.vaccines_outlined,
  RecordType.dewormInternal => Icons.medication_outlined,
  RecordType.dewormExternal => Icons.bug_report_outlined,
  RecordType.heartworm => Icons.favorite_border,
  RecordType.medication => Icons.medication_liquid_outlined,
  RecordType.grooming => Icons.shower_outlined,
  RecordType.checkup => Icons.health_and_safety_outlined,
  RecordType.custom => Icons.check_circle_outline,
  RecordType.feeding => Icons.restaurant_outlined,
  RecordType.water => Icons.water_drop_outlined,
  RecordType.poop => Icons.grass_outlined,
  RecordType.urine => Icons.opacity,
  RecordType.vomit => Icons.sick_outlined,
  RecordType.cough => Icons.air,
  RecordType.lethargy => Icons.bedtime_outlined,
  RecordType.appetiteLoss => Icons.no_meals_outlined,
  RecordType.vetVisit => Icons.local_hospital_outlined,
  RecordType.note => Icons.edit_note,
};

class RecordTile extends StatelessWidget {
  const RecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.showDate = true,
  });

  final CareRecord record;
  final VoidCallback? onTap;

  /// False on the timeline, where rows sit under a date header.
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final details = [
      showDate
          ? formatDateTime(context, record.occurredAt)
          : formatTime(context, record.occurredAt),
      if (record.severity != null) severityLabel(l, record.severity),
      if (record.vetClinic.isNotEmpty) record.vetClinic,
      if (record.cost != null) l.costLabel(formatAmount(context, record.cost!)),
    ].join(' · ');
    final extra = [
      record.diagnosis,
      record.notes,
    ].where((s) => s.isNotEmpty).join('\n');
    return ListTile(
      leading: Icon(
        recordIcon(record.type),
        color: record.severity == Severity.severe
            ? theme.colorScheme.error
            : null,
      ),
      title: Text(recordDisplayTitle(l, record)),
      subtitle: Text(extra.isEmpty ? details : '$details\n$extra'),
      isThreeLine: extra.isNotEmpty,
      onTap: onTap,
    );
  }
}
