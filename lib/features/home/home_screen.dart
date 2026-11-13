import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/notifications/notification_status.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/paw_card.dart';
import '../../shared/widgets/pet_avatar.dart';
import '../pets/data/pet_repository.dart';
import '../pets/pets_screen.dart';
import '../records/quick_log.dart';
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
      final activePets = pets.where((p) => !p.isArchived).toList();
      final next = [...overdue, ...today, ...upcoming].firstOrNull;
      var i = 0;
      Widget enter(Widget w) => w
          .animate()
          .fadeIn(delay: (45 * i++).ms, duration: 320.ms)
          .slideY(begin: 0.08, curve: Curves.easeOutCubic);
      body = ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          enter(
            _Header(
              pets: activePets,
              todayCount: overdue.length + today.length,
            ),
          ),
          if (next != null) enter(_UpNextCard(item: next, now: now)),
          enter(SectionTitle(l.quickLogTitle)),
          QuickLogBar(pets: activePets),
          if (overdue.isEmpty && today.isEmpty && upcoming.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: EmptyState(
                icon: Icons.event_available_outlined,
                title: l.homeEmptyTitle,
                body: l.homeEmptyBody,
              ),
            )
          else
            for (final w in [
              ..._section(context, l.homeOverdue, overdue, danger: true),
              ..._section(context, l.homeToday, today),
              ..._section(context, l.homeUpcoming, upcoming),
            ])
              enter(w),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _PermissionBanner(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    String title,
    List<ReminderWithPet> items, {
    bool danger = false,
  }) {
    if (items.isEmpty) return const [];
    return [
      SectionTitle(title, color: danger ? context.paw.danger : null),
      for (final item in items)
        ReminderTile(
          rule: item.rule,
          petName: item.pet.name,
          onTap: () => context.go(AppRoutes.pet(item.pet.id)),
        ),
    ];
  }
}

/// Greeting with the pets' avatars and how many things are due today.
class _Header extends StatelessWidget {
  const _Header({required this.pets, required this.todayCount});

  final List<Pet> pets;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = context.paw;
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? l.homeGreetingMorning
        : hour < 18
        ? l.homeGreetingAfternoon
        : l.homeGreetingEvening;
    final shown = pets.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          SizedBox(
            width: 49.0 + (shown.length - 1) * 24,
            height: 49,
            child: Stack(
              children: [
                for (final (i, pet) in shown.indexed)
                  Positioned(
                    left: i * 24.0,
                    child: PetAvatar(pet: pet, radius: 22, ring: true),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: TextStyle(color: p.subtle, fontSize: 14)),
                Text(
                  l.homeTasksToday(todayCount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Big teal card with the next reminder.
class _UpNextCard extends ConsumerWidget {
  const _UpNextCard({required this.item, required this.now});

  final ReminderWithPet item;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = context.paw;
    final rule = item.rule;
    final due = rule.nextDueAt!;
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(
      due.year,
      due.month,
      due.day,
    ).difference(today).inDays;
    final when = days < 0
        ? l.homeOverdue
        : days == 0
        ? '${l.homeToday} ${formatTime(context, due)}'
        : days == 1
        ? '${l.homeTomorrow} ${formatTime(context, due)}'
        : formatDateTime(context, due);
    const onCard = Colors.white;
    final pill = Colors.white.withValues(alpha: 0.2);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PawCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: dark ? const Color(0xFF24584C) : kBrandTeal,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      onTap: () => context.go(AppRoutes.pet(item.pet.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.homeUpNext,
                  style: TextStyle(
                    color: onCard.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.pet.name} · ${reminderDisplayTitle(l, rule)}',
                  style: const TextStyle(
                    color: onCard,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PawPill(
                      when,
                      icon: days < 0
                          ? Icons.error_outline
                          : Icons.schedule_rounded,
                      bg: days < 0 ? p.dangerSoft : pill,
                      fg: days < 0 ? p.danger : onCard,
                    ),
                    PawPill(
                      repeatLabel(l, rule.repeatUnit, rule.repeatInterval),
                      icon: Icons.repeat_rounded,
                      bg: pill,
                      fg: onCard,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              PetAvatar(pet: item.pet, radius: 24, ring: true),
              const SizedBox(height: 10),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  key: Key('home.upNext.done.${rule.id}'),
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    completeReminder(context, ref, rule);
                  },
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.check_rounded, color: kBrandTeal),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    final p = context.paw;
    return PawCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      color: p.dangerSoft,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => context.go(AppRoutes.settings),
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: p.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.enabled ? l.exactBlocked : l.notifBlocked,
              style: TextStyle(color: p.danger, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right, color: p.danger),
        ],
      ),
    );
  }
}
