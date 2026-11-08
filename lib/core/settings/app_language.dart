import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Traditional Chinese. Only Traditional text exists, so every Chinese
/// device locale resolves here and Material widgets also use Traditional.
const kZhHant = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
const kEnglish = Locale('en');

const kSupportedLocales = <Locale>[kEnglish, kZhHant];

/// Maps any device locale onto one of [kSupportedLocales].
Locale resolveAppLocale(Locale? deviceLocale) {
  if (deviceLocale?.languageCode == 'zh') return kZhHant;
  return kEnglish;
}

enum AppLanguage {
  system(null),
  english(kEnglish),
  chineseTraditional(kZhHant);

  const AppLanguage(this.locale);

  /// `null` means follow the device (and Android per-app language setting).
  final Locale? locale;
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() with a real instance'),
);

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

class AppLanguageController extends Notifier<AppLanguage> {
  static const _key = 'app_language';

  @override
  AppLanguage build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return AppLanguage.values.firstWhere(
      (l) => l.name == saved,
      orElse: () => AppLanguage.system,
    );
  }

  Future<void> set(AppLanguage language) async {
    state = language;
    await ref.read(sharedPreferencesProvider).setString(_key, language.name);
  }
}
