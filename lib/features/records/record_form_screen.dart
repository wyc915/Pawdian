import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/storage/photo_store.dart';
import 'data/attachment_repository.dart';
import '../../core/notifications/notification_status.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../pets/data/pet_repository.dart';
import '../reminders/data/reminder_repository.dart';
import 'data/record_repository.dart';

/// Create (recordId == null) or edit a care record for [petId].
class RecordFormScreen extends ConsumerStatefulWidget {
  const RecordFormScreen({
    super.key,
    required this.petId,
    this.recordId,
    this.initialType,
  });

  final String petId;
  final String? recordId;
  final RecordType? initialType;

  @override
  ConsumerState<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends ConsumerState<RecordFormScreen> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _clinic = TextEditingController();
  final _diagnosis = TextEditingController();
  final _cost = TextEditingController();

  late RecordType _type = widget.initialType ?? RecordType.note;
  DateTime _occurredAt = DateTime.now();
  Severity? _severity;
  DateTime? _nextVisit;
  bool _loading = true;
  bool _saving = false;

  /// Saved photos still attached, newly picked photos, and removed ones.
  List<Attachment> _existing = [];
  final List<String> _pickedPaths = [];
  final List<Attachment> _removed = [];

  int get _photoCount => _existing.length + _pickedPaths.length;

  Future<void> _addPhoto(ImageSource source) async {
    final l = AppLocalizations.of(context);
    if (_photoCount >= kFreeAttachmentsPerRecord && !ref.read(isProProvider)) {
      await showProDialog(context, l.proAttachments);
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedPaths.add(picked.path));
  }

  Future<void> _saveAttachments(String recordId) async {
    final repo = ref.read(attachmentRepositoryProvider);
    final store = await ref.read(attachmentStoreProvider.future);
    for (final a in _removed) {
      await repo.softDelete(a.id);
      await store.delete(a.fileName);
    }
    for (final path in _pickedPaths) {
      await repo.add(recordId, await store.importFile(path));
    }
  }

  void _viewPhoto(ImageProvider image) => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(8),
      child: InteractiveViewer(child: Image(image: image)),
    ),
  );

  Widget _photos(AppLocalizations l) {
    final store = ref.watch(attachmentStoreProvider).value;
    Widget thumb(ImageProvider image, VoidCallback onRemove) => Stack(
      children: [
        GestureDetector(
          onTap: () => _viewPhoto(image),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: image,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.attachmentsTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (store != null)
              for (final a in _existing)
                if (store.imageFor(a.fileName) case final image?)
                  thumb(
                    image,
                    () => setState(() {
                      _existing = [..._existing]..remove(a);
                      _removed.add(a);
                    }),
                  ),
            for (final path in _pickedPaths)
              thumb(
                pickedImage(path),
                () => setState(() => _pickedPaths.remove(path)),
              ),
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              key: const Key('recordForm.addPhoto'),
              onPressed: () => _addPhoto(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l.attachmentAddGallery),
            ),
            TextButton.icon(
              onPressed: () => _addPhoto(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l.attachmentAddCamera),
            ),
          ],
        ),
      ],
    );
  }

  bool get _isEdit => widget.recordId != null;

  /// Stored title before editing (may be a "tpl:" template marker).
  String _originalTitle = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.recordId;
    if (id != null) {
      final r = await ref.read(recordRepositoryProvider).get(id);
      if (r != null) {
        _type = r.type;
        _occurredAt = r.occurredAt;
        _originalTitle = r.title;
        if (mounted) {
          _title.text = editableTitle(AppLocalizations.of(context), r.title);
        }
        _notes.text = r.notes;
        _severity = r.severity;
        _clinic.text = r.vetClinic;
        _diagnosis.text = r.diagnosis;
        _cost.text = r.cost == null ? '' : _trimNumber(r.cost!);
      }
      _existing = await ref.read(attachmentRepositoryProvider).forRecord(id);
    } else {
      final pet = await ref.read(petRepositoryProvider).get(widget.petId);
      _clinic.text = pet?.vetName ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  static String _trimNumber(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    for (final c in [_title, _notes, _clinic, _diagnosis, _cost]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    final draft = RecordDraft(
      type: _type,
      occurredAt: _occurredAt,
      title: titleToStore(l, _originalTitle, _title.text),
      notes: _notes.text,
      severity: _severity,
      vetClinic: _clinic.text,
      diagnosis: _diagnosis.text,
      cost: double.tryParse(_cost.text.trim().replaceAll(',', '')),
    );
    final repo = ref.read(recordRepositoryProvider);
    final String recordId;
    if (_isEdit) {
      recordId = widget.recordId!;
      await repo.update(recordId, draft);
    } else {
      recordId = await repo.create(widget.petId, draft);
    }
    await _saveAttachments(recordId);
    if (_type == RecordType.vetVisit && _nextVisit != null) {
      await ref
          .read(reminderRepositoryProvider)
          .create(
            widget.petId,
            ReminderDraft(
              type: ReminderType.checkup,
              title: l.revisitReminderTitle,
              startDate: _nextVisit!,
              times: [ref.read(defaultReminderTimeProvider)],
              unit: RepeatUnit.none,
              advanceNoticeDays: 1,
            ),
          );
      await requestNotificationPermission(ref);
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(
      context,
      message: l.deleteRecordConfirm,
      confirmLabel: l.actionDelete,
    )) {
      await ref.read(recordRepositoryProvider).softDelete(widget.recordId!);
      if (mounted) context.pop();
    }
  }

  Future<void> _pickNextVisit() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVisit ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _nextVisit = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.recordFormEditTitle : l.recordFormNewTitle),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.actionDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
            key: const Key('recordForm.save'),
            onPressed: _loading || _saving ? null : _save,
            child: Text(l.actionSave),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<RecordType>(
                  key: const Key('recordForm.type'),
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l.fieldReminderType),
                  items: [
                    for (final t in RecordType.values)
                      DropdownMenuItem(
                        value: t,
                        child: Text(recordTypeLabel(l, t)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.fieldTime),
                  subtitle: Text(formatDateTime(context, _occurredAt)),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final picked = await pickDateTime(context, _occurredAt);
                    if (picked != null) setState(() => _occurredAt = picked);
                  },
                ),
                if (_type.hasSeverity) ...[
                  Text(l.fieldSeverity),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in <Severity?>[null, ...Severity.values])
                        ChoiceChip(
                          label: Text(severityLabel(l, s)),
                          selected: _severity == s,
                          onSelected: (_) => setState(() => _severity = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (_type == RecordType.vetVisit) ...[
                  TextField(
                    controller: _clinic,
                    decoration: InputDecoration(labelText: l.fieldVetName),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _diagnosis,
                    decoration: InputDecoration(labelText: l.fieldDiagnosis),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cost,
                    decoration: InputDecoration(labelText: l.fieldCost),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.fieldNextVisit),
                    subtitle: Text(
                      _nextVisit == null
                          ? l.notSet
                          : formatDate(context, _nextVisit!),
                    ),
                    trailing: _nextVisit == null
                        ? const Icon(Icons.event)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _nextVisit = null),
                          ),
                    onTap: _pickNextVisit,
                  ),
                ],
                TextField(
                  controller: _title,
                  decoration: InputDecoration(
                    labelText: l.fieldTitleOptional,
                    hintText: recordTypeLabel(l, _type),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('recordForm.notes'),
                  controller: _notes,
                  decoration: InputDecoration(labelText: l.fieldNotes),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _photos(l),
              ],
            ),
    );
  }
}
