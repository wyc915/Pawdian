import '../../core/domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/l10n_labels.dart';

/// One suggested reminder. Intervals are common general-practice guidance,
/// NOT medical advice; the UI always shows a disclaimer.
///
/// TODO(before launch): verify every interval against a published source
/// (SPEC section 13, open items).
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

  String title(AppLocalizations l) => switch (key) {
    'rabies' => l.templateRabies,
    'coreDog' => l.templateCoreVaccineDog,
    'coreCat' => l.templateCoreVaccineCat,
    _ => reminderTypeLabel(l, type),
  };

  /// Saved as the reminder title only when it differs from the type label.
  String storedTitle(AppLocalizations l) =>
      title(l) == reminderTypeLabel(l, type) ? '' : title(l);
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
          advanceNoticeDays: 7,
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
          advanceNoticeDays: 7,
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
      (_, Species.rabbit || Species.rodent || Species.bird || Species.reptile) =>
        const [_checkup],
      _ => const [],
    };
