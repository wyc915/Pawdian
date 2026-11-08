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
