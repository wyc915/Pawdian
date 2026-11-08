import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// App name.
  ///
  /// In en, this message translates to:
  /// **'Pawdian'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get navPets;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @homeNoPetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pawdian'**
  String get homeNoPetsTitle;

  /// No description provided for @homeNoPetsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first pet to get vaccine, deworming and medication reminders.'**
  String get homeNoPetsBody;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add pet'**
  String get addPet;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No reminders in the next 7 days.'**
  String get homeEmptyBody;

  /// No description provided for @homeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get homeOverdue;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get homeUpcoming;

  /// No description provided for @reminderCompletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Marked \"{title}\" as done'**
  String reminderCompletedSnack(String title);

  /// No description provided for @petsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pets yet'**
  String get petsEmptyTitle;

  /// No description provided for @petsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your pets will appear here.'**
  String get petsEmptyBody;

  /// No description provided for @petsArchivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get petsArchivedSection;

  /// No description provided for @petFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New pet'**
  String get petFormNewTitle;

  /// No description provided for @petFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit pet'**
  String get petFormEditTitle;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get fieldNameRequired;

  /// No description provided for @fieldSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get fieldSpecies;

  /// No description provided for @fieldBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get fieldBreed;

  /// No description provided for @fieldSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get fieldSex;

  /// No description provided for @fieldNeutered.
  ///
  /// In en, this message translates to:
  /// **'Spayed / neutered'**
  String get fieldNeutered;

  /// No description provided for @fieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get fieldBirthDate;

  /// No description provided for @fieldBirthDateEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated date'**
  String get fieldBirthDateEstimated;

  /// No description provided for @fieldMicrochip.
  ///
  /// In en, this message translates to:
  /// **'Microchip number'**
  String get fieldMicrochip;

  /// No description provided for @fieldColor.
  ///
  /// In en, this message translates to:
  /// **'Color / markings'**
  String get fieldColor;

  /// No description provided for @fieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// No description provided for @fieldVetName.
  ///
  /// In en, this message translates to:
  /// **'Vet clinic'**
  String get fieldVetName;

  /// No description provided for @fieldVetPhone.
  ///
  /// In en, this message translates to:
  /// **'Vet phone'**
  String get fieldVetPhone;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @speciesDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get speciesDog;

  /// No description provided for @speciesCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get speciesCat;

  /// No description provided for @speciesRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get speciesRabbit;

  /// No description provided for @speciesRodent.
  ///
  /// In en, this message translates to:
  /// **'Small rodent'**
  String get speciesRodent;

  /// No description provided for @speciesBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get speciesBird;

  /// No description provided for @speciesReptile.
  ///
  /// In en, this message translates to:
  /// **'Reptile'**
  String get speciesReptile;

  /// No description provided for @speciesOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get speciesOther;

  /// No description provided for @sexUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sexUnknown;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @petAgeYearsMonths.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =1{1 yr} other{{years} yrs}} {months, plural, =0{} =1{1 mo} other{{months} mo}}'**
  String petAgeYearsMonths(int years, int months);

  /// No description provided for @petAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month} other{{months} months}}'**
  String petAgeMonths(int months);

  /// No description provided for @petAgeEstimated.
  ///
  /// In en, this message translates to:
  /// **'about {age}'**
  String petAgeEstimated(String age);

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get sectionReminders;

  /// No description provided for @sectionRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent care'**
  String get sectionRecentRecords;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noReminders;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get noRecords;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @applyTemplates.
  ///
  /// In en, this message translates to:
  /// **'Suggested schedule'**
  String get applyTemplates;

  /// No description provided for @archivePet.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archivePet;

  /// No description provided for @unarchivePet.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get unarchivePet;

  /// No description provided for @archivePetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive {name}? Reminders stop, records are kept.'**
  String archivePetConfirm(String name);

  /// No description provided for @deletePet.
  ///
  /// In en, this message translates to:
  /// **'Delete pet'**
  String get deletePet;

  /// No description provided for @deletePetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and all of its records? This cannot be undone.'**
  String deletePetConfirm(String name);

  /// No description provided for @archivedBadge.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedBadge;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String nextDue(String date);

  /// No description provided for @reminderFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get reminderFinished;

  /// No description provided for @reminderPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get reminderPaused;

  /// No description provided for @reminderTypeVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get reminderTypeVaccine;

  /// No description provided for @reminderTypeDewormInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal deworming'**
  String get reminderTypeDewormInternal;

  /// No description provided for @reminderTypeDewormExternal.
  ///
  /// In en, this message translates to:
  /// **'Flea & tick prevention'**
  String get reminderTypeDewormExternal;

  /// No description provided for @reminderTypeHeartworm.
  ///
  /// In en, this message translates to:
  /// **'Heartworm prevention'**
  String get reminderTypeHeartworm;

  /// No description provided for @reminderTypeMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get reminderTypeMedication;

  /// No description provided for @reminderTypeGrooming.
  ///
  /// In en, this message translates to:
  /// **'Bath / grooming'**
  String get reminderTypeGrooming;

  /// No description provided for @reminderTypeCheckup.
  ///
  /// In en, this message translates to:
  /// **'Health check-up'**
  String get reminderTypeCheckup;

  /// No description provided for @reminderTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reminderTypeCustom;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @repeatEveryDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryDays(int count);

  /// No description provided for @repeatEveryWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatEveryWeeks(int count);

  /// No description provided for @repeatEveryMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String repeatEveryMonths(int count);

  /// No description provided for @repeatEveryYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String repeatEveryYears(int count);

  /// No description provided for @unitNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get unitNone;

  /// No description provided for @unitDay.
  ///
  /// In en, this message translates to:
  /// **'day(s)'**
  String get unitDay;

  /// No description provided for @unitWeek.
  ///
  /// In en, this message translates to:
  /// **'week(s)'**
  String get unitWeek;

  /// No description provided for @unitMonth.
  ///
  /// In en, this message translates to:
  /// **'month(s)'**
  String get unitMonth;

  /// No description provided for @unitYear.
  ///
  /// In en, this message translates to:
  /// **'year(s)'**
  String get unitYear;

  /// No description provided for @reminderFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get reminderFormNewTitle;

  /// No description provided for @reminderFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderFormEditTitle;

  /// No description provided for @fieldReminderType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldReminderType;

  /// No description provided for @fieldTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get fieldTitleOptional;

  /// No description provided for @fieldNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next due date'**
  String get fieldNextDate;

  /// No description provided for @fieldTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get fieldTimes;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @fieldRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get fieldRepeat;

  /// No description provided for @fieldRepeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get fieldRepeatEvery;

  /// No description provided for @fieldAdvanceNotice.
  ///
  /// In en, this message translates to:
  /// **'Early notice'**
  String get fieldAdvanceNotice;

  /// No description provided for @advanceNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get advanceNone;

  /// No description provided for @advanceDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day before} other{{count} days before}}'**
  String advanceDays(int count);

  /// No description provided for @fieldActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get fieldActive;

  /// No description provided for @deleteReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get deleteReminderConfirm;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested schedule'**
  String get templatesTitle;

  /// No description provided for @templatesIntro.
  ///
  /// In en, this message translates to:
  /// **'Common care intervals for a {species} ({region}). Tick what applies and set each next due date.'**
  String templatesIntro(String species, String region);

  /// No description provided for @templatesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General guidance only, not medical advice. Follow your vet\'s instructions.'**
  String get templatesDisclaimer;

  /// No description provided for @templatesApply.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add reminders} =1{Add 1 reminder} other{Add {count} reminders}}'**
  String templatesApply(int count);

  /// No description provided for @templatesSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get templatesSkip;

  /// No description provided for @templatesNone.
  ///
  /// In en, this message translates to:
  /// **'No suggested schedule for this species. You can add reminders yourself.'**
  String get templatesNone;

  /// No description provided for @templateRabies.
  ///
  /// In en, this message translates to:
  /// **'Rabies vaccine'**
  String get templateRabies;

  /// No description provided for @templateCoreVaccineDog.
  ///
  /// In en, this message translates to:
  /// **'Core vaccine (DHPP)'**
  String get templateCoreVaccineDog;

  /// No description provided for @templateCoreVaccineCat.
  ///
  /// In en, this message translates to:
  /// **'Core vaccine (FVRCP)'**
  String get templateCoreVaccineCat;

  /// No description provided for @settingsRegion.
  ///
  /// In en, this message translates to:
  /// **'Care schedule region'**
  String get settingsRegion;

  /// No description provided for @regionAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get regionAuto;

  /// No description provided for @regionTw.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get regionTw;

  /// No description provided for @regionUs.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get regionUs;

  /// No description provided for @settingsDefaultTime.
  ///
  /// In en, this message translates to:
  /// **'Default reminder time'**
  String get settingsDefaultTime;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notifAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications allowed'**
  String get notifAllowed;

  /// No description provided for @notifBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications off — tap to allow'**
  String get notifBlocked;

  /// No description provided for @exactAllowed.
  ///
  /// In en, this message translates to:
  /// **'On-time alarms allowed'**
  String get exactAllowed;

  /// No description provided for @exactBlocked.
  ///
  /// In en, this message translates to:
  /// **'On-time alarms off — tap to allow'**
  String get exactBlocked;

  /// No description provided for @reminderHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders not showing up?'**
  String get reminderHelpTitle;

  /// No description provided for @reminderHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'Some phones stop apps in the background to save battery, which can delay or block reminders. Please check:'**
  String get reminderHelpIntro;

  /// No description provided for @reminderHelpStep1.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications and on-time alarms for Pawdian (see Settings above).'**
  String get reminderHelpStep1;

  /// No description provided for @reminderHelpStep2.
  ///
  /// In en, this message translates to:
  /// **'Set Pawdian\'s battery usage to \"Unrestricted\" (Settings > Apps > Pawdian > Battery).'**
  String get reminderHelpStep2;

  /// No description provided for @reminderHelpStep3.
  ///
  /// In en, this message translates to:
  /// **'On Xiaomi, OPPO, vivo, Huawei and similar phones, also enable \"Autostart\" for Pawdian.'**
  String get reminderHelpStep3;

  /// No description provided for @reminderHelpStep4.
  ///
  /// In en, this message translates to:
  /// **'Open Pawdian once after restarting your phone so reminders are rescheduled.'**
  String get reminderHelpStep4;

  /// No description provided for @debugPro.
  ///
  /// In en, this message translates to:
  /// **'Developer: Pro unlocked'**
  String get debugPro;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Pawdian Pro'**
  String get proTitle;

  /// No description provided for @proMultiplePets.
  ///
  /// In en, this message translates to:
  /// **'The free version supports 1 pet. Pawdian Pro (coming soon) unlocks unlimited pets.'**
  String get proMultiplePets;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Care reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Vaccine, deworming and medication reminders'**
  String get notifChannelDescription;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'{pet}: {title}'**
  String notifTitle(String pet, String title);

  /// No description provided for @notifBodyDue.
  ///
  /// In en, this message translates to:
  /// **'It\'s time. Tap Done when finished.'**
  String get notifBodyDue;

  /// No description provided for @notifBodyAdvance.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Due tomorrow} other{Due in {count} days}}'**
  String notifBodyAdvance(int count);

  /// No description provided for @notifBodySnoozed.
  ///
  /// In en, this message translates to:
  /// **'Reminder again'**
  String get notifBodySnoozed;

  /// No description provided for @notifActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notifActionDone;

  /// No description provided for @notifActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'In 1 hour'**
  String get notifActionSnooze;

  /// No description provided for @notifActionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get notifActionTomorrow;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageChineseTraditional;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
