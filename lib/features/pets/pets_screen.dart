import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/paw_card.dart';
import '../../shared/widgets/pet_avatar.dart';
import 'data/pet_repository.dart';

/// Opens the new-pet form, or the Pro dialog when the free limit is reached.
Future<void> startAddPet(BuildContext context, WidgetRef ref) async {
  final count = await ref.read(petRepositoryProvider).countActive();
  if (!context.mounted) return;
  if (count >= kFreePetLimit && !ref.read(isProProvider)) {
    await showProDialog(context, AppLocalizations.of(context).proMultiplePets);
    return;
  }
  context.go(AppRoutes.newPet);
}

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pets = ref.watch(petsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.navPets)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('pets.add'),
        onPressed: () => startAddPet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addPet),
      ),
      body: pets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.pets_outlined,
              title: l.petsEmptyTitle,
              body: l.petsEmptyBody,
            );
          }
          final active = list.where((p) => !p.isArchived).toList();
          final archived = list.where((p) => p.isArchived).toList();
          return ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 96),
            children: [
              for (final (i, pet) in active.indexed)
                _PetTile(pet: pet)
                    .animate()
                    .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),
              if (archived.isNotEmpty) ...[
                SectionTitle(l.petsArchivedSection),
                for (final pet in archived) _PetTile(pet: pet),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final parts = [
      speciesLabel(l, pet.species),
      if (pet.breed.isNotEmpty) pet.breed,
      ?ageLabel(l, pet, DateTime.now()),
    ];
    final p = context.paw;
    return PawCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      onTap: () => context.go(AppRoutes.pet(pet.id)),
      child: Opacity(
        opacity: pet.isArchived ? 0.6 : 1,
        child: Row(
          children: [
            PetAvatar(pet: pet, radius: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    parts.join(' · '),
                    style: TextStyle(color: p.subtle, fontSize: 13.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.subtle),
          ],
        ),
      ),
    );
  }
}

/// Small helper for screens that need "Unknown"/"Not set" text.
String orNotSet(AppLocalizations l, String value) =>
    value.trim().isEmpty ? l.notSet : value;

/// Shared formatting for a pet's birthday line.
String birthdayText(BuildContext context, Pet pet) {
  final l = AppLocalizations.of(context);
  final b = pet.birthDate;
  if (b == null) return l.notSet;
  final age = ageLabel(l, pet, DateTime.now());
  return '${formatDate(context, b)}${age == null ? '' : ' ($age)'}';
}
