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

/// Which quick-log buttons are shown (order follows [kQuickLogTypes]).
final quickLogTypesProvider =
    NotifierProvider<QuickLogTypesSetting, List<RecordType>>(
      QuickLogTypesSetting.new,
    );

class QuickLogTypesSetting extends Notifier<List<RecordType>> {
  static const _key = 'quick_log_types';

  @override
  List<RecordType> build() {
    final saved = ref.read(sharedPreferencesProvider).getStringList(_key);
    final selected = saved == null
        ? kDefaultQuickLogTypes
        : saved
              .map((n) => RecordType.values.where((t) => t.name == n).firstOrNull)
              .nonNulls
              .toSet();
    return [for (final t in kQuickLogTypes) if (selected.contains(t)) t];
  }

  Future<void> toggle(RecordType type, bool enabled) async {
    final next = {...state};
    enabled ? next.add(type) : next.remove(type);
    state = [for (final t in kQuickLogTypes) if (next.contains(t)) t];
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key, [for (final t in state) t.name]);
  }
}

/// Default time of day (minutes since midnight) for new reminders.
final defaultReminderTimeProvider =
    NotifierProvider<DefaultReminderTime, int>(DefaultReminderTime.new);

class DefaultReminderTime extends Notifier<int> {
  static const _key = 'default_reminder_minute';

  @override
  int build() => ref.read(sharedPreferencesProvider).getInt(_key) ?? 9 * 60;

  Future<void> set(int minuteOfDay) async {
    state = minuteOfDay;
    await ref.read(sharedPreferencesProvider).setInt(_key, minuteOfDay);
  }
}

/// Pro entitlement. Real purchases arrive in M3; until then only a debug
/// switch can unlock it.
final isProProvider = NotifierProvider<ProEntitlement, bool>(ProEntitlement.new);

class ProEntitlement extends Notifier<bool> {
  static const _debugKey = 'debug_pro_unlocked';

  @override
  bool build() =>
      kDebugMode &&
      (ref.read(sharedPreferencesProvider).getBool(_debugKey) ?? false);

  Future<void> setDebugUnlocked(bool value) async {
    if (!kDebugMode) return;
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_debugKey, value);
  }
}

const kFreePetLimit = 1;
