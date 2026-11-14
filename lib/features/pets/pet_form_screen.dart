import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/photo_store.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatting.dart';
import '../../shared/l10n_labels.dart';
import '../../shared/widgets/pet_avatar.dart';
import 'data/pet_repository.dart';

/// Create (petId == null) or edit a pet.
class PetFormScreen extends ConsumerStatefulWidget {
  const PetFormScreen({super.key, this.petId});

  final String? petId;

  @override
  ConsumerState<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends ConsumerState<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _microchip = TextEditingController();
  final _color = TextEditingController();
  final _notes = TextEditingController();
  final _vetName = TextEditingController();
  final _vetPhone = TextEditingController();

  Species _species = Species.dog;
  Sex _sex = Sex.unknown;
  bool? _neutered;
  DateTime? _birthDate;
  bool _birthEstimated = false;

  /// Photo file name already stored for this pet.
  String? _photoFile;

  /// Newly picked image not yet copied into the store.
  String? _pickedPath;
  bool _removePhoto = false;

  bool _loading = true;
  bool _saving = false;
  Pet? _original;

  bool get _isEdit => widget.petId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.petId;
    if (id != null) {
      final pet = await ref.read(petRepositoryProvider).get(id);
      if (pet != null) {
        _original = pet;
        _name.text = pet.name;
        _breed.text = pet.breed;
        _microchip.text = pet.microchipId;
        _color.text = pet.color;
        _notes.text = pet.notes;
        _vetName.text = pet.vetName;
        _vetPhone.text = pet.vetPhone;
        _species = pet.species;
        _sex = pet.sex;
        _neutered = pet.neutered;
        _birthDate = pet.birthDate;
        _birthEstimated = pet.birthDateEstimated;
        _photoFile = pet.photoFile;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _breed,
      _microchip,
      _color,
      _notes,
      _vetName,
      _vetPhone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _pickedPath = picked.path;
      _removePhoto = false;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 40),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(petRepositoryProvider);

    String? photoFile = _removePhoto ? null : _photoFile;
    if (_pickedPath != null || _removePhoto) {
      final store = await ref.read(photoStoreProvider.future);
      if (_photoFile != null) await store.delete(_photoFile!);
      if (_pickedPath != null) photoFile = await store.importFile(_pickedPath!);
    }

    final data = PetsCompanion(
      name: Value(_name.text.trim()),
      species: Value(_species),
      breed: Value(_breed.text.trim()),
      sex: Value(_sex),
      neutered: Value(_neutered),
      birthDate: Value(_birthDate),
      birthDateEstimated: Value(_birthDate != null && _birthEstimated),
      microchipId: Value(_microchip.text.trim()),
      photoFile: Value(photoFile),
      color: Value(_color.text.trim()),
      notes: Value(_notes.text.trim()),
      vetName: Value(_vetName.text.trim()),
      vetPhone: Value(_vetPhone.text.trim()),
    );

    if (_isEdit) {
      await repo.update(widget.petId!, data);
      if (mounted) context.pop();
    } else {
      final id = await repo.create(data);
      if (mounted) context.go(AppRoutes.petTemplates(id, isNew: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.petFormEditTitle : l.petFormNewTitle),
        actions: [
          TextButton(
            key: const Key('petForm.save'),
            onPressed: _loading || _saving ? null : _save,
            child: Text(l.actionSave),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _photoPicker(l),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('petForm.name'),
                    controller: _name,
                    decoration: InputDecoration(labelText: l.fieldName),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.fieldNameRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Species>(
                    key: const Key('petForm.species'),
                    initialValue: _species,
                    decoration: InputDecoration(labelText: l.fieldSpecies),
                    items: [
                      for (final s in Species.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(speciesLabel(l, s)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _species = v ?? _species),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _breed,
                    decoration: InputDecoration(labelText: l.fieldBreed),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Sex>(
                    initialValue: _sex,
                    decoration: InputDecoration(labelText: l.fieldSex),
                    items: [
                      for (final s in Sex.values)
                        DropdownMenuItem(value: s, child: Text(sexLabel(l, s))),
                    ],
                    onChanged: (v) => setState(() => _sex = v ?? _sex),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.fieldNeutered),
                    value: _neutered ?? false,
                    onChanged: (v) => setState(() => _neutered = v),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.fieldBirthDate),
                    subtitle: Text(
                      _birthDate == null
                          ? l.notSet
                          : formatDate(context, _birthDate!),
                    ),
                    trailing: _birthDate == null
                        ? const Icon(Icons.calendar_today)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _birthDate = null),
                          ),
                    onTap: _pickBirthDate,
                  ),
                  if (_birthDate != null)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.fieldBirthDateEstimated),
                      value: _birthEstimated,
                      onChanged: (v) =>
                          setState(() => _birthEstimated = v ?? false),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _microchip,
                    decoration: InputDecoration(labelText: l.fieldMicrochip),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _color,
                    decoration: InputDecoration(labelText: l.fieldColor),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vetName,
                    decoration: InputDecoration(labelText: l.fieldVetName),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vetPhone,
                    decoration: InputDecoration(labelText: l.fieldVetPhone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    decoration: InputDecoration(labelText: l.fieldNotes),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _photoPicker(AppLocalizations l) {
    final hasPhoto = _pickedPath != null || (_photoFile != null && !_removePhoto);
    Widget avatar;
    if (_pickedPath != null) {
      avatar = CircleAvatar(
        radius: 48,
        foregroundImage: pickedImage(_pickedPath!),
      );
    } else if (_original != null && !_removePhoto) {
      avatar = PetAvatar(pet: _original!, radius: 48);
    } else {
      avatar = CircleAvatar(
        radius: 48,
        child: Icon(speciesIcon(_species), size: 48),
      );
    }
    return Column(
      children: [
        avatar,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l.choosePhoto),
            ),
            if (hasPhoto)
              TextButton(
                onPressed: () => setState(() {
                  _pickedPath = null;
                  _removePhoto = true;
                }),
                child: Text(l.removePhoto),
              ),
          ],
        ),
      ],
    );
  }
}
