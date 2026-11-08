import '../core/database/app_database.dart';
import '../core/domain/enums.dart';
import '../l10n/app_localizations.dart';

String speciesLabel(AppLocalizations l, Species s) => switch (s) {
  Species.dog => l.speciesDog,
  Species.cat => l.speciesCat,
  Species.rabbit => l.speciesRabbit,
  Species.rodent => l.speciesRodent,
  Species.bird => l.speciesBird,
  Species.reptile => l.speciesReptile,
  Species.other => l.speciesOther,
};

String sexLabel(AppLocalizations l, Sex s) => switch (s) {
  Sex.unknown => l.sexUnknown,
  Sex.male => l.sexMale,
  Sex.female => l.sexFemale,
};

String reminderTypeLabel(AppLocalizations l, ReminderType t) => switch (t) {
  ReminderType.vaccine => l.reminderTypeVaccine,
  ReminderType.dewormInternal => l.reminderTypeDewormInternal,
  ReminderType.dewormExternal => l.reminderTypeDewormExternal,
  ReminderType.heartworm => l.reminderTypeHeartworm,
  ReminderType.medication => l.reminderTypeMedication,
  ReminderType.grooming => l.reminderTypeGrooming,
  ReminderType.checkup => l.reminderTypeCheckup,
  ReminderType.custom => l.reminderTypeCustom,
};

String recordTypeLabel(AppLocalizations l, RecordType t) => switch (t) {
  RecordType.vaccine => l.reminderTypeVaccine,
  RecordType.dewormInternal => l.reminderTypeDewormInternal,
  RecordType.dewormExternal => l.reminderTypeDewormExternal,
  RecordType.heartworm => l.reminderTypeHeartworm,
  RecordType.medication => l.reminderTypeMedication,
  RecordType.grooming => l.reminderTypeGrooming,
  RecordType.checkup => l.reminderTypeCheckup,
  RecordType.custom => l.reminderTypeCustom,
  RecordType.feeding => l.recordTypeFeeding,
  RecordType.water => l.recordTypeWater,
  RecordType.poop => l.recordTypePoop,
  RecordType.urine => l.recordTypeUrine,
  RecordType.vomit => l.recordTypeVomit,
  RecordType.cough => l.recordTypeCough,
  RecordType.lethargy => l.recordTypeLethargy,
  RecordType.appetiteLoss => l.recordTypeAppetiteLoss,
  RecordType.vetVisit => l.recordTypeVetVisit,
  RecordType.note => l.recordTypeNote,
};

String severityLabel(AppLocalizations l, Severity? s) => switch (s) {
  null => l.severityNone,
  Severity.mild => l.severityMild,
  Severity.moderate => l.severityModerate,
  Severity.severe => l.severitySevere,
};

String categoryLabel(AppLocalizations l, RecordCategory? c) => switch (c) {
  null => l.categoryAll,
  RecordCategory.care => l.categoryCare,
  RecordCategory.medication => l.categoryMedication,
  RecordCategory.daily => l.categoryDaily,
  RecordCategory.symptom => l.categorySymptom,
  RecordCategory.vet => l.categoryVet,
  RecordCategory.weight => l.categoryWeight,
};

String repeatLabel(AppLocalizations l, RepeatUnit unit, int interval) =>
    switch (unit) {
      RepeatUnit.none => l.repeatOnce,
      RepeatUnit.day => l.repeatEveryDays(interval),
      RepeatUnit.week => l.repeatEveryWeeks(interval),
      RepeatUnit.month => l.repeatEveryMonths(interval),
      RepeatUnit.year => l.repeatEveryYears(interval),
    };

String repeatUnitLabel(AppLocalizations l, RepeatUnit unit) => switch (unit) {
  RepeatUnit.none => l.unitNone,
  RepeatUnit.day => l.unitDay,
  RepeatUnit.week => l.unitWeek,
  RepeatUnit.month => l.unitMonth,
  RepeatUnit.year => l.unitYear,
};

String regionLabel(AppLocalizations l, CareRegion r) => switch (r) {
  CareRegion.tw => l.regionTw,
  CareRegion.us => l.regionUs,
};

/// Reminder titles created from templates are stored as "tpl:KEY" so they
/// follow the app language instead of the language at creation time.
const kTemplateTitlePrefix = 'tpl:';
const kNamedTemplateKeys = {'rabies', 'coreDog', 'coreCat'};

String? templateTitle(AppLocalizations l, String key) => switch (key) {
  'rabies' => l.templateRabies,
  'coreDog' => l.templateCoreVaccineDog,
  'coreCat' => l.templateCoreVaccineCat,
  _ => null,
};

String reminderDisplayTitle(AppLocalizations l, ReminderRule rule) =>
    _displayTitle(l, rule.title) ?? reminderTypeLabel(l, rule.type);

/// Text to show in an editable title field for [stored].
String editableTitle(AppLocalizations l, String stored) =>
    _displayTitle(l, stored) ?? '';

/// Title to save from an edit field: keeps the language-independent template
/// marker when the user did not change the text shown for it.
String titleToStore(AppLocalizations l, String original, String edited) =>
    edited.trim() == editableTitle(l, original) ? original : edited.trim();

String? _displayTitle(AppLocalizations l, String stored) {
  final t = stored.trim();
  if (t.isEmpty) return null;
  if (t.startsWith(kTemplateTitlePrefix)) {
    return templateTitle(l, t.substring(kTemplateTitlePrefix.length));
  }
  return t;
}

String recordDisplayTitle(AppLocalizations l, CareRecord record) =>
    _displayTitle(l, record.title) ?? recordTypeLabel(l, record.type);

/// Whole years and remaining months between [birth] and [now].
(int years, int months) ageParts(DateTime birth, DateTime now) {
  var months = (now.year - birth.year) * 12 + now.month - birth.month;
  if (now.day < birth.day) months -= 1;
  if (months < 0) months = 0;
  return (months ~/ 12, months % 12);
}

String? ageLabel(AppLocalizations l, Pet pet, DateTime now) {
  final birth = pet.birthDate;
  if (birth == null) return null;
  final (years, months) = ageParts(birth, now);
  final age = years == 0
      ? l.petAgeMonths(months)
      : l.petAgeYearsMonths(years, months).trim();
  return pet.birthDateEstimated ? l.petAgeEstimated(age) : age;
}
