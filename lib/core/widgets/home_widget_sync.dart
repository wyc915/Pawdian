import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../features/reminders/data/reminder_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';

/// Texts shown by the Android "next reminder" widget.
class WidgetTexts {
  const WidgetTexts(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

/// Picks the soonest pending reminder (overdue ones first, since the list is
/// sorted by due time) and formats it for the widget.
WidgetTexts nextReminderTexts(
  List<ReminderWithPet> items,
  DateTime now,
  AppLocalizations l,
) {
  if (items.isEmpty) return WidgetTexts('Pawdian', l.widgetNoReminders);
  final next = items.first;
  final due = next.rule.nextDueAt!;
  final when = DateFormat.MMMd(l.localeName).add_Hm().format(due);
  final startOfToday = DateTime(now.year, now.month, now.day);
  return WidgetTexts(
    l.notifTitle(next.pet.name, reminderDisplayTitle(l, next.rule)),
    due.isBefore(startOfToday) ? '${l.widgetOverdue} · $when' : when,
  );
}

abstract class HomeWidgetGateway {
  Future<void> show(WidgetTexts texts);
}

class AndroidHomeWidgetGateway implements HomeWidgetGateway {
  @override
  Future<void> show(WidgetTexts texts) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await HomeWidget.saveWidgetData<String>('next_title', texts.title);
    await HomeWidget.saveWidgetData<String>('next_subtitle', texts.subtitle);
    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.wyc915.pawdian.NextReminderWidget',
    );
  }
}

final homeWidgetGatewayProvider = Provider<HomeWidgetGateway>(
  (ref) => AndroidHomeWidgetGateway(),
);
