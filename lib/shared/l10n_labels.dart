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

String reminderDisplayTitle(AppLocalizations l, ReminderRule rule) =>
    rule.title.trim().isEmpty ? reminderTypeLabel(l, rule.type) : rule.title;

String recordDisplayTitle(AppLocalizations l, CareRecord record) =>
    record.title.trim().isEmpty ? recordTypeLabel(l, record.type) : record.title;

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
