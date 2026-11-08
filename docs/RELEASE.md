# 上架操作指南

依序完成即可把 Pawdian 上架到 Google Play。標示 **[你]** 的步驟需要你本人操作（帳號、付款、密碼、法律聲明）。

---

## 1. 建立上傳金鑰 [你]

上傳金鑰用來證明 App 是你發布的。**金鑰檔和密碼一旦遺失就無法更新 App**（使用 Play App 簽署時可向 Google 申請重設，但很麻煩），請備份到安全的地方，**不要放進 Git**。

1. 開啟 PowerShell，執行（密碼會在執行時詢問，請自己設定並記下）：
   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v `
     -keystore F:\dev\pawdian-keys\upload-keystore.jks `
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   金鑰放在專案資料夾外面（`F:\dev\pawdian-keys\`）比較安全。
2. 建立 `F:\dev\pawdian\android\key.properties`（已被 `.gitignore` 排除）：
   ```properties
   storePassword=你設定的密碼
   keyPassword=你設定的密碼
   keyAlias=upload
   storeFile=F:/dev/pawdian-keys/upload-keystore.jks
   ```
3. 把 `upload-keystore.jks` 和密碼另外備份（例如密碼管理器 + 隨身碟）。

沒有 `key.properties` 時，release 版會改用 debug 金鑰，只能在本機測試，Google Play 會拒收。

## 2. 建置上架檔

```bash
cd F:/dev/pawdian
flutter build appbundle --release
```

產出：`build/app/outputs/bundle/release/app-release.aab`

每次上傳新版前，把 `pubspec.yaml` 的 `version: 1.0.0+1` 往上加：`+` 後面的數字（versionCode）**每次都必須比上一版大**。

## 3. 發布隱私權政策網站 [你]

Google Play 要求公開的隱私權政策網址。網站檔案在 `site/`（首頁、隱私權政策、使用條款）。

1. 先把三個 HTML 中的 `CONTACT_EMAIL` 換成你要公開的聯絡信箱（`docs/STORE_LISTING.md` 也要換）。
2. 選一種免費方式發布：
   - **GitHub Pages**：建立一個公開的儲存庫（例如 `wyc915/pawdian-site`），把 `site/` 內的檔案放到根目錄，在 Settings > Pages 選 `main` 分支。網址會是 `https://wyc915.github.io/pawdian-site/`。
   - 若 `wyc915/Pawdian` 本身是公開儲存庫，也可以直接在它的 Pages 設定選 `/site` 以外的方式（GitHub Pages 只支援根目錄或 `/docs`，需另外調整），所以建議用獨立儲存庫。
3. 建議請熟悉法規的人看過條款內容；目前內容依 App 的實際行為撰寫，但不是法律意見。

## 4. 建立 Google Play 開發者帳號 [你]

1. 到 https://play.google.com/console 註冊（一次性 US$25），選「個人」。
2. 完成身分驗證（需要證件，通常數天）。
3. 驗證手機號碼與電子郵件。

## 5. 在 Play Console 建立 App [你]

1. 建立應用程式：名稱 `Pawdian`、預設語言「中文（台灣）」、類型「應用程式」、「免費」（含應用程式內購）。
2. 依 `docs/STORE_LISTING.md` 填寫：商店資訊（中英）、圖示、主題圖片、截圖、類別、聯絡資訊、隱私權政策網址。
3. 「應用程式內容」逐項完成：隱私權政策、廣告（無）、應用程式存取權（不需登入）、內容分級問卷、目標對象（18 歲以上）、資料安全性、新聞應用程式（否）、政府應用程式（否）、金融功能（無）、健康（寵物照護，非人類醫療）。
4. 「應用程式完整性」：使用 **Play 應用程式簽署**（預設），上傳金鑰用步驟 1 建立的。

## 6. 建立 Pro 商品 [你]

到「營利 > 產品」：

| 類型 | 產品 ID | 建議價格 | 備註 |
|---|---|---|---|
| 訂閱 | `pawdian_pro_yearly` | NT$490 ／ US$14.99 | 基本方案：每年自動續訂；可加 7 天免費試用優惠 |
| 訂閱 | `pawdian_pro_monthly` | NT$90 ／ US$2.99 | 基本方案：每月自動續訂 |
| 一次性產品 | `pawdian_pro_lifetime` | NT$1,290 ／ US$39.99 | |

**產品 ID 必須和程式完全一致**（`lib/core/billing/billing.dart`）。另外到「設定 > 授權測試」加入你自己的 Google 帳號，測試購買不會真的扣款。

## 7. 封閉測試（新個人帳號必要）[你]

2023-11-13 之後註冊的個人帳號，必須先完成：**至少 12 位測試者、連續 14 天**參與封閉測試，才能申請正式版。

1. 「測試 > 封閉測試」建立測試群組，加入測試者的 Google 帳號（Gmail）。
2. 上傳 `app-release.aab`，填寫版本資訊，送出審查。
3. 審查通過後，把「加入測試」連結傳給測試者；他們要在 Play 商店安裝並**保持加入 14 天**。
4. 測試期間請測試者特別試：通知是否準時（不同品牌手機）、通知上的按鈕、重開機後提醒、備份還原、購買（授權測試帳號）。
5. 期滿後在「資訊主頁」申請正式版存取權，回答問卷（測試心得、修正了什麼）。

## 8. 正式發布 [你]

1. 申請通過後，「正式版」建立新版本，上傳同一個或更新的 aab。
2. 選擇發布國家／地區（建議先台灣、美國，再擴大）。
3. 送審，通常數小時到數天。

---

## 發布前檢查清單

- [ ] `pubspec.yaml` 版本號已更新
- [ ] `flutter analyze` 無問題、`flutter test` 全部通過
- [ ] release 版在實機測過：新增寵物、提醒準時跳出、通知按鈕、PDF、備份還原
- [ ] 隱私權政策網址可開啟，`CONTACT_EMAIL` 已替換
- [ ] Play Console 商品 ID 與程式一致，授權測試帳號可購買
- [ ] 截圖與商店文案是最新版本
