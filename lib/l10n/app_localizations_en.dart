// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pawdian';

  @override
  String get navHome => 'Home';

  @override
  String get navPets => 'Pets';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDone => 'Done';

  @override
  String get actionOk => 'OK';

  @override
  String get notSet => 'Not set';

  @override
  String get homeNoPetsTitle => 'Welcome to Pawdian';

  @override
  String get homeNoPetsBody =>
      'Add your first pet to get vaccine, deworming and medication reminders.';

  @override
  String get addPet => 'Add pet';

  @override
  String get homeEmptyTitle => 'Nothing due today';

  @override
  String get homeEmptyBody => 'No reminders in the next 7 days.';

  @override
  String get homeOverdue => 'Overdue';

  @override
  String get homeToday => 'Today';

  @override
  String get homeUpcoming => 'Next 7 days';

  @override
  String reminderCompletedSnack(String title) {
    return 'Marked \"$title\" as done';
  }

  @override
  String get petsEmptyTitle => 'No pets yet';

  @override
  String get petsEmptyBody => 'Your pets will appear here.';

  @override
  String get petsArchivedSection => 'Archived';

  @override
  String get petFormNewTitle => 'New pet';

  @override
  String get petFormEditTitle => 'Edit pet';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameRequired => 'Please enter a name';

  @override
  String get fieldSpecies => 'Species';

  @override
  String get fieldBreed => 'Breed';

  @override
  String get fieldSex => 'Sex';

  @override
  String get fieldNeutered => 'Spayed / neutered';

  @override
  String get fieldBirthDate => 'Birthday';

  @override
  String get fieldBirthDateEstimated => 'Estimated date';

  @override
  String get fieldMicrochip => 'Microchip number';

  @override
  String get fieldColor => 'Color / markings';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldVetName => 'Vet clinic';

  @override
  String get fieldVetPhone => 'Vet phone';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get speciesDog => 'Dog';

  @override
  String get speciesCat => 'Cat';

  @override
  String get speciesRabbit => 'Rabbit';

  @override
  String get speciesRodent => 'Small rodent';

  @override
  String get speciesBird => 'Bird';

  @override
  String get speciesReptile => 'Reptile';

  @override
  String get speciesOther => 'Other';

  @override
  String get sexUnknown => 'Unknown';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String petAgeYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yrs',
      one: '1 yr',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months mo',
      one: '1 mo',
      zero: '',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String petAgeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String petAgeEstimated(String age) {
    return 'about $age';
  }

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get sectionRecentRecords => 'Recent care';

  @override
  String get noReminders => 'No reminders yet';

  @override
  String get noRecords => 'Nothing recorded yet';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get applyTemplates => 'Suggested schedule';

  @override
  String get archivePet => 'Archive';

  @override
  String get unarchivePet => 'Restore';

  @override
  String archivePetConfirm(String name) {
    return 'Archive $name? Reminders stop, records are kept.';
  }

  @override
  String get deletePet => 'Delete pet';

  @override
  String deletePetConfirm(String name) {
    return 'Delete $name and all of its records? This cannot be undone.';
  }

  @override
  String get archivedBadge => 'Archived';

  @override
  String nextDue(String date) {
    return 'Next: $date';
  }

  @override
  String get reminderFinished => 'Finished';

  @override
  String get reminderPaused => 'Paused';

  @override
  String get reminderTypeVaccine => 'Vaccine';

  @override
  String get reminderTypeDewormInternal => 'Internal deworming';

  @override
  String get reminderTypeDewormExternal => 'Flea & tick prevention';

  @override
  String get reminderTypeHeartworm => 'Heartworm prevention';

  @override
  String get reminderTypeMedication => 'Medication';

  @override
  String get reminderTypeGrooming => 'Bath / grooming';

  @override
  String get reminderTypeCheckup => 'Health check-up';

  @override
  String get reminderTypeCustom => 'Other';

  @override
  String get repeatOnce => 'Once';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String get unitNone => 'Does not repeat';

  @override
  String get unitDay => 'day(s)';

  @override
  String get unitWeek => 'week(s)';

  @override
  String get unitMonth => 'month(s)';

  @override
  String get unitYear => 'year(s)';

  @override
  String get reminderFormNewTitle => 'New reminder';

  @override
  String get reminderFormEditTitle => 'Edit reminder';

  @override
  String get fieldReminderType => 'Type';

  @override
  String get fieldTitleOptional => 'Title (optional)';

  @override
  String get fieldNextDate => 'Next due date';

  @override
  String get fieldTimes => 'Reminder times';

  @override
  String get addTime => 'Add time';

  @override
  String get fieldRepeat => 'Repeat';

  @override
  String get fieldRepeatEvery => 'Every';

  @override
  String get fieldAdvanceNotice => 'Early notice';

  @override
  String get advanceNone => 'None';

  @override
  String advanceDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get fieldActive => 'Active';

  @override
  String get deleteReminderConfirm => 'Delete this reminder?';

  @override
  String get templatesTitle => 'Suggested schedule';

  @override
  String templatesIntro(String species, String region) {
    return 'Common care intervals ($species, $region). Tick the ones that apply and set each next due date.';
  }

  @override
  String get templatesDisclaimer =>
      'General guidance only, not medical advice. Follow your vet\'s instructions.';

  @override
  String templatesApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count reminders',
      one: 'Add 1 reminder',
      zero: 'Add reminders',
    );
    return '$_temp0';
  }

  @override
  String get templatesSkip => 'Skip';

  @override
  String get templatesNone =>
      'No suggested schedule for this species. You can add reminders yourself.';

  @override
  String get templateRabies => 'Rabies vaccine';

  @override
  String get templateCoreVaccineDog => 'Core vaccine (DHPP)';

  @override
  String get templateCoreVaccineCat => 'Core vaccine (FVRCP)';

  @override
  String get settingsRegion => 'Care schedule region';

  @override
  String get regionAuto => 'Automatic';

  @override
  String get regionTw => 'Taiwan';

  @override
  String get regionUs => 'United States';

  @override
  String get settingsDefaultTime => 'Default reminder time';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notifAllowed => 'Notifications allowed';

  @override
  String get notifBlocked => 'Notifications off — tap to allow';

  @override
  String get exactAllowed => 'On-time alarms allowed';

  @override
  String get exactBlocked => 'On-time alarms off — tap to allow';

  @override
  String get reminderHelpTitle => 'Reminders not showing up?';

  @override
  String get reminderHelpIntro =>
      'Some phones stop apps in the background to save battery, which can delay or block reminders. Please check:';

  @override
  String get reminderHelpStep1 =>
      'Allow notifications and on-time alarms for Pawdian (see Settings above).';

  @override
  String get reminderHelpStep2 =>
      'Set Pawdian\'s battery usage to \"Unrestricted\" (Settings > Apps > Pawdian > Battery).';

  @override
  String get reminderHelpStep3 =>
      'On Xiaomi, OPPO, vivo, Huawei and similar phones, also enable \"Autostart\" for Pawdian.';

  @override
  String get reminderHelpStep4 =>
      'Open Pawdian once after restarting your phone so reminders are rescheduled.';

  @override
  String get debugPro => 'Developer: Pro unlocked';

  @override
  String get proTitle => 'Pawdian Pro';

  @override
  String get proMultiplePets =>
      'The free version supports 1 pet. Pawdian Pro unlocks unlimited pets.';

  @override
  String get notifChannelName => 'Care reminders';

  @override
  String get notifChannelDescription =>
      'Vaccine, deworming and medication reminders';

  @override
  String notifTitle(String pet, String title) {
    return '$pet: $title';
  }

  @override
  String get notifBodyDue => 'It\'s time. Tap Done when finished.';

  @override
  String notifBodyAdvance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get notifBodySnoozed => 'Reminder again';

  @override
  String get notifActionDone => 'Done';

  @override
  String get notifActionSnooze => 'In 1 hour';

  @override
  String get notifActionTomorrow => 'Tomorrow';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseTraditional => '繁體中文';

  @override
  String get recordTypeFeeding => 'Feeding';

  @override
  String get recordTypeWater => 'Water';

  @override
  String get recordTypePoop => 'Poop';

  @override
  String get recordTypeUrine => 'Pee';

  @override
  String get recordTypeVomit => 'Vomit';

  @override
  String get recordTypeCough => 'Cough';

  @override
  String get recordTypeLethargy => 'Low energy';

  @override
  String get recordTypeAppetiteLoss => 'Poor appetite';

  @override
  String get recordTypeVetVisit => 'Vet visit';

  @override
  String get recordTypeNote => 'Note';

  @override
  String get severityNone => 'Not specified';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryCare => 'Care';

  @override
  String get categoryMedication => 'Medication';

  @override
  String get categoryDaily => 'Daily';

  @override
  String get categorySymptom => 'Symptoms';

  @override
  String get categoryVet => 'Vet';

  @override
  String get categoryWeight => 'Weight';

  @override
  String get quickLogTitle => 'Quick log';

  @override
  String quickLogDone(String type, String pet) {
    return 'Logged $type for $pet';
  }

  @override
  String get quickLogAddNote => 'Add details';

  @override
  String get quickLogPickPet => 'Which pet?';

  @override
  String get addRecord => 'Add record';

  @override
  String get recordFormNewTitle => 'New record';

  @override
  String get recordFormEditTitle => 'Edit record';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldSeverity => 'Severity';

  @override
  String get fieldDiagnosis => 'Diagnosis / summary';

  @override
  String get fieldCost => 'Cost';

  @override
  String get fieldNextVisit => 'Next visit';

  @override
  String get revisitReminderTitle => 'Follow-up visit';

  @override
  String get deleteRecordConfirm => 'Delete this record?';

  @override
  String costLabel(String amount) {
    return 'Cost $amount';
  }

  @override
  String get weightTitle => 'Weight';

  @override
  String get addWeight => 'Add weight';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get weightInvalid => 'Enter a valid weight';

  @override
  String get weightEmpty => 'No weight records yet';

  @override
  String weightLatest(String value) {
    return 'Latest $value';
  }

  @override
  String weightEntryTitle(String value) {
    return 'Weight $value';
  }

  @override
  String get rangeMonth => '1M';

  @override
  String get range3Months => '3M';

  @override
  String get rangeYear => '1Y';

  @override
  String get rangeAll => 'All';

  @override
  String get proWeightHistory =>
      'The free version shows the last 3 months. Pawdian Pro unlocks the full history.';

  @override
  String get deleteWeightConfirm => 'Delete this weight entry?';

  @override
  String get settingsWeightUnit => 'Weight unit';

  @override
  String get settingsQuickLog => 'Quick log buttons';

  @override
  String get quickLogReorderHint =>
      'Tick the buttons to show. Drag the handle to change the order.';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get viewAll => 'View all';

  @override
  String get searchHint => 'Search notes';

  @override
  String get timelineEmpty => 'No matching records';

  @override
  String get proLearnMore => 'About Pro';

  @override
  String get proHeadline => 'Unlock everything for your pets';

  @override
  String get proFeaturePets => 'Unlimited pets';

  @override
  String get proFeatureHistory => 'Full weight history';

  @override
  String get proFeatureReport => 'Vet report PDF';

  @override
  String get proFeatureAttachments => 'Unlimited photos per record';

  @override
  String get proFeatureCsv => 'Export data to CSV';

  @override
  String get proYearly => 'Yearly';

  @override
  String get proMonthly => 'Monthly';

  @override
  String get proLifetime => 'Lifetime (one-time)';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proUnavailable =>
      'Google Play is not available right now. Please try again later.';

  @override
  String get proActive => 'Pawdian Pro is active. Thank you for your support!';

  @override
  String get proPending => 'Payment is pending…';

  @override
  String proFailed(String message) {
    return 'Purchase failed: $message';
  }

  @override
  String get proRestored => 'Purchases restored';

  @override
  String get proNothingToRestore =>
      'No Pro purchase found for this Google account';

  @override
  String get proTerms =>
      'Subscriptions renew automatically until cancelled. You can cancel anytime in Google Play > Subscriptions.';

  @override
  String get settingsPro => 'Pawdian Pro';

  @override
  String get settingsProActive => 'Active';

  @override
  String get settingsProFree => 'Free version';

  @override
  String get proAttachments =>
      'The free version allows 1 photo per record. Pawdian Pro unlocks unlimited photos.';

  @override
  String get proReport => 'Vet report PDF is a Pawdian Pro feature.';

  @override
  String get proCsv => 'CSV export is a Pawdian Pro feature.';

  @override
  String get settingsData => 'Data';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupIntro =>
      'Your data is stored only on this phone. If Google backup is on, Android also backs up records and settings to your Google account (photos excluded). For a complete copy including photos, create a backup file and keep it somewhere safe.';

  @override
  String get backupCreateShare => 'Create backup and share';

  @override
  String get backupCreateSave => 'Create backup and save to files';

  @override
  String get backupRestore => 'Restore from backup file';

  @override
  String get backupRestoreConfirm =>
      'Restoring replaces ALL current data on this phone with the backup. This cannot be undone. Continue?';

  @override
  String get backupRestoreAction => 'Replace data';

  @override
  String get backupDone => 'Backup created';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupInvalid => 'This is not a valid Pawdian backup file';

  @override
  String get backupTooNew =>
      'This backup was made by a newer version of Pawdian. Please update the app first.';

  @override
  String backupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupNever => 'No backup file created yet';

  @override
  String get backupStale => 'It has been over 30 days since your last backup';

  @override
  String get csvExport => 'Export CSV';

  @override
  String get csvExportHint =>
      'Records and weights of all pets, for Excel or Google Sheets';

  @override
  String get attachmentsTitle => 'Photos';

  @override
  String get attachmentAddGallery => 'Choose photo';

  @override
  String get attachmentAddCamera => 'Take photo';

  @override
  String get reportTitle => 'Vet report';

  @override
  String get reportRange => 'Period';

  @override
  String reportDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String reportGenerated(String date) {
    return 'Generated $date';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'Period: $from – $to';
  }

  @override
  String get reportProfile => 'Profile';

  @override
  String get reportWeights => 'Weight';

  @override
  String get reportSymptoms => 'Symptoms';

  @override
  String get reportMedication => 'Medication';

  @override
  String get reportCare => 'Vaccines, deworming and care';

  @override
  String get reportVetVisits => 'Vet visits';

  @override
  String get reportNone => 'None recorded';

  @override
  String get reportColDate => 'Date';

  @override
  String get reportColItem => 'Item';

  @override
  String get reportColDetails => 'Details';

  @override
  String get reportDisclaimer =>
      'Recorded by the owner with Pawdian. For reference only; not a medical record.';

  @override
  String get widgetNoReminders => 'No upcoming reminders';

  @override
  String get widgetOverdue => 'Overdue';
}
