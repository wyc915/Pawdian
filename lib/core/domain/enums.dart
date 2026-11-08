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

/// Kinds of care records. M1 only writes records from completed reminders;
/// daily quick-log kinds arrive in M2.
enum RecordType {
  vaccine,
  dewormInternal,
  dewormExternal,
  heartworm,
  medication,
  grooming,
  checkup,
  custom;

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
}

/// Region used to pick care-schedule templates.
enum CareRegion { tw, us }
