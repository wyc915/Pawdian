// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PetsTable extends Pets with TableInfo<$PetsTable, Pet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Species, String> species =
      GeneratedColumn<String>(
        'species',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Species>($PetsTable.$converterspecies);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Sex.unknown.name),
      ).withConverter<Sex>($PetsTable.$convertersex);
  static const VerificationMeta _neuteredMeta = const VerificationMeta(
    'neutered',
  );
  @override
  late final GeneratedColumn<bool> neutered = GeneratedColumn<bool>(
    'neutered',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("neutered" IN (0, 1))',
    ),
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateEstimatedMeta =
      const VerificationMeta('birthDateEstimated');
  @override
  late final GeneratedColumn<bool> birthDateEstimated = GeneratedColumn<bool>(
    'birth_date_estimated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("birth_date_estimated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _microchipIdMeta = const VerificationMeta(
    'microchipId',
  );
  @override
  late final GeneratedColumn<String> microchipId = GeneratedColumn<String>(
    'microchip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoFileMeta = const VerificationMeta(
    'photoFile',
  );
  @override
  late final GeneratedColumn<String> photoFile = GeneratedColumn<String>(
    'photo_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vetNameMeta = const VerificationMeta(
    'vetName',
  );
  @override
  late final GeneratedColumn<String> vetName = GeneratedColumn<String>(
    'vet_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _vetPhoneMeta = const VerificationMeta(
    'vetPhone',
  );
  @override
  late final GeneratedColumn<String> vetPhone = GeneratedColumn<String>(
    'vet_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    name,
    species,
    breed,
    sex,
    neutered,
    birthDate,
    birthDateEstimated,
    microchipId,
    photoFile,
    color,
    notes,
    vetName,
    vetPhone,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('neutered')) {
      context.handle(
        _neuteredMeta,
        neutered.isAcceptableOrUnknown(data['neutered']!, _neuteredMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('birth_date_estimated')) {
      context.handle(
        _birthDateEstimatedMeta,
        birthDateEstimated.isAcceptableOrUnknown(
          data['birth_date_estimated']!,
          _birthDateEstimatedMeta,
        ),
      );
    }
    if (data.containsKey('microchip_id')) {
      context.handle(
        _microchipIdMeta,
        microchipId.isAcceptableOrUnknown(
          data['microchip_id']!,
          _microchipIdMeta,
        ),
      );
    }
    if (data.containsKey('photo_file')) {
      context.handle(
        _photoFileMeta,
        photoFile.isAcceptableOrUnknown(data['photo_file']!, _photoFileMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('vet_name')) {
      context.handle(
        _vetNameMeta,
        vetName.isAcceptableOrUnknown(data['vet_name']!, _vetNameMeta),
      );
    }
    if (data.containsKey('vet_phone')) {
      context.handle(
        _vetPhoneMeta,
        vetPhone.isAcceptableOrUnknown(data['vet_phone']!, _vetPhoneMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      species: $PetsTable.$converterspecies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}species'],
        )!,
      ),
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      )!,
      sex: $PetsTable.$convertersex.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        )!,
      ),
      neutered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}neutered'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      birthDateEstimated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}birth_date_estimated'],
      )!,
      microchipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}microchip_id'],
      )!,
      photoFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_file'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      vetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vet_name'],
      )!,
      vetPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vet_phone'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Species, String, String> $converterspecies =
      const EnumNameConverter<Species>(Species.values);
  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
}

class Pet extends DataClass implements Insertable<Pet> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? ownerId;
  final String name;
  final Species species;
  final String breed;
  final Sex sex;
  final bool? neutered;
  final DateTime? birthDate;
  final bool birthDateEstimated;
  final String microchipId;

  /// File name inside the app's pet_photos directory.
  final String? photoFile;
  final String color;
  final String notes;
  final String vetName;
  final String vetPhone;
  final bool isArchived;
  const Pet({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    this.neutered,
    this.birthDate,
    required this.birthDateEstimated,
    required this.microchipId,
    this.photoFile,
    required this.color,
    required this.notes,
    required this.vetName,
    required this.vetPhone,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['name'] = Variable<String>(name);
    {
      map['species'] = Variable<String>(
        $PetsTable.$converterspecies.toSql(species),
      );
    }
    map['breed'] = Variable<String>(breed);
    {
      map['sex'] = Variable<String>($PetsTable.$convertersex.toSql(sex));
    }
    if (!nullToAbsent || neutered != null) {
      map['neutered'] = Variable<bool>(neutered);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['birth_date_estimated'] = Variable<bool>(birthDateEstimated);
    map['microchip_id'] = Variable<String>(microchipId);
    if (!nullToAbsent || photoFile != null) {
      map['photo_file'] = Variable<String>(photoFile);
    }
    map['color'] = Variable<String>(color);
    map['notes'] = Variable<String>(notes);
    map['vet_name'] = Variable<String>(vetName);
    map['vet_phone'] = Variable<String>(vetPhone);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      sex: Value(sex),
      neutered: neutered == null && nullToAbsent
          ? const Value.absent()
          : Value(neutered),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthDateEstimated: Value(birthDateEstimated),
      microchipId: Value(microchipId),
      photoFile: photoFile == null && nullToAbsent
          ? const Value.absent()
          : Value(photoFile),
      color: Value(color),
      notes: Value(notes),
      vetName: Value(vetName),
      vetPhone: Value(vetPhone),
      isArchived: Value(isArchived),
    );
  }

  factory Pet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pet(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      species: $PetsTable.$converterspecies.fromJson(
        serializer.fromJson<String>(json['species']),
      ),
      breed: serializer.fromJson<String>(json['breed']),
      sex: $PetsTable.$convertersex.fromJson(
        serializer.fromJson<String>(json['sex']),
      ),
      neutered: serializer.fromJson<bool?>(json['neutered']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      birthDateEstimated: serializer.fromJson<bool>(json['birthDateEstimated']),
      microchipId: serializer.fromJson<String>(json['microchipId']),
      photoFile: serializer.fromJson<String?>(json['photoFile']),
      color: serializer.fromJson<String>(json['color']),
      notes: serializer.fromJson<String>(json['notes']),
      vetName: serializer.fromJson<String>(json['vetName']),
      vetPhone: serializer.fromJson<String>(json['vetPhone']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'ownerId': serializer.toJson<String?>(ownerId),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(
        $PetsTable.$converterspecies.toJson(species),
      ),
      'breed': serializer.toJson<String>(breed),
      'sex': serializer.toJson<String>($PetsTable.$convertersex.toJson(sex)),
      'neutered': serializer.toJson<bool?>(neutered),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'birthDateEstimated': serializer.toJson<bool>(birthDateEstimated),
      'microchipId': serializer.toJson<String>(microchipId),
      'photoFile': serializer.toJson<String?>(photoFile),
      'color': serializer.toJson<String>(color),
      'notes': serializer.toJson<String>(notes),
      'vetName': serializer.toJson<String>(vetName),
      'vetPhone': serializer.toJson<String>(vetPhone),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Pet copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
    String? name,
    Species? species,
    String? breed,
    Sex? sex,
    Value<bool?> neutered = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    bool? birthDateEstimated,
    String? microchipId,
    Value<String?> photoFile = const Value.absent(),
    String? color,
    String? notes,
    String? vetName,
    String? vetPhone,
    bool? isArchived,
  }) => Pet(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    name: name ?? this.name,
    species: species ?? this.species,
    breed: breed ?? this.breed,
    sex: sex ?? this.sex,
    neutered: neutered.present ? neutered.value : this.neutered,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    birthDateEstimated: birthDateEstimated ?? this.birthDateEstimated,
    microchipId: microchipId ?? this.microchipId,
    photoFile: photoFile.present ? photoFile.value : this.photoFile,
    color: color ?? this.color,
    notes: notes ?? this.notes,
    vetName: vetName ?? this.vetName,
    vetPhone: vetPhone ?? this.vetPhone,
    isArchived: isArchived ?? this.isArchived,
  );
  Pet copyWithCompanion(PetsCompanion data) {
    return Pet(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      sex: data.sex.present ? data.sex.value : this.sex,
      neutered: data.neutered.present ? data.neutered.value : this.neutered,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthDateEstimated: data.birthDateEstimated.present
          ? data.birthDateEstimated.value
          : this.birthDateEstimated,
      microchipId: data.microchipId.present
          ? data.microchipId.value
          : this.microchipId,
      photoFile: data.photoFile.present ? data.photoFile.value : this.photoFile,
      color: data.color.present ? data.color.value : this.color,
      notes: data.notes.present ? data.notes.value : this.notes,
      vetName: data.vetName.present ? data.vetName.value : this.vetName,
      vetPhone: data.vetPhone.present ? data.vetPhone.value : this.vetPhone,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pet(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('neutered: $neutered, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthDateEstimated: $birthDateEstimated, ')
          ..write('microchipId: $microchipId, ')
          ..write('photoFile: $photoFile, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('vetName: $vetName, ')
          ..write('vetPhone: $vetPhone, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    name,
    species,
    breed,
    sex,
    neutered,
    birthDate,
    birthDateEstimated,
    microchipId,
    photoFile,
    color,
    notes,
    vetName,
    vetPhone,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pet &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.sex == this.sex &&
          other.neutered == this.neutered &&
          other.birthDate == this.birthDate &&
          other.birthDateEstimated == this.birthDateEstimated &&
          other.microchipId == this.microchipId &&
          other.photoFile == this.photoFile &&
          other.color == this.color &&
          other.notes == this.notes &&
          other.vetName == this.vetName &&
          other.vetPhone == this.vetPhone &&
          other.isArchived == this.isArchived);
}

class PetsCompanion extends UpdateCompanion<Pet> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> ownerId;
  final Value<String> name;
  final Value<Species> species;
  final Value<String> breed;
  final Value<Sex> sex;
  final Value<bool?> neutered;
  final Value<DateTime?> birthDate;
  final Value<bool> birthDateEstimated;
  final Value<String> microchipId;
  final Value<String?> photoFile;
  final Value<String> color;
  final Value<String> notes;
  final Value<String> vetName;
  final Value<String> vetPhone;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.sex = const Value.absent(),
    this.neutered = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthDateEstimated = const Value.absent(),
    this.microchipId = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    this.vetName = const Value.absent(),
    this.vetPhone = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PetsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    required String name,
    required Species species,
    this.breed = const Value.absent(),
    this.sex = const Value.absent(),
    this.neutered = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthDateEstimated = const Value.absent(),
    this.microchipId = const Value.absent(),
    this.photoFile = const Value.absent(),
    this.color = const Value.absent(),
    this.notes = const Value.absent(),
    this.vetName = const Value.absent(),
    this.vetPhone = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       species = Value(species);
  static Insertable<Pet> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? sex,
    Expression<bool>? neutered,
    Expression<DateTime>? birthDate,
    Expression<bool>? birthDateEstimated,
    Expression<String>? microchipId,
    Expression<String>? photoFile,
    Expression<String>? color,
    Expression<String>? notes,
    Expression<String>? vetName,
    Expression<String>? vetPhone,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (sex != null) 'sex': sex,
      if (neutered != null) 'neutered': neutered,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthDateEstimated != null)
        'birth_date_estimated': birthDateEstimated,
      if (microchipId != null) 'microchip_id': microchipId,
      if (photoFile != null) 'photo_file': photoFile,
      if (color != null) 'color': color,
      if (notes != null) 'notes': notes,
      if (vetName != null) 'vet_name': vetName,
      if (vetPhone != null) 'vet_phone': vetPhone,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PetsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? ownerId,
    Value<String>? name,
    Value<Species>? species,
    Value<String>? breed,
    Value<Sex>? sex,
    Value<bool?>? neutered,
    Value<DateTime?>? birthDate,
    Value<bool>? birthDateEstimated,
    Value<String>? microchipId,
    Value<String?>? photoFile,
    Value<String>? color,
    Value<String>? notes,
    Value<String>? vetName,
    Value<String>? vetPhone,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      neutered: neutered ?? this.neutered,
      birthDate: birthDate ?? this.birthDate,
      birthDateEstimated: birthDateEstimated ?? this.birthDateEstimated,
      microchipId: microchipId ?? this.microchipId,
      photoFile: photoFile ?? this.photoFile,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      vetName: vetName ?? this.vetName,
      vetPhone: vetPhone ?? this.vetPhone,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(
        $PetsTable.$converterspecies.toSql(species.value),
      );
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>($PetsTable.$convertersex.toSql(sex.value));
    }
    if (neutered.present) {
      map['neutered'] = Variable<bool>(neutered.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (birthDateEstimated.present) {
      map['birth_date_estimated'] = Variable<bool>(birthDateEstimated.value);
    }
    if (microchipId.present) {
      map['microchip_id'] = Variable<String>(microchipId.value);
    }
    if (photoFile.present) {
      map['photo_file'] = Variable<String>(photoFile.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (vetName.present) {
      map['vet_name'] = Variable<String>(vetName.value);
    }
    if (vetPhone.present) {
      map['vet_phone'] = Variable<String>(vetPhone.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('neutered: $neutered, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthDateEstimated: $birthDateEstimated, ')
          ..write('microchipId: $microchipId, ')
          ..write('photoFile: $photoFile, ')
          ..write('color: $color, ')
          ..write('notes: $notes, ')
          ..write('vetName: $vetName, ')
          ..write('vetPhone: $vetPhone, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRulesTable extends ReminderRules
    with TableInfo<$ReminderRulesTable, ReminderRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderType>($ReminderRulesTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RepeatUnit, String> repeatUnit =
      GeneratedColumn<String>(
        'repeat_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RepeatUnit>($ReminderRulesTable.$converterrepeatUnit);
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  @override
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timesOfDayMeta = const VerificationMeta(
    'timesOfDay',
  );
  @override
  late final GeneratedColumn<String> timesOfDay = GeneratedColumn<String>(
    'times_of_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('09:00'),
  );
  static const VerificationMeta _advanceNoticeDaysMeta = const VerificationMeta(
    'advanceNoticeDays',
  );
  @override
  late final GeneratedColumn<int> advanceNoticeDays = GeneratedColumn<int>(
    'advance_notice_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _nextDueAtMeta = const VerificationMeta(
    'nextDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueAt = GeneratedColumn<DateTime>(
    'next_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    petId,
    type,
    title,
    startDate,
    repeatUnit,
    repeatInterval,
    timesOfDay,
    advanceNoticeDays,
    isActive,
    nextDueAt,
    snoozedUntil,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    }
    if (data.containsKey('times_of_day')) {
      context.handle(
        _timesOfDayMeta,
        timesOfDay.isAcceptableOrUnknown(
          data['times_of_day']!,
          _timesOfDayMeta,
        ),
      );
    }
    if (data.containsKey('advance_notice_days')) {
      context.handle(
        _advanceNoticeDaysMeta,
        advanceNoticeDays.isAcceptableOrUnknown(
          data['advance_notice_days']!,
          _advanceNoticeDaysMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('next_due_at')) {
      context.handle(
        _nextDueAtMeta,
        nextDueAt.isAcceptableOrUnknown(data['next_due_at']!, _nextDueAtMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      type: $ReminderRulesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      repeatUnit: $ReminderRulesTable.$converterrepeatUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}repeat_unit'],
        )!,
      ),
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      timesOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_of_day'],
      )!,
      advanceNoticeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}advance_notice_days'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      nextDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $ReminderRulesTable createAlias(String alias) {
    return $ReminderRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderType, String, String> $convertertype =
      const EnumNameConverter<ReminderType>(ReminderType.values);
  static JsonTypeConverter2<RepeatUnit, String, String> $converterrepeatUnit =
      const EnumNameConverter<RepeatUnit>(RepeatUnit.values);
}

class ReminderRule extends DataClass implements Insertable<ReminderRule> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? ownerId;
  final String petId;
  final ReminderType type;

  /// User title; empty means "use the localized type name".
  final String title;
  final DateTime startDate;
  final RepeatUnit repeatUnit;
  final int repeatInterval;

  /// "HH:mm" values separated by commas, e.g. "08:00,20:00".
  final String timesOfDay;
  final int advanceNoticeDays;
  final bool isActive;

  /// Next pending occurrence; null once a one-off reminder is done.
  final DateTime? nextDueAt;
  final DateTime? snoozedUntil;
  final String notes;
  const ReminderRule({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.ownerId,
    required this.petId,
    required this.type,
    required this.title,
    required this.startDate,
    required this.repeatUnit,
    required this.repeatInterval,
    required this.timesOfDay,
    required this.advanceNoticeDays,
    required this.isActive,
    this.nextDueAt,
    this.snoozedUntil,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['pet_id'] = Variable<String>(petId);
    {
      map['type'] = Variable<String>(
        $ReminderRulesTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    map['start_date'] = Variable<DateTime>(startDate);
    {
      map['repeat_unit'] = Variable<String>(
        $ReminderRulesTable.$converterrepeatUnit.toSql(repeatUnit),
      );
    }
    map['repeat_interval'] = Variable<int>(repeatInterval);
    map['times_of_day'] = Variable<String>(timesOfDay);
    map['advance_notice_days'] = Variable<int>(advanceNoticeDays);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || nextDueAt != null) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  ReminderRulesCompanion toCompanion(bool nullToAbsent) {
    return ReminderRulesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      petId: Value(petId),
      type: Value(type),
      title: Value(title),
      startDate: Value(startDate),
      repeatUnit: Value(repeatUnit),
      repeatInterval: Value(repeatInterval),
      timesOfDay: Value(timesOfDay),
      advanceNoticeDays: Value(advanceNoticeDays),
      isActive: Value(isActive),
      nextDueAt: nextDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      notes: Value(notes),
    );
  }

  factory ReminderRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRule(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      petId: serializer.fromJson<String>(json['petId']),
      type: $ReminderRulesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      repeatUnit: $ReminderRulesTable.$converterrepeatUnit.fromJson(
        serializer.fromJson<String>(json['repeatUnit']),
      ),
      repeatInterval: serializer.fromJson<int>(json['repeatInterval']),
      timesOfDay: serializer.fromJson<String>(json['timesOfDay']),
      advanceNoticeDays: serializer.fromJson<int>(json['advanceNoticeDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      nextDueAt: serializer.fromJson<DateTime?>(json['nextDueAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'ownerId': serializer.toJson<String?>(ownerId),
      'petId': serializer.toJson<String>(petId),
      'type': serializer.toJson<String>(
        $ReminderRulesTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'startDate': serializer.toJson<DateTime>(startDate),
      'repeatUnit': serializer.toJson<String>(
        $ReminderRulesTable.$converterrepeatUnit.toJson(repeatUnit),
      ),
      'repeatInterval': serializer.toJson<int>(repeatInterval),
      'timesOfDay': serializer.toJson<String>(timesOfDay),
      'advanceNoticeDays': serializer.toJson<int>(advanceNoticeDays),
      'isActive': serializer.toJson<bool>(isActive),
      'nextDueAt': serializer.toJson<DateTime?>(nextDueAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'notes': serializer.toJson<String>(notes),
    };
  }

  ReminderRule copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
    String? petId,
    ReminderType? type,
    String? title,
    DateTime? startDate,
    RepeatUnit? repeatUnit,
    int? repeatInterval,
    String? timesOfDay,
    int? advanceNoticeDays,
    bool? isActive,
    Value<DateTime?> nextDueAt = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    String? notes,
  }) => ReminderRule(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    petId: petId ?? this.petId,
    type: type ?? this.type,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    repeatUnit: repeatUnit ?? this.repeatUnit,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    timesOfDay: timesOfDay ?? this.timesOfDay,
    advanceNoticeDays: advanceNoticeDays ?? this.advanceNoticeDays,
    isActive: isActive ?? this.isActive,
    nextDueAt: nextDueAt.present ? nextDueAt.value : this.nextDueAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    notes: notes ?? this.notes,
  );
  ReminderRule copyWithCompanion(ReminderRulesCompanion data) {
    return ReminderRule(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      petId: data.petId.present ? data.petId.value : this.petId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      repeatUnit: data.repeatUnit.present
          ? data.repeatUnit.value
          : this.repeatUnit,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      timesOfDay: data.timesOfDay.present
          ? data.timesOfDay.value
          : this.timesOfDay,
      advanceNoticeDays: data.advanceNoticeDays.present
          ? data.advanceNoticeDays.value
          : this.advanceNoticeDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      nextDueAt: data.nextDueAt.present ? data.nextDueAt.value : this.nextDueAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRule(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('petId: $petId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('startDate: $startDate, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('advanceNoticeDays: $advanceNoticeDays, ')
          ..write('isActive: $isActive, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    petId,
    type,
    title,
    startDate,
    repeatUnit,
    repeatInterval,
    timesOfDay,
    advanceNoticeDays,
    isActive,
    nextDueAt,
    snoozedUntil,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRule &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ownerId == this.ownerId &&
          other.petId == this.petId &&
          other.type == this.type &&
          other.title == this.title &&
          other.startDate == this.startDate &&
          other.repeatUnit == this.repeatUnit &&
          other.repeatInterval == this.repeatInterval &&
          other.timesOfDay == this.timesOfDay &&
          other.advanceNoticeDays == this.advanceNoticeDays &&
          other.isActive == this.isActive &&
          other.nextDueAt == this.nextDueAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.notes == this.notes);
}

class ReminderRulesCompanion extends UpdateCompanion<ReminderRule> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> ownerId;
  final Value<String> petId;
  final Value<ReminderType> type;
  final Value<String> title;
  final Value<DateTime> startDate;
  final Value<RepeatUnit> repeatUnit;
  final Value<int> repeatInterval;
  final Value<String> timesOfDay;
  final Value<int> advanceNoticeDays;
  final Value<bool> isActive;
  final Value<DateTime?> nextDueAt;
  final Value<DateTime?> snoozedUntil;
  final Value<String> notes;
  final Value<int> rowid;
  const ReminderRulesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.petId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.startDate = const Value.absent(),
    this.repeatUnit = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    this.advanceNoticeDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRulesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    required String petId,
    required ReminderType type,
    this.title = const Value.absent(),
    required DateTime startDate,
    required RepeatUnit repeatUnit,
    this.repeatInterval = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    this.advanceNoticeDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.nextDueAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       petId = Value(petId),
       type = Value(type),
       startDate = Value(startDate),
       repeatUnit = Value(repeatUnit);
  static Insertable<ReminderRule> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? ownerId,
    Expression<String>? petId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<DateTime>? startDate,
    Expression<String>? repeatUnit,
    Expression<int>? repeatInterval,
    Expression<String>? timesOfDay,
    Expression<int>? advanceNoticeDays,
    Expression<bool>? isActive,
    Expression<DateTime>? nextDueAt,
    Expression<DateTime>? snoozedUntil,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (petId != null) 'pet_id': petId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (startDate != null) 'start_date': startDate,
      if (repeatUnit != null) 'repeat_unit': repeatUnit,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (timesOfDay != null) 'times_of_day': timesOfDay,
      if (advanceNoticeDays != null) 'advance_notice_days': advanceNoticeDays,
      if (isActive != null) 'is_active': isActive,
      if (nextDueAt != null) 'next_due_at': nextDueAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRulesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? ownerId,
    Value<String>? petId,
    Value<ReminderType>? type,
    Value<String>? title,
    Value<DateTime>? startDate,
    Value<RepeatUnit>? repeatUnit,
    Value<int>? repeatInterval,
    Value<String>? timesOfDay,
    Value<int>? advanceNoticeDays,
    Value<bool>? isActive,
    Value<DateTime?>? nextDueAt,
    Value<DateTime?>? snoozedUntil,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return ReminderRulesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ownerId: ownerId ?? this.ownerId,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      repeatUnit: repeatUnit ?? this.repeatUnit,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      advanceNoticeDays: advanceNoticeDays ?? this.advanceNoticeDays,
      isActive: isActive ?? this.isActive,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ReminderRulesTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (repeatUnit.present) {
      map['repeat_unit'] = Variable<String>(
        $ReminderRulesTable.$converterrepeatUnit.toSql(repeatUnit.value),
      );
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (timesOfDay.present) {
      map['times_of_day'] = Variable<String>(timesOfDay.value);
    }
    if (advanceNoticeDays.present) {
      map['advance_notice_days'] = Variable<int>(advanceNoticeDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (nextDueAt.present) {
      map['next_due_at'] = Variable<DateTime>(nextDueAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRulesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('petId: $petId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('startDate: $startDate, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('advanceNoticeDays: $advanceNoticeDays, ')
          ..write('isActive: $isActive, ')
          ..write('nextDueAt: $nextDueAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareRecordsTable extends CareRecords
    with TableInfo<$CareRecordsTable, CareRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecordType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordType>($CareRecordsTable.$convertertype);
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceReminderIdMeta = const VerificationMeta(
    'sourceReminderId',
  );
  @override
  late final GeneratedColumn<String> sourceReminderId = GeneratedColumn<String>(
    'source_reminder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    petId,
    type,
    occurredAt,
    title,
    notes,
    sourceReminderId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('source_reminder_id')) {
      context.handle(
        _sourceReminderIdMeta,
        sourceReminderId.isAcceptableOrUnknown(
          data['source_reminder_id']!,
          _sourceReminderIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      type: $CareRecordsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      sourceReminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_reminder_id'],
      ),
    );
  }

  @override
  $CareRecordsTable createAlias(String alias) {
    return $CareRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecordType, String, String> $convertertype =
      const EnumNameConverter<RecordType>(RecordType.values);
}

class CareRecord extends DataClass implements Insertable<CareRecord> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? ownerId;
  final String petId;
  final RecordType type;
  final DateTime occurredAt;
  final String title;
  final String notes;
  final String? sourceReminderId;
  const CareRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.ownerId,
    required this.petId,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.notes,
    this.sourceReminderId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['pet_id'] = Variable<String>(petId);
    {
      map['type'] = Variable<String>(
        $CareRecordsTable.$convertertype.toSql(type),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || sourceReminderId != null) {
      map['source_reminder_id'] = Variable<String>(sourceReminderId);
    }
    return map;
  }

  CareRecordsCompanion toCompanion(bool nullToAbsent) {
    return CareRecordsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      petId: Value(petId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      title: Value(title),
      notes: Value(notes),
      sourceReminderId: sourceReminderId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceReminderId),
    );
  }

  factory CareRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      petId: serializer.fromJson<String>(json['petId']),
      type: $CareRecordsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      sourceReminderId: serializer.fromJson<String?>(json['sourceReminderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'ownerId': serializer.toJson<String?>(ownerId),
      'petId': serializer.toJson<String>(petId),
      'type': serializer.toJson<String>(
        $CareRecordsTable.$convertertype.toJson(type),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'sourceReminderId': serializer.toJson<String?>(sourceReminderId),
    };
  }

  CareRecord copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> ownerId = const Value.absent(),
    String? petId,
    RecordType? type,
    DateTime? occurredAt,
    String? title,
    String? notes,
    Value<String?> sourceReminderId = const Value.absent(),
  }) => CareRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    petId: petId ?? this.petId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    sourceReminderId: sourceReminderId.present
        ? sourceReminderId.value
        : this.sourceReminderId,
  );
  CareRecord copyWithCompanion(CareRecordsCompanion data) {
    return CareRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      petId: data.petId.present ? data.petId.value : this.petId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      sourceReminderId: data.sourceReminderId.present
          ? data.sourceReminderId.value
          : this.sourceReminderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('petId: $petId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('sourceReminderId: $sourceReminderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    ownerId,
    petId,
    type,
    occurredAt,
    title,
    notes,
    sourceReminderId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.ownerId == this.ownerId &&
          other.petId == this.petId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.sourceReminderId == this.sourceReminderId);
}

class CareRecordsCompanion extends UpdateCompanion<CareRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> ownerId;
  final Value<String> petId;
  final Value<RecordType> type;
  final Value<DateTime> occurredAt;
  final Value<String> title;
  final Value<String> notes;
  final Value<String?> sourceReminderId;
  final Value<int> rowid;
  const CareRecordsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.petId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceReminderId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareRecordsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    required String petId,
    required RecordType type,
    required DateTime occurredAt,
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceReminderId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       petId = Value(petId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<CareRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? ownerId,
    Expression<String>? petId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? sourceReminderId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (petId != null) 'pet_id': petId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (sourceReminderId != null) 'source_reminder_id': sourceReminderId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? ownerId,
    Value<String>? petId,
    Value<RecordType>? type,
    Value<DateTime>? occurredAt,
    Value<String>? title,
    Value<String>? notes,
    Value<String?>? sourceReminderId,
    Value<int>? rowid,
  }) {
    return CareRecordsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      ownerId: ownerId ?? this.ownerId,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      sourceReminderId: sourceReminderId ?? this.sourceReminderId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $CareRecordsTable.$convertertype.toSql(type.value),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sourceReminderId.present) {
      map['source_reminder_id'] = Variable<String>(sourceReminderId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareRecordsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('petId: $petId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('sourceReminderId: $sourceReminderId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $ReminderRulesTable reminderRules = $ReminderRulesTable(this);
  late final $CareRecordsTable careRecords = $CareRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pets,
    reminderRules,
    careRecords,
  ];
}

typedef $$PetsTableCreateCompanionBuilder = PetsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> ownerId,
  required String name,
  required Species species,
  Value<String> breed,
  Value<Sex> sex,
  Value<bool?> neutered,
  Value<DateTime?> birthDate,
  Value<bool> birthDateEstimated,
  Value<String> microchipId,
  Value<String?> photoFile,
  Value<String> color,
  Value<String> notes,
  Value<String> vetName,
  Value<String> vetPhone,
  Value<bool> isArchived,
  Value<int> rowid,
});
typedef $$PetsTableUpdateCompanionBuilder = PetsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> ownerId,
  Value<String> name,
  Value<Species> species,
  Value<String> breed,
  Value<Sex> sex,
  Value<bool?> neutered,
  Value<DateTime?> birthDate,
  Value<bool> birthDateEstimated,
  Value<String> microchipId,
  Value<String?> photoFile,
  Value<String> color,
  Value<String> notes,
  Value<String> vetName,
  Value<String> vetPhone,
  Value<bool> isArchived,
  Value<int> rowid,
});

final class $$PetsTableReferences
    extends BaseReferences<_$AppDatabase, $PetsTable, Pet> {
  $$PetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReminderRulesTable, List<ReminderRule>>
  _reminderRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderRules,
    aliasName: 'pets__id__reminder_rules__pet_id',
  );

  $$ReminderRulesTableProcessedTableManager get reminderRulesRefs {
    final manager = $$ReminderRulesTableTableManager(
      $_db,
      $_db.reminderRules,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CareRecordsTable, List<CareRecord>>
  _careRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.careRecords,
    aliasName: 'pets__id__care_records__pet_id',
  );

  $$CareRecordsTableProcessedTableManager get careRecordsRefs {
    final manager = $$CareRecordsTableTableManager(
      $_db,
      $_db.careRecords,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_careRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PetsTableFilterComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Species, Species, String> get species =>
      $composableBuilder(
        column: $table.species,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get neutered => $composableBuilder(
    column: $table.neutered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get birthDateEstimated => $composableBuilder(
    column: $table.birthDateEstimated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microchipId => $composableBuilder(
    column: $table.microchipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetName => $composableBuilder(
    column: $table.vetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetPhone => $composableBuilder(
    column: $table.vetPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reminderRulesRefs(
    Expression<bool> Function($$ReminderRulesTableFilterComposer f) f,
  ) {
    final $$ReminderRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableFilterComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> careRecordsRefs(
    Expression<bool> Function($$CareRecordsTableFilterComposer f) f,
  ) {
    final $$CareRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careRecords,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareRecordsTableFilterComposer(
            $db: $db,
            $table: $db.careRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableOrderingComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get neutered => $composableBuilder(
    column: $table.neutered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get birthDateEstimated => $composableBuilder(
    column: $table.birthDateEstimated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microchipId => $composableBuilder(
    column: $table.microchipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoFile => $composableBuilder(
    column: $table.photoFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetName => $composableBuilder(
    column: $table.vetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetPhone => $composableBuilder(
    column: $table.vetPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Species, String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<bool> get neutered =>
      $composableBuilder(column: $table.neutered, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<bool> get birthDateEstimated => $composableBuilder(
    column: $table.birthDateEstimated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get microchipId => $composableBuilder(
    column: $table.microchipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoFile =>
      $composableBuilder(column: $table.photoFile, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get vetName =>
      $composableBuilder(column: $table.vetName, builder: (column) => column);

  GeneratedColumn<String> get vetPhone =>
      $composableBuilder(column: $table.vetPhone, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> reminderRulesRefs<T extends Object>(
    Expression<T> Function($$ReminderRulesTableAnnotationComposer a) f,
  ) {
    final $$ReminderRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderRules,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> careRecordsRefs<T extends Object>(
    Expression<T> Function($$CareRecordsTableAnnotationComposer a) f,
  ) {
    final $$CareRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.careRecords,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CareRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.careRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetsTable,
          Pet,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (Pet, $$PetsTableReferences),
          Pet,
          PrefetchHooks Function({bool reminderRulesRefs, bool careRecordsRefs})
        > {
  $$PetsTableTableManager(_$AppDatabase db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Species> species = const Value.absent(),
                Value<String> breed = const Value.absent(),
                Value<Sex> sex = const Value.absent(),
                Value<bool?> neutered = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<bool> birthDateEstimated = const Value.absent(),
                Value<String> microchipId = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> vetName = const Value.absent(),
                Value<String> vetPhone = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                name: name,
                species: species,
                breed: breed,
                sex: sex,
                neutered: neutered,
                birthDate: birthDate,
                birthDateEstimated: birthDateEstimated,
                microchipId: microchipId,
                photoFile: photoFile,
                color: color,
                notes: notes,
                vetName: vetName,
                vetPhone: vetPhone,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                required String name,
                required Species species,
                Value<String> breed = const Value.absent(),
                Value<Sex> sex = const Value.absent(),
                Value<bool?> neutered = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<bool> birthDateEstimated = const Value.absent(),
                Value<String> microchipId = const Value.absent(),
                Value<String?> photoFile = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> vetName = const Value.absent(),
                Value<String> vetPhone = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                name: name,
                species: species,
                breed: breed,
                sex: sex,
                neutered: neutered,
                birthDate: birthDate,
                birthDateEstimated: birthDateEstimated,
                microchipId: microchipId,
                photoFile: photoFile,
                color: color,
                notes: notes,
                vetName: vetName,
                vetPhone: vetPhone,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PetsTable, Pet>(table),
                  $$PetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({reminderRulesRefs = false, careRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reminderRulesRefs) db.reminderRules,
                    if (careRecordsRefs) db.careRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reminderRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          Pet,
                          $PetsTable,
                          ReminderRule,
                          $ReminderRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._reminderRulesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).reminderRulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (careRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          Pet,
                          $PetsTable,
                          CareRecord,
                          $CareRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._careRecordsRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).careRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetsTable,
      Pet,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (Pet, $$PetsTableReferences),
      Pet,
      PrefetchHooks Function({bool reminderRulesRefs, bool careRecordsRefs})
    >;
typedef $$ReminderRulesTableCreateCompanionBuilder =
    ReminderRulesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> ownerId,
      required String petId,
      required ReminderType type,
      Value<String> title,
      required DateTime startDate,
      required RepeatUnit repeatUnit,
      Value<int> repeatInterval,
      Value<String> timesOfDay,
      Value<int> advanceNoticeDays,
      Value<bool> isActive,
      Value<DateTime?> nextDueAt,
      Value<DateTime?> snoozedUntil,
      Value<String> notes,
      Value<int> rowid,
    });
typedef $$ReminderRulesTableUpdateCompanionBuilder =
    ReminderRulesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> ownerId,
      Value<String> petId,
      Value<ReminderType> type,
      Value<String> title,
      Value<DateTime> startDate,
      Value<RepeatUnit> repeatUnit,
      Value<int> repeatInterval,
      Value<String> timesOfDay,
      Value<int> advanceNoticeDays,
      Value<bool> isActive,
      Value<DateTime?> nextDueAt,
      Value<DateTime?> snoozedUntil,
      Value<String> notes,
      Value<int> rowid,
    });

final class $$ReminderRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderRulesTable, ReminderRule> {
  $$ReminderRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('reminder_rules__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RepeatUnit, RepeatUnit, String>
  get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get advanceNoticeDays => $composableBuilder(
    column: $table.advanceNoticeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get advanceNoticeDays => $composableBuilder(
    column: $table.advanceNoticeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueAt => $composableBuilder(
    column: $table.nextDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRulesTable> {
  $$ReminderRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepeatUnit, String> get repeatUnit =>
      $composableBuilder(
        column: $table.repeatUnit,
        builder: (column) => column,
      );

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get advanceNoticeDays => $composableBuilder(
    column: $table.advanceNoticeDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueAt =>
      $composableBuilder(column: $table.nextDueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRulesTable,
          ReminderRule,
          $$ReminderRulesTableFilterComposer,
          $$ReminderRulesTableOrderingComposer,
          $$ReminderRulesTableAnnotationComposer,
          $$ReminderRulesTableCreateCompanionBuilder,
          $$ReminderRulesTableUpdateCompanionBuilder,
          (ReminderRule, $$ReminderRulesTableReferences),
          ReminderRule,
          PrefetchHooks Function({bool petId})
        > {
  $$ReminderRulesTableTableManager(_$AppDatabase db, $ReminderRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<ReminderType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<RepeatUnit> repeatUnit = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<String> timesOfDay = const Value.absent(),
                Value<int> advanceNoticeDays = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                petId: petId,
                type: type,
                title: title,
                startDate: startDate,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                timesOfDay: timesOfDay,
                advanceNoticeDays: advanceNoticeDays,
                isActive: isActive,
                nextDueAt: nextDueAt,
                snoozedUntil: snoozedUntil,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                required String petId,
                required ReminderType type,
                Value<String> title = const Value.absent(),
                required DateTime startDate,
                required RepeatUnit repeatUnit,
                Value<int> repeatInterval = const Value.absent(),
                Value<String> timesOfDay = const Value.absent(),
                Value<int> advanceNoticeDays = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> nextDueAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRulesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                petId: petId,
                type: type,
                title: title,
                startDate: startDate,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                timesOfDay: timesOfDay,
                advanceNoticeDays: advanceNoticeDays,
                isActive: isActive,
                nextDueAt: nextDueAt,
                snoozedUntil: snoozedUntil,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderRulesTable, ReminderRule>(table),
                  $$ReminderRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$ReminderRulesTableReferences
                            ._petIdTable(db),
                        referencedColumn: $$ReminderRulesTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRulesTable,
      ReminderRule,
      $$ReminderRulesTableFilterComposer,
      $$ReminderRulesTableOrderingComposer,
      $$ReminderRulesTableAnnotationComposer,
      $$ReminderRulesTableCreateCompanionBuilder,
      $$ReminderRulesTableUpdateCompanionBuilder,
      (ReminderRule, $$ReminderRulesTableReferences),
      ReminderRule,
      PrefetchHooks Function({bool petId})
    >;
typedef $$CareRecordsTableCreateCompanionBuilder =
    CareRecordsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> ownerId,
      required String petId,
      required RecordType type,
      required DateTime occurredAt,
      Value<String> title,
      Value<String> notes,
      Value<String?> sourceReminderId,
      Value<int> rowid,
    });
typedef $$CareRecordsTableUpdateCompanionBuilder =
    CareRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> ownerId,
      Value<String> petId,
      Value<RecordType> type,
      Value<DateTime> occurredAt,
      Value<String> title,
      Value<String> notes,
      Value<String?> sourceReminderId,
      Value<int> rowid,
    });

final class $$CareRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $CareRecordsTable, CareRecord> {
  $$CareRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$AppDatabase db) =>
      db.pets.createAlias('care_records__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CareRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CareRecordsTable> {
  $$CareRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecordType, RecordType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceReminderId => $composableBuilder(
    column: $table.sourceReminderId,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CareRecordsTable> {
  $$CareRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceReminderId => $composableBuilder(
    column: $table.sourceReminderId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareRecordsTable> {
  $$CareRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sourceReminderId => $composableBuilder(
    column: $table.sourceReminderId,
    builder: (column) => column,
  );

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CareRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareRecordsTable,
          CareRecord,
          $$CareRecordsTableFilterComposer,
          $$CareRecordsTableOrderingComposer,
          $$CareRecordsTableAnnotationComposer,
          $$CareRecordsTableCreateCompanionBuilder,
          $$CareRecordsTableUpdateCompanionBuilder,
          (CareRecord, $$CareRecordsTableReferences),
          CareRecord,
          PrefetchHooks Function({bool petId})
        > {
  $$CareRecordsTableTableManager(_$AppDatabase db, $CareRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<RecordType> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> sourceReminderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareRecordsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                petId: petId,
                type: type,
                occurredAt: occurredAt,
                title: title,
                notes: notes,
                sourceReminderId: sourceReminderId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                required String petId,
                required RecordType type,
                required DateTime occurredAt,
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> sourceReminderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareRecordsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                ownerId: ownerId,
                petId: petId,
                type: type,
                occurredAt: occurredAt,
                title: title,
                notes: notes,
                sourceReminderId: sourceReminderId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CareRecordsTable, CareRecord>(table),
                  $$CareRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$CareRecordsTableReferences
                            ._petIdTable(db),
                        referencedColumn: $$CareRecordsTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CareRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareRecordsTable,
      CareRecord,
      $$CareRecordsTableFilterComposer,
      $$CareRecordsTableOrderingComposer,
      $$CareRecordsTableAnnotationComposer,
      $$CareRecordsTableCreateCompanionBuilder,
      $$CareRecordsTableUpdateCompanionBuilder,
      (CareRecord, $$CareRecordsTableReferences),
      CareRecord,
      PrefetchHooks Function({bool petId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$ReminderRulesTableTableManager get reminderRules =>
      $$ReminderRulesTableTableManager(_db, _db.reminderRules);
  $$CareRecordsTableTableManager get careRecords =>
      $$CareRecordsTableTableManager(_db, _db.careRecords);
}
