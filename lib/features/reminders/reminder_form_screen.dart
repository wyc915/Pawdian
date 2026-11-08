import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/notifications/notification_status.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import 'data/reminder_repository.dart';
import 'domain/recurrence.dart';

const _advanceOptions = [0, 1, 3, 7, 14];

/// Create (ruleId == null) or edit a reminder for [petId].
class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, required this.petId, this.ruleId});

  final String petId;
  final String? ruleId;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _interval = TextEditingController(text: '1');

  ReminderType _type = ReminderType.vaccine;
  DateTime _date = DateTime.now();
  List<MinuteOfDay> _times = [];
  RepeatUnit _unit = RepeatUnit.year;
  int _advance = 0;
  bool _active = true;
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.ruleId != null;

  /// Stored title before editing (may be a "tpl:" template marker).
  String _originalTitle = '';

  @override
  void initState() {
    super.initState();
    _times = [ref.read(defaultReminderTimeProvider)];
    _load();
  }

  Future<void> _load() async {
    final id = widget.ruleId;
    if (id != null) {
      final rule = await ref.read(reminderRepositoryProvider).get(id);
      if (rule != null) {
        _type = rule.type;
        _originalTitle = rule.title;
        if (mounted) {
          _title.text = editableTitle(AppLocalizations.of(context), rule.title);
        }
        _notes.text = rule.notes;
        _interval.text = '${rule.repeatInterval}';
        _date = rule.nextDueAt ?? rule.startDate;
        _times = parseTimesOfDay(rule.timesOfDay);
        _unit = rule.repeatUnit;
        _advance = rule.advanceNoticeDays;
        _active = rule.isActive;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({int? replaceIndex}) async {
    final initial = replaceIndex == null
        ? ref.read(defaultReminderTimeProvider)
        : _times[replaceIndex];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null) return;
    final m = picked.hour * 60 + picked.minute;
    setState(() {
      final next = [..._times];
      if (replaceIndex == null) {
        next.add(m);
      } else {
        next[replaceIndex] = m;
      }
      _times = (next.toSet().toList()..sort());
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // For the date we store the chosen calendar day; recurrence re-anchors
    // from it, so "next due date" is also the schedule's start.
    final draft = ReminderDraft(
      type: _type,
      title: titleToStore(
        AppLocalizations.of(context),
        _originalTitle,
        _title.text,
      ),
      startDate: _date,
      times: _times,
      unit: _unit,
      interval: int.tryParse(_interval.text) ?? 1,
      advanceNoticeDays: _advance,
      notes: _notes.text,
      isActive: _active,
    );
    final repo = ref.read(reminderRepositoryProvider);
    if (_isEdit) {
      await repo.updateFromDraft(widget.ruleId!, draft);
    } else {
      await repo.create(widget.petId, draft);
    }
    await requestNotificationPermission(ref);
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(
      context,
      message: l.deleteReminderConfirm,
      confirmLabel: l.actionDelete,
    )) {
      await ref.read(reminderRepositoryProvider).softDelete(widget.ruleId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.reminderFormEditTitle : l.reminderFormNewTitle),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.actionDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
            key: const Key('reminderForm.save'),
            onPressed: _loading || _saving || _times.isEmpty ? null : _save,
            child: Text(l.actionSave),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<ReminderType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l.fieldReminderType),
                  items: [
                    for (final t in ReminderType.values)
                      DropdownMenuItem(
                        value: t,
                        child: Text(reminderTypeLabel(l, t)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: l.fieldTitleOptional,
                    hintText: reminderTypeLabel(l, _type),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.fieldNextDate),
                  subtitle: Text(formatDate(context, _date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                Text(
                  l.fieldTimes,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _times.length; i++)
                      InputChip(
                        label: Text(formatMinute(context, _times[i])),
                        onPressed: () => _pickTime(replaceIndex: i),
                        onDeleted: _times.length > 1
                            ? () => setState(() => _times.removeAt(i))
                            : null,
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l.addTime),
                      onPressed: () => _pickTime(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_unit != RepeatUnit.none) ...[
                      Text(l.fieldRepeatEvery),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 64,
                        child: TextField(
                          controller: _interval,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: DropdownButtonFormField<RepeatUnit>(
                        initialValue: _unit,
                        decoration: InputDecoration(labelText: l.fieldRepeat),
                        items: [
                          for (final u in RepeatUnit.values)
                            DropdownMenuItem(
                              value: u,
                              child: Text(repeatUnitLabel(l, u)),
                            ),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? _unit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _advanceOptions.contains(_advance)
                      ? _advance
                      : 0,
                  decoration: InputDecoration(labelText: l.fieldAdvanceNotice),
                  items: [
                    for (final d in _advanceOptions)
                      DropdownMenuItem(
                        value: d,
                        child: Text(d == 0 ? l.advanceNone : l.advanceDays(d)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _advance = v ?? 0),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notes,
                  decoration: InputDecoration(labelText: l.fieldNotes),
                  maxLines: 3,
                ),
                if (_isEdit)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.fieldActive),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
              ],
            ),
    );
  }
}
