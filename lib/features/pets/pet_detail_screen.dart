import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/pet_avatar.dart';
import '../../core/settings/app_settings.dart';
import '../../shared/units.dart';
import '../records/data/record_repository.dart';
import '../records/quick_log.dart';
import '../records/widgets/record_tile.dart';
import '../reminders/data/reminder_repository.dart';
import '../reminders/widgets/reminder_tile.dart';
import '../weight/data/weight_repository.dart';
import '../weight/weight_screen.dart';
import 'data/pet_repository.dart';
import 'pets_screen.dart';

enum _MenuAction { archive, unarchive, delete }

class PetDetailScreen extends ConsumerWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final petAsync = ref.watch(petProvider(petId));
    final pet = petAsync.value;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(),
        body: petAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
      );
    }

    final reminders = ref.watch(petRemindersProvider(petId)).value ?? const [];
    final records = ref.watch(recentRecordsProvider(petId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            key: const Key('petDetail.report'),
            tooltip: l.reportTitle,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              if (ref.read(isProProvider)) {
                context.go(AppRoutes.report(petId));
              } else {
                showProDialog(context, l.proReport);
              }
            },
          ),
          IconButton(
            tooltip: l.actionEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go(AppRoutes.editPet(petId)),
          ),
          PopupMenuButton<_MenuAction>(
            onSelected: (a) => _onMenu(context, ref, pet, a),
            itemBuilder: (context) => [
              if (pet.isArchived)
                PopupMenuItem(
                  value: _MenuAction.unarchive,
                  child: Text(l.unarchivePet),
                )
              else
                PopupMenuItem(
                  value: _MenuAction.archive,
                  child: Text(l.archivePet),
                ),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text(l.deletePet),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Header(pet: pet),
          const Divider(),
          _SectionTitle(
            title: l.sectionReminders,
            trailing: pet.isArchived
                ? null
                : PopupMenuButton<String>(
                    key: const Key('petDetail.addReminder'),
                    icon: const Icon(Icons.add),
                    tooltip: l.addReminder,
                    onSelected: (v) => context.go(
                      v == 'templates'
                          ? AppRoutes.petTemplates(petId)
                          : AppRoutes.newReminder(petId),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'new', child: Text(l.addReminder)),
                      PopupMenuItem(
                        value: 'templates',
                        child: Text(l.applyTemplates),
                      ),
                    ],
                  ),
          ),
          if (reminders.isEmpty)
            _EmptyLine(text: l.noReminders)
          else
            for (final r in reminders)
              ReminderTile(
                rule: r,
                enabled: !pet.isArchived,
                onTap: () => context.go(AppRoutes.editReminder(petId, r.id)),
              ),
          if (!pet.isArchived) ...[
            const Divider(),
            QuickLogBar(pets: [pet]),
          ],
          const Divider(),
          _WeightSummary(petId: petId, enabled: !pet.isArchived),
          const Divider(),
          _SectionTitle(
            title: l.sectionRecentRecords,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  key: const Key('petDetail.timeline'),
                  onPressed: () => context.go(AppRoutes.timeline(petId)),
                  child: Text(l.viewAll),
                ),
                if (!pet.isArchived)
                  IconButton(
                    key: const Key('petDetail.addRecord'),
                    tooltip: l.addRecord,
                    icon: const Icon(Icons.add),
                    onPressed: () => context.go(AppRoutes.newRecord(petId)),
                  ),
              ],
            ),
          ),
          if (records.isEmpty)
            _EmptyLine(text: l.noRecords)
          else
            for (final rec in records)
              RecordTile(
                record: rec,
                onTap: () => context.go(AppRoutes.editRecord(petId, rec.id)),
              ),
        ],
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
    _MenuAction action,
  ) async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(petRepositoryProvider);
    switch (action) {
      case _MenuAction.archive:
        if (await confirmDialog(
          context,
          message: l.archivePetConfirm(pet.name),
          confirmLabel: l.archivePet,
        )) {
          await repo.setArchived(pet.id, true);
        }
      case _MenuAction.unarchive:
        await repo.setArchived(pet.id, false);
      case _MenuAction.delete:
        if (await confirmDialog(
          context,
          message: l.deletePetConfirm(pet.name),
          confirmLabel: l.actionDelete,
        )) {
          await repo.softDelete(pet.id);
          if (context.mounted) context.go(AppRoutes.pets);
        }
    }
  }
}

/// Latest weight with a small chart; opens the full weight screen.
class _WeightSummary extends ConsumerWidget {
  const _WeightSummary({required this.petId, required this.enabled});

  final String petId;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final unit = ref.watch(effectiveWeightUnitProvider);
    final weights = ref.watch(petWeightsProvider(petId)).value ?? const [];
    final recent = weights.length > 12
        ? weights.sublist(weights.length - 12)
        : weights;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: l.weightTitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                key: const Key('petDetail.weight'),
                onPressed: () => context.go(AppRoutes.weight(petId)),
                child: Text(l.viewAll),
              ),
              if (enabled)
                IconButton(
                  key: const Key('petDetail.addWeight'),
                  tooltip: l.addWeight,
                  icon: const Icon(Icons.add),
                  onPressed: () => showWeightDialog(context, ref, petId: petId),
                ),
            ],
          ),
        ),
        if (weights.isEmpty)
          _EmptyLine(text: l.weightEmpty)
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.weightLatest(formatWeight(weights.last.grams, unit)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (recent.length >= 2)
            SizedBox(
              height: 140,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: WeightChart(entries: recent, unit: unit),
              ),
            ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final subtitle = [
      speciesLabel(l, pet.species),
      if (pet.breed.isNotEmpty) pet.breed,
      if (pet.sex != Sex.unknown) sexLabel(l, pet.sex),
      if (pet.neutered == true) l.fieldNeutered,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PetAvatar(pet: pet, radius: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name, style: theme.textTheme.headlineSmall),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                    if (pet.isArchived)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(label: Text(l.archivedBadge)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: l.fieldBirthDate, value: birthdayText(context, pet)),
          if (pet.microchipId.isNotEmpty)
            _InfoRow(label: l.fieldMicrochip, value: pet.microchipId),
          if (pet.color.isNotEmpty)
            _InfoRow(label: l.fieldColor, value: pet.color),
          if (pet.vetName.isNotEmpty || pet.vetPhone.isNotEmpty)
            _InfoRow(
              label: l.fieldVetName,
              value: [pet.vetName, pet.vetPhone]
                  .where((s) => s.isNotEmpty)
                  .join('  '),
            ),
          if (pet.notes.isNotEmpty)
            _InfoRow(label: l.fieldNotes, value: pet.notes),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?trailing,
      ],
    ),
  );
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}
