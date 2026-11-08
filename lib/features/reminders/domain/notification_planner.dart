import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n_labels.dart';
import '../data/reminder_repository.dart';

class PlannedNotification {
  const PlannedNotification({
    required this.at,
    required this.title,
    required this.body,
    required this.ruleId,
  });

  final DateTime at;
  final String title;
  final String body;
  final String ruleId;
}

/// Turns reminders into concrete notifications for the near future.
///
/// Only a rolling window is scheduled (Android limits pending alarms and the
/// schedule changes as reminders are completed); the app re-plans on every
/// data change and whenever it returns to the foreground.
List<PlannedNotification> planNotifications(
  List<ReminderWithPet> items,
  DateTime now,
  AppLocalizations l, {
  int horizonDays = 30,
  int perRule = 10,
  int maxTotal = 60,
}) {
  final until = now.add(Duration(days: horizonDays));
  final planned = <PlannedNotification>[];

  for (final item in items) {
    final rule = item.rule;
    final due = rule.nextDueAt;
    if (due == null || !rule.isActive) continue;
    final title = l.notifTitle(item.pet.name, reminderDisplayTitle(l, rule));
    final recurrence = recurrenceOf(rule);

    final occurrences = <DateTime>[
      if (due.isAfter(now) && !due.isAfter(until)) due,
    ];
    occurrences.addAll(
      recurrence.occurrencesBetween(
        due.isAfter(now) ? due : now,
        until,
        limit: perRule - occurrences.length,
      ),
    );
    for (final at in occurrences) {
      planned.add(
        PlannedNotification(
          at: at,
          title: title,
          body: l.notifBodyDue,
          ruleId: rule.id,
        ),
      );
    }

    final upcoming = due.isAfter(now) ? due : recurrence.nextAfter(now);
    if (rule.advanceNoticeDays > 0 && upcoming != null) {
      final early = upcoming.subtract(Duration(days: rule.advanceNoticeDays));
      if (early.isAfter(now)) {
        planned.add(
          PlannedNotification(
            at: early,
            title: title,
            body: l.notifBodyAdvance(rule.advanceNoticeDays),
            ruleId: rule.id,
          ),
        );
      }
    }

    final snoozed = rule.snoozedUntil;
    if (snoozed != null && snoozed.isAfter(now)) {
      planned.add(
        PlannedNotification(
          at: snoozed,
          title: title,
          body: l.notifBodySnoozed,
          ruleId: rule.id,
        ),
      );
    }
  }

  planned.sort((a, b) => a.at.compareTo(b.at));
  return planned.length > maxTotal ? planned.sublist(0, maxTotal) : planned;
}
