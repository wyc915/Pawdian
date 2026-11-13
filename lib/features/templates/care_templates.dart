import '../../core/domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';

/// One suggested reminder. Intervals are common general-practice guidance,
/// NOT medical advice; the UI always shows a disclaimer.
///
/// Sources for every interval: docs/CARE_TEMPLATE_SOURCES.md (checked
/// 2026-11). In short:
/// - Rabies: yearly. Taiwan law (Animal Infectious Disease Control Act §13)
///   requires a yearly dose; in the US 1- or 3-year vaccines exist and the
///   interval follows the label and state law, so yearly is the safe default.
/// - Core vaccines: Taiwan practice is yearly; in the US, AAHA (dogs) and
///   AAHA/AAFP (cats) recommend every 3 years after the 1-year booster.
/// - Heartworm, fleas and ticks: monthly, year-round (CAPC).
/// - Intestinal worms: every 3 months (ESCCAP: at least 4 times a year). In
///   the US monthly heartworm products usually cover them, so it is off by
///   default there.
/// - Check-up: yearly (AAHA/AVMA preventive care).
class CareTemplateItem {
  const CareTemplateItem({
    required this.key,
    required this.type,
    required this.unit,
    this.interval = 1,
    this.advanceNoticeDays = 0,
    this.selectedByDefault = true,
  });

  final String key;
  final ReminderType type;
  final RepeatUnit unit;
  final int interval;
  final int advanceNoticeDays;
  final bool selectedByDefault;

  String title(AppLocalizations l) =>
      templateTitle(l, key) ?? reminderTypeLabel(l, type);

  /// Stored on the reminder: a language-independent template marker
  /// ("tpl:rabies") for named templates, otherwise empty (type label).
  String get storedTitle =>
      kNamedTemplateKeys.contains(key) ? '$kTemplateTitlePrefix$key' : '';
}

const _rabies = CareTemplateItem(
  key: 'rabies',
  type: ReminderType.vaccine,
  unit: RepeatUnit.year,
  advanceNoticeDays: 7,
);
const _heartworm = CareTemplateItem(
  key: 'heartworm',
  type: ReminderType.heartworm,
  unit: RepeatUnit.month,
  advanceNoticeDays: 1,
);
const _external = CareTemplateItem(
  key: 'external',
  type: ReminderType.dewormExternal,
  unit: RepeatUnit.month,
  advanceNoticeDays: 1,
);
const _internal = CareTemplateItem(
  key: 'internal',
  type: ReminderType.dewormInternal,
  unit: RepeatUnit.month,
  interval: 3,
  advanceNoticeDays: 1,
);
const _checkup = CareTemplateItem(
  key: 'checkup',
  type: ReminderType.checkup,
  unit: RepeatUnit.year,
  advanceNoticeDays: 7,
);

List<CareTemplateItem> templatesFor(CareRegion region, Species species) =>
    switch ((region, species)) {
      (CareRegion.tw, Species.dog) => const [
        _rabies,
        CareTemplateItem(
          key: 'coreDog',
          type: ReminderType.vaccine,
          unit: RepeatUnit.year,
          advanceNoticeDays: 7,
        ),
        _heartworm,
        _external,
        _internal,
        _checkup,
      ],
      (CareRegion.tw, Species.cat) => const [
        _rabies,
        CareTemplateItem(
          key: 'coreCat',
          type: ReminderType.vaccine,
          unit: RepeatUnit.year,
          advanceNoticeDays: 7,
        ),
        _external,
        _internal,
        CareTemplateItem(
          key: 'heartworm',
          type: ReminderType.heartworm,
          unit: RepeatUnit.month,
          advanceNoticeDays: 1,
          selectedByDefault: false,
        ),
        _checkup,
      ],
      (CareRegion.us, Species.dog) => const [
        _rabies,
        CareTemplateItem(
          key: 'coreDog',
          type: ReminderType.vaccine,
          unit: RepeatUnit.year,
          interval: 3,
          advanceNoticeDays: 14,
        ),
        _heartworm,
        _external,
        CareTemplateItem(
          key: 'internal',
          type: ReminderType.dewormInternal,
          unit: RepeatUnit.month,
          interval: 3,
          advanceNoticeDays: 1,
          selectedByDefault: false,
        ),
        _checkup,
      ],
      (CareRegion.us, Species.cat) => const [
        _rabies,
        CareTemplateItem(
          key: 'coreCat',
          type: ReminderType.vaccine,
          unit: RepeatUnit.year,
          interval: 3,
          advanceNoticeDays: 14,
        ),
        _external,
        CareTemplateItem(
          key: 'internal',
          type: ReminderType.dewormInternal,
          unit: RepeatUnit.month,
          interval: 3,
          advanceNoticeDays: 1,
          selectedByDefault: false,
        ),
        _checkup,
      ],
      (
        _,
        Species.rabbit || Species.rodent || Species.bird || Species.reptile,
      ) =>
        const [_checkup],
      _ => const [],
    };
