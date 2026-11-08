import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/notifications/notification_status.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../pets/data/pet_repository.dart';
import '../pets/pets_screen.dart';
import '../reminders/data/reminder_repository.dart';
import '../reminders/widgets/reminder_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pets = ref.watch(petsProvider).value;
    final items = ref.watch(schedulableRemindersProvider).value ?? const [];

    Widget body;
    if (pets == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (pets.where((p) => !p.isArchived).isEmpty) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyState(
            icon: Icons.pets_outlined,
            title: l.homeNoPetsTitle,
            body: l.homeNoPetsBody,
          ),
          FilledButton.icon(
            key: const Key('home.addPet'),
            onPressed: () => startAddPet(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l.addPet),
          ),
        ],
      );
    } else {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day + 1);
      final horizon = endOfToday.add(const Duration(days: 7));
      final overdue = <ReminderWithPet>[];
      final today = <ReminderWithPet>[];
      final upcoming = <ReminderWithPet>[];
      for (final item in items) {
        final due = item.rule.nextDueAt!;
        // Anything due today stays under "Today" even after its time passes;
        // only earlier days count as overdue.
        if (due.isBefore(startOfToday)) {
          overdue.add(item);
        } else if (due.isBefore(endOfToday)) {
          today.add(item);
        } else if (due.isBefore(horizon)) {
          upcoming.add(item);
        }
      }
      if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty) {
        body = EmptyState(
          icon: Icons.event_available_outlined,
          title: l.homeEmptyTitle,
          body: l.homeEmptyBody,
        );
      } else {
        body = ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ..._section(context, l.homeOverdue, overdue),
            ..._section(context, l.homeToday, today),
            ..._section(context, l.homeUpcoming, upcoming),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.navHome)),
      body: Column(
        children: [
          const _PermissionBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<ReminderWithPet> items,
  ) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
      for (final item in items)
        ReminderTile(
          rule: item.rule,
          petName: item.pet.name,
          onTap: () => context.go(AppRoutes.pet(item.pet.id)),
        ),
    ];
  }
}

/// Warns when reminders cannot be delivered on time.
class _PermissionBanner extends ConsumerWidget {
  const _PermissionBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReminders =
        (ref.watch(schedulableRemindersProvider).value ?? const []).isNotEmpty;
    final status = ref.watch(notificationStatusProvider).value;
    if (!hasReminders || status == null || status.allGood) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.notifications_off_outlined,
          color: scheme.onErrorContainer,
        ),
        title: Text(
          status.enabled ? l.exactBlocked : l.notifBlocked,
          style: TextStyle(color: scheme.onErrorContainer),
        ),
        onTap: () => context.go(AppRoutes.settings),
      ),
    );
  }
}
