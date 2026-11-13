import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_theme.dart';
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
    final p = context.paw;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: LayoutBuilder(
        builder: (context, c) {
          // 4 tiles per row on phones, more on wide screens.
          final perRow = (c.maxWidth / 86).floor().clamp(3, 8);
          const gap = 8.0;
          final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (i, t) in types.indexed)
                SizedBox(
                      width: w,
                      child: _QuickTile(
                        key: Key('quickLog.${t.name}'),
                        icon: recordIcon(t),
                        label: recordTypeLabel(l, t),
                        tone: p.recordTone(t),
                        onTap: () => quickLog(context, ref, t, pets),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (30 * i).ms, duration: 250.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOutBack,
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Tone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: tone.bg,
    borderRadius: BorderRadius.circular(PawRadius.tile),
    child: InkWell(
      borderRadius: BorderRadius.circular(PawRadius.tile),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, color: tone.fg, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone.fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
