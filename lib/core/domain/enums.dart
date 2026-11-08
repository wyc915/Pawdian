/// Enums persisted by name in the database. Never rename a value without a
/// migration; adding new values at the end is safe.
library;

enum Species { dog, cat, rabbit, rodent, bird, reptile, other }

enum Sex { unknown, male, female }

enum ReminderType {
  vaccine,
  dewormInternal,
  dewormExternal,
  heartworm,
  medication,
  grooming,
  checkup,
  custom,
}

enum RepeatUnit { none, day, week, month, year }

/// Kinds of care records: completed reminders (first block) and daily
/// quick-log entries (second block, added in schema v2).
enum RecordType {
  vaccine,
  dewormInternal,
  dewormExternal,
  heartworm,
  medication,
  grooming,
  checkup,
  custom,
  // ---- schema v2 ----
  feeding,
  water,
  poop,
  urine,
  vomit,
  cough,
  lethargy,
  appetiteLoss,
  vetVisit,
  note;

  static RecordType fromReminder(ReminderType t) => switch (t) {
    ReminderType.vaccine => vaccine,
    ReminderType.dewormInternal => dewormInternal,
    ReminderType.dewormExternal => dewormExternal,
    ReminderType.heartworm => heartworm,
    ReminderType.medication => medication,
    ReminderType.grooming => grooming,
    ReminderType.checkup => checkup,
    ReminderType.custom => custom,
  };

  /// Symptom-like entries where a severity makes sense.
  bool get hasSeverity => const {
    poop,
    urine,
    vomit,
    cough,
    lethargy,
    appetiteLoss,
  }.contains(this);

  RecordCategory get category => switch (this) {
    vaccine ||
    dewormInternal ||
    dewormExternal ||
    heartworm ||
    grooming ||
    checkup ||
    custom => RecordCategory.care,
    medication => RecordCategory.medication,
    feeding || water || poop || urine || note => RecordCategory.daily,
    vomit || cough || lethargy || appetiteLoss => RecordCategory.symptom,
    vetVisit => RecordCategory.vet,
  };
}

/// Region used to pick care-schedule templates.
enum CareRegion { tw, us }

/// Timeline filter groups.
enum RecordCategory { care, medication, daily, symptom, vet, weight }

enum Severity { mild, moderate, severe }

enum WeightUnit {
  kg,
  lb;

  static const gramsPerPound = 453.59237;

  double fromGrams(int grams) =>
      this == kg ? grams / 1000 : grams / gramsPerPound;

  int toGrams(double value) =>
      (this == kg ? value * 1000 : value * gramsPerPound).round();
}

/// Quick-log buttons the user can choose from, in display order.
const kQuickLogTypes = <RecordType>[
  RecordType.feeding,
  RecordType.water,
  RecordType.poop,
  RecordType.urine,
  RecordType.vomit,
  RecordType.medication,
  RecordType.cough,
  RecordType.lethargy,
  RecordType.appetiteLoss,
  RecordType.note,
];

const kDefaultQuickLogTypes = <RecordType>{
  RecordType.feeding,
  RecordType.water,
  RecordType.poop,
  RecordType.vomit,
  RecordType.medication,
  RecordType.note,
};
