import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionOk),
        ),
      ],
    ),
  );
}
