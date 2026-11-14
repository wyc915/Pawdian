import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/enums.dart';
import 'app_language.dart';

/// Region preference: null = automatic (from the device's country).
final careRegionSettingProvider =
    NotifierProvider<CareRegionSetting, CareRegion?>(CareRegionSetting.new);

class CareRegionSetting extends Notifier<CareRegion?> {
  static const _key = 'care_region';

  @override
  CareRegion? build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return CareRegion.values.where((r) => r.name == saved).firstOrNull;
  }

  Future<void> set(CareRegion? region) async {
    state = region;
    final prefs = ref.read(sharedPreferencesProvider);
    if (region == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, region.name);
    }
  }
}

CareRegion regionForCountry(String? countryCode) => switch (countryCode) {
  'TW' => CareRegion.tw,
  _ => CareRegion.us,
};

final effectiveCareRegionProvider = Provider<CareRegion>((ref) {
  final setting = ref.watch(careRegionSettingProvider);
  return setting ??
      regionForCountry(PlatformDispatcher.instance.locale.countryCode);
});

/// Weight unit preference: null = automatic (lb in the US, kg elsewhere).
final weightUnitSettingProvider =
    NotifierProvider<WeightUnitSetting, WeightUnit?>(WeightUnitSetting.new);

class WeightUnitSetting extends Notifier<WeightUnit?> {
  static const _key = 'weight_unit';

  @override
  WeightUnit? build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return WeightUnit.values.where((u) => u.name == saved).firstOrNull;
  }

  Future<void> set(WeightUnit? unit) async {
    state = unit;
    final prefs = ref.read(sharedPreferencesProvider);
    if (unit == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, unit.name);
    }
  }
}

WeightUnit weightUnitForCountry(String? countryCode) =>
    countryCode == 'US' ? WeightUnit.lb : WeightUnit.kg;

final effectiveWeightUnitProvider = Provider<WeightUnit>((ref) {
  return ref.watch(weightUnitSettingProvider) ??
      weightUnitForCountry(PlatformDispatcher.instance.locale.countryCode);
});

/// Which quick-log buttons are shown, in the user's order.
final quickLogTypesProvider =
    NotifierProvider<QuickLogTypesSetting, List<RecordType>>(
      QuickLogTypesSetting.new,
    );

class QuickLogTypesSetting extends Notifier<List<RecordType>> {
  static const _key = 'quick_log_types';
  static const _orderKey = 'quick_log_order';

  static List<RecordType>? _parse(List<String>? names) => names
      ?.map((n) => kQuickLogTypes.where((t) => t.name == n).firstOrNull)
      .nonNulls
      .toList();

  /// Every quick-log type in the user's order; types added in later app
  /// versions go at the end.
  List<RecordType> get order {
    final saved =
        _parse(ref.read(sharedPreferencesProvider).getStringList(_orderKey)) ??
        const [];
    return [
      ...saved.toSet(),
      for (final t in kQuickLogTypes)
        if (!saved.contains(t)) t,
    ];
  }

  Set<RecordType> get _selected =>
      _parse(ref.read(sharedPreferencesProvider).getStringList(_key))
          ?.toSet() ??
      kDefaultQuickLogTypes;

  List<RecordType> _visible(Set<RecordType> selected) => [
    for (final t in order)
      if (selected.contains(t)) t,
  ];

  @override
  List<RecordType> build() => _visible(_selected);

  Future<void> toggle(RecordType type, bool enabled) async {
    final next = {...state};
    enabled ? next.add(type) : next.remove(type);
    state = _visible(next);
    await ref.read(sharedPreferencesProvider).setStringList(_key, [
      for (final t in state) t.name,
    ]);
  }

  /// Moves the item at [oldIndex] of [order] so it ends up at [newIndex].
  Future<void> reorder(int oldIndex, int newIndex) async {
    final next = order;
    next.insert(newIndex, next.removeAt(oldIndex));
    await ref.read(sharedPreferencesProvider).setStringList(_orderKey, [
      for (final t in next) t.name,
    ]);
    state = _visible(state.toSet());
  }
}

/// Default time of day (minutes since midnight) for new reminders.
final defaultReminderTimeProvider = NotifierProvider<DefaultReminderTime, int>(
  DefaultReminderTime.new,
);

class DefaultReminderTime extends Notifier<int> {
  static const _key = 'default_reminder_minute';

  @override
  int build() => ref.read(sharedPreferencesProvider).getInt(_key) ?? 9 * 60;

  Future<void> set(int minuteOfDay) async {
    state = minuteOfDay;
    await ref.read(sharedPreferencesProvider).setInt(_key, minuteOfDay);
  }
}

/// Pro entitlement: true when Google Play reports an active Pro purchase
/// (cached so it also works offline) or, in debug builds, when the developer
/// switch is on. Purchases are verified on device; see BillingController.
final isProProvider = NotifierProvider<ProEntitlement, bool>(
  ProEntitlement.new,
);

class ProEntitlement extends Notifier<bool> {
  static const _debugKey = 'debug_pro_unlocked';
  static const _ownedKey = 'pro_owned';

  bool get _debug =>
      kDebugMode &&
      (ref.read(sharedPreferencesProvider).getBool(_debugKey) ?? false);

  bool get _owned =>
      ref.read(sharedPreferencesProvider).getBool(_ownedKey) ?? false;

  /// The home server edition (web) is the owner's own copy: everything is
  /// included.
  @override
  bool build() => kIsWeb || _debug || _owned;

  /// Called with the store's answer; only a definite answer should be passed
  /// (do not call when the store could not be reached).
  Future<void> setOwned(bool owned) async {
    await ref.read(sharedPreferencesProvider).setBool(_ownedKey, owned);
    state = kIsWeb || _debug || owned;
  }

  Future<void> setDebugUnlocked(bool value) async {
    if (!kDebugMode) return;
    await ref.read(sharedPreferencesProvider).setBool(_debugKey, value);
    state = value || _owned;
  }
}

const kFreePetLimit = 1;
