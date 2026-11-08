import 'package:drift/drift.dart';

import '../domain/enums.dart';

/// Columns shared by every synced table (see SPEC 5.3): UUID ids, timestamps,
/// soft delete and an owner slot reserved for v1.1 cloud sharing.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Pets extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get species => textEnum<Species>()();
  TextColumn get breed => text().withDefault(const Constant(''))();
  TextColumn get sex => textEnum<Sex>().withDefault(Constant(Sex.unknown.name))();
  BoolColumn get neutered => boolean().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  BoolColumn get birthDateEstimated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get microchipId => text().withDefault(const Constant(''))();

  /// File name inside the app's pet_photos directory.
  TextColumn get photoFile => text().nullable()();
  TextColumn get color => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get vetName => text().withDefault(const Constant(''))();
  TextColumn get vetPhone => text().withDefault(const Constant(''))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class ReminderRules extends Table with SyncColumns {
  TextColumn get petId => text().references(Pets, #id)();
  TextColumn get type => textEnum<ReminderType>()();

  /// User title; empty means "use the localized type name".
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get repeatUnit => textEnum<RepeatUnit>()();
  IntColumn get repeatInterval => integer().withDefault(const Constant(1))();

  /// "HH:mm" values separated by commas, e.g. "08:00,20:00".
  TextColumn get timesOfDay => text().withDefault(const Constant('09:00'))();
  IntColumn get advanceNoticeDays => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Next pending occurrence; null once a one-off reminder is done.
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class CareRecords extends Table with SyncColumns {
  TextColumn get petId => text().references(Pets, #id)();
  TextColumn get type => textEnum<RecordType>()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get sourceReminderId => text().nullable()();

  // ---- schema v2 ----
  TextColumn get severity => textEnum<Severity>().nullable()();
  TextColumn get vetClinic => text().withDefault(const Constant(''))();
  TextColumn get diagnosis => text().withDefault(const Constant(''))();
  RealColumn get cost => real().nullable()();
}

/// Added in schema v2.
class WeightEntries extends Table with SyncColumns {
  TextColumn get petId => text().references(Pets, #id)();
  DateTimeColumn get measuredAt => dateTime()();
  IntColumn get grams => integer()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Photos attached to a care record (e.g. lab reports). Added in schema v3.
class Attachments extends Table with SyncColumns {
  TextColumn get recordId => text().references(CareRecords, #id)();

  /// File name inside the app's attachments directory.
  TextColumn get fileName => text()();
}
