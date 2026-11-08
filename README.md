# Pawdian 毛孩守護

寵物健康紀錄與照護提醒 App：疫苗、驅蟲、心絲蟲預防、用藥提醒，不用註冊、資料只存在手機上。
A pet health tracker with vaccine, deworming and medication reminders. No sign-up; data stays on the device.

- 平台：Android 優先（Flutter，之後同一套程式碼出 iOS 版）
- 語言：繁體中文、English
- 規格書：[docs/SPEC.md](docs/SPEC.md)

## 開發環境

- Flutter stable（目前 3.47.x，Dart 3.13）
- Android Studio（Android SDK 36/37、NDK 28.2）
- Windows 10

## 常用指令

```bash
flutter pub get
dart run build_runner build     # 修改 lib/core/database/tables.dart 後重新產生資料庫程式碼
flutter gen-l10n                # 修改 lib/l10n/*.arb 後重新產生翻譯程式碼
flutter analyze
flutter test
flutter run                     # 在模擬器或實機上執行
flutter build apk --debug
```

## 專案結構

```
lib/
  core/        資料庫、通知、路由、設定、主題等共用基礎
  features/    依功能分資料夾：home、pets、reminders、records、templates、settings
  shared/      共用元件與格式化工具
  l10n/        翻譯檔（app_en.arb、app_zh.arb）
test/          單元測試與畫面流程測試
docs/          產品與技術規格書
```

## 注意事項

- 專案與 Flutter 套件快取放在不同磁碟時，Kotlin 增量編譯會失敗，因此 `android/gradle.properties` 關閉了 `kotlin.incremental`。
- `flutter_local_notifications` 23 需要以 Android API 37 編譯（`compileSdk = 37`）。
- 正式版簽章尚未設定，release 版目前仍用 debug 金鑰，上架前必須更換。
