import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatting.dart';
import '../../../shared/l10n_labels.dart';
import '../data/reminder_repository.dart';

IconData reminderIcon(ReminderType t) => switch (t) {
  ReminderType.vaccine => Icons.vaccines_outlined,
  ReminderType.dewormInternal => Icons.medication_outlined,
  ReminderType.dewormExternal => Icons.bug_report_outlined,
  ReminderType.heartworm => Icons.favorite_border,
  ReminderType.medication => Icons.medication_liquid_outlined,
  ReminderType.grooming => Icons.shower_outlined,
  ReminderType.checkup => Icons.health_and_safety_outlined,
  ReminderType.custom => Icons.notifications_outlined,
};

Future<void> completeReminder(
  BuildContext context,
  WidgetRef ref,
  ReminderRule rule,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final title = reminderDisplayTitle(l, rule);
  final done = await ref.read(reminderRepositoryProvider).complete(rule.id);
  if (done) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.reminderCompletedSnack(title))));
  }
}

class ReminderTile extends ConsumerWidget {
  const ReminderTile({
    super.key,
    required this.rule,
    this.petName,
    this.enabled = true,
    this.onTap,
  });

  final ReminderRule rule;

  /// Shown before the title on screens that list several pets.
  final String? petName;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final due = rule.nextDueAt;
    final now = DateTime.now();
    final overdue =
        due != null && due.isBefore(DateTime(now.year, now.month, now.day));
    final title = reminderDisplayTitle(l, rule);

    final String status;
    if (!rule.isActive) {
      status = l.reminderPaused;
    } else if (due == null) {
      status = l.reminderFinished;
    } else {
      status = l.nextDue(formatDateTime(context, due));
    }

    return ListTile(
      enabled: enabled,
      leading: Icon(reminderIcon(rule.type)),
      title: Text(petName == null ? title : '$petName · $title'),
      subtitle: Text(
        '${repeatLabel(l, rule.repeatUnit, rule.repeatInterval)} · $status',
        style: overdue && rule.isActive
            ? TextStyle(color: theme.colorScheme.error)
            : null,
      ),
      trailing: enabled && rule.isActive && due != null
          ? IconButton.filledTonal(
              key: Key('reminder.complete.${rule.id}'),
              tooltip: l.actionDone,
              icon: const Icon(Icons.check),
              onPressed: () => completeReminder(context, ref, rule),
            )
          : null,
      onTap: onTap,
    );
  }
}
