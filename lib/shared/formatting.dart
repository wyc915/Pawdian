import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/router/app_router.dart';
import '../l10n/app_localizations.dart';

String formatDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMd(AppLocalizations.of(context).localeName).format(d);

String formatTime(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(d),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

String formatDateTime(BuildContext context, DateTime d) =>
    '${formatDate(context, d)} ${formatTime(context, d)}';

/// Plain number without currency symbol (users enter amounts in their own
/// currency), e.g. "1,250" or "12.5".
String formatAmount(BuildContext context, double amount) =>
    NumberFormat.decimalPattern(AppLocalizations.of(context).localeName)
        .format(amount);

/// Picks a date and then a time; returns null if either is cancelled.
Future<DateTime?> pickDateTime(BuildContext context, DateTime initial) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(now.year - 30),
    lastDate: DateTime(now.year + 1),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String formatMinute(BuildContext context, int minuteOfDay) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

Future<bool> confirmDialog(
  BuildContext context, {
  required String message,
  required String confirmLabel,
}) async {
  final l = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showProDialog(BuildContext context, String message) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.proTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          key: const Key('proDialog.learnMore'),
          onPressed: () {
            Navigator.pop(context);
            GoRouter.of(context).push(AppRoutes.pro);
          },
          child: Text(l.proLearnMore),
        ),
      ],
    ),
  );
}
