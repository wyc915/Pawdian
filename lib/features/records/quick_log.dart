import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/pet_avatar.dart';
import 'data/record_repository.dart';
import 'widgets/record_tile.dart';

/// Logs [type] "now" for one of [pets] (asks which one when there are
/// several) and offers to add details from the snack bar.
Future<void> quickLog(
  BuildContext context,
  WidgetRef ref,
  RecordType type,
  List<Pet> pets,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final pet = pets.length == 1 ? pets.single : await _pickPet(context, pets);
  if (pet == null) return;
  final id = await ref.read(recordRepositoryProvider).quickLog(pet.id, type);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l.quickLogDone(recordTypeLabel(l, type), pet.name)),
        // Snack bars with an action persist by default; this one should not
        // block the screen after a quick log.
        persist: false,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l.quickLogAddNote,
          onPressed: () => router.go(AppRoutes.editRecord(pet.id, id)),
        ),
      ),
    );
}

Future<Pet?> _pickPet(BuildContext context, List<Pet> pets) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<Pet>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              l.quickLogPickPet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final pet in pets)
            ListTile(
              key: Key('quickLog.pet.${pet.id}'),
              leading: PetAvatar(pet: pet, radius: 18),
              title: Text(pet.name),
              onTap: () => Navigator.pop(context, pet),
            ),
        ],
      ),
    ),
  );
}

/// Row of one-tap buttons for the user's chosen quick-log types.
class QuickLogBar extends ConsumerWidget {
  const QuickLogBar({super.key, required this.pets});

  /// Active pets the entry can be logged for.
  final List<Pet> pets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pets.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final types = ref.watch(quickLogTypesProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.quickLogTitle, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in types)
                ActionChip(
                  key: Key('quickLog.${t.name}'),
                  avatar: Icon(recordIcon(t), size: 18),
                  label: Text(recordTypeLabel(l, t)),
                  onPressed: () => quickLog(context, ref, t, pets),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
