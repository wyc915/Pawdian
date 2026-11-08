import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/notifications/notification_status.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../pets/data/pet_repository.dart';
import '../reminders/data/reminder_repository.dart';
import '../reminders/widgets/reminder_tile.dart';
import 'care_templates.dart';

/// Suggests a care schedule for a pet. Shown right after a pet is created
/// ([isNewPet]) and from the pet's reminder menu.
class TemplatePickerScreen extends ConsumerWidget {
  const TemplatePickerScreen({
    super.key,
    required this.petId,
    this.isNewPet = false,
  });

  final String petId;
  final bool isNewPet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider(petId)).value;
    if (pet == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _TemplatePicker(key: ValueKey(pet.id), pet: pet, isNewPet: isNewPet);
  }
}

class _Choice {
  _Choice(this.item, this.selected, this.date);

  final CareTemplateItem item;
  bool selected;
  DateTime date;
}

class _TemplatePicker extends ConsumerStatefulWidget {
  const _TemplatePicker({super.key, required this.pet, required this.isNewPet});

  final Pet pet;
  final bool isNewPet;

  @override
  ConsumerState<_TemplatePicker> createState() => _TemplatePickerState();
}

class _TemplatePickerState extends ConsumerState<_TemplatePicker> {
  late final List<_Choice> _choices;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final region = ref.read(effectiveCareRegionProvider);
    final today = DateTime.now();
    _choices = [
      for (final item in templatesFor(region, widget.pet.species))
        _Choice(item, item.selectedByDefault, today),
    ];
  }

  int get _selectedCount => _choices.where((c) => c.selected).length;

  void _finish() => context.go(AppRoutes.pet(widget.pet.id));

  Future<void> _apply() async {
    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    final time = ref.read(defaultReminderTimeProvider);
    final drafts = [
      for (final c in _choices.where((c) => c.selected))
        ReminderDraft(
          type: c.item.type,
          title: c.item.storedTitle(l),
          startDate: c.date,
          times: [time],
          unit: c.item.unit,
          interval: c.item.interval,
          advanceNoticeDays: c.item.advanceNoticeDays,
        ),
    ];
    await ref.read(reminderRepositoryProvider).createAll(widget.pet.id, drafts);
    await requestNotificationPermission(ref);
    if (mounted) _finish();
  }

  Future<void> _pickDate(_Choice c) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: c.date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => c.date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final region = ref.watch(effectiveCareRegionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.templatesTitle),
        actions: [
          TextButton(
            key: const Key('templates.skip'),
            onPressed: _saving ? null : _finish,
            child: Text(l.templatesSkip),
          ),
        ],
      ),
      body: _choices.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.templatesNone),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    l.templatesIntro(
                      speciesLabel(l, widget.pet.species),
                      regionLabel(l, region),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.templatesDisclaimer,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final c in _choices)
                  CheckboxListTile(
                    key: Key('template.${c.item.key}'),
                    value: c.selected,
                    onChanged: (v) => setState(() => c.selected = v ?? false),
                    secondary: Icon(reminderIcon(c.item.type)),
                    title: Text(c.item.title(l)),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            repeatLabel(l, c.item.unit, c.item.interval),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: c.selected ? () => _pickDate(c) : null,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            '${l.fieldNextDate} ${formatDate(context, c.date)}',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: _choices.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _finish,
              label: Text(l.actionDone),
            )
          : FloatingActionButton.extended(
              key: const Key('templates.apply'),
              onPressed: _saving || _selectedCount == 0 ? null : _apply,
              icon: const Icon(Icons.check),
              label: Text(l.templatesApply(_selectedCount)),
            ),
    );
  }
}
