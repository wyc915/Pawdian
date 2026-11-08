# Google Play 商店資料

所有素材在 `store/`：

| 素材 | 檔案 | 規格 |
|---|---|---|
| App 圖示 | `store/icon-512.png` | 512×512 PNG |
| 主題圖片（Feature graphic） | `store/feature-graphic-1024x500.png` | 1024×500 PNG |
| 手機截圖（繁中） | `store/screenshots/zh_*.png` | 1200×2400（2:1） |
| 手機截圖（英文） | `store/screenshots/en_*.png` | 1200×2400（2:1） |

圖示與主題圖片由 `tool/generate_store_assets_test.dart` 產生（目前為草稿）；截圖用 debug 版「Developer: load demo data」載入示範資料後拍攝，再執行同一支工具補邊。

---

## 繁體中文（zh-TW，預設語言）

**應用程式名稱**（30 字元內）
```
Pawdian 毛孩守護：寵物健康提醒
```

**簡短說明**（80 字元內）
```
疫苗、驅蟲、心絲蟲、餵藥準時提醒，體重與健康紀錄一手掌握。不用註冊，資料只存在手機。
```

**完整說明**（4000 字元內）
```
Pawdian 毛孩守護，幫你記住毛孩的每一次疫苗、驅蟲與用藥。

🐾 不用註冊，打開就能用
不需要帳號、不收集個人資料，所有紀錄只存在你的手機上。

⏰ 準時的照護提醒
・疫苗、體內／體外驅蟲、心絲蟲預防、用藥、洗澡美容、健康檢查
・每天、每週、每月、每年重複，一天可設定多個餵藥時間
・提前通知，從通知直接按「完成」、「1 小時後」、「明天」
・完成後自動排好下一次：疫苗從實際施打日重新起算

📋 一鍵建立建議排程
新增寵物時，依台灣或美國常見的照護頻率，勾選就能建立提醒。（僅供參考，實際頻率請依獸醫指示）

📝 日常紀錄，2 秒完成
餵食、喝水、便便、嘔吐、用藥……首頁一鍵記錄；症狀可標示程度，看診可記錄診斷、花費並設定回診提醒。

📈 體重曲線與時間軸
體重變化一目了然；所有紀錄依日期排列，可分類篩選、搜尋備註。

🏥 就醫報告 PDF（Pro）
一鍵整理近 30／90／365 天的體重、症狀、用藥與看診紀錄，看獸醫時直接給醫生看。

💾 備份與還原
建立包含照片的完整備份檔，存到雲端硬碟或寄給自己，換手機也不怕。

🏠 桌面小工具
在手機桌面直接看到下一個提醒。

Pawdian Pro
・不限寵物數量
・完整體重歷史
・就醫報告 PDF
・每筆紀錄不限照片
・匯出 CSV
提供月訂閱、年訂閱與終身買斷。訂閱可隨時在 Google Play 取消。

注意：本 App 不提供醫療建議，寵物的健康問題請諮詢獸醫師。
```

---

## English (en-US)

**App name**
```
Pawdian: Pet Health Reminders
```

**Short description**
```
Vaccine, deworming & medication reminders plus weight and health logs. No sign-up.
```

**Full description**
```
Pawdian helps you remember every vaccine, deworming dose and medication for your pets.

🐾 No sign-up, no tracking
No account needed and no personal data collected. Everything stays on your phone.

⏰ On-time care reminders
• Vaccines, internal/external deworming, heartworm prevention, medication, grooming and check-ups
• Daily, weekly, monthly or yearly repeats, with several doses per day
• Early notices and Done / In 1 hour / Tomorrow buttons right in the notification
• The next dose is scheduled automatically when you mark one done

📋 Suggested care schedules
Add a pet and pick from common care intervals for dogs and cats in one tap. (General guidance only; follow your vet.)

📝 Two-second daily logs
Log feeding, water, poop, vomiting, medication and more from the home screen. Rate symptom severity, and record vet visits with diagnosis, cost and a follow-up reminder.

📈 Weight chart and timeline
See weight trends at a glance and browse every record by date with filters and search.

🏥 Vet report PDF (Pro)
Summarise weight, symptoms, medication and vet visits for the last 30, 90 or 365 days and share it with your vet.

💾 Backup & restore
Create a complete backup file (photos included) and keep it in your cloud drive or email.

🏠 Home screen widget
See your next reminder right on your home screen.

Pawdian Pro
• Unlimited pets
• Full weight history
• Vet report PDF
• Unlimited photos per record
• CSV export
Monthly, yearly and lifetime options. Cancel subscriptions anytime in Google Play.

Note: Pawdian does not provide medical advice. Always consult your veterinarian.
```

---

## 其他設定

| 項目 | 建議填寫 |
|---|---|
| 應用程式類別 | 生活品味（Lifestyle）。另可考慮「醫療」，但審查較嚴，不建議 |
| 標記 | 寵物、提醒、健康 |
| 聯絡電子郵件 | `CONTACT_EMAIL`（必填，會公開顯示） |
| 網站 | 隱私權網站首頁網址 |
| 隱私權政策網址 | `.../privacy.html` |
| 廣告 | 否，不含廣告 |
| 應用程式存取權 | 所有功能不需登入即可使用 |
| 目標年齡層 | 18 歲以上（避免適用兒童與家庭政策） |
| 內容分級問卷 | 無暴力、色情、賭博、使用者互動或分享位置；預期分級為「普遍級／Everyone」 |
| 健康應用程式聲明 | 若被問到，說明為寵物照護紀錄，不提供人類醫療功能 |

---

## 資料安全性表單（Data safety）建議答案

依 Google 的定義，資料只在裝置上處理、未傳送出裝置，不算「收集」。請以填寫當時的 Play Console 說明為準。

| 問題 | 答案 |
|---|---|
| 應用程式是否會收集或分享任何必要的使用者資料類型？ | **否** |
| 資料是否經過加密傳輸？ | 不適用（不傳輸資料） |
| 使用者能否要求刪除資料？ | 資料只在裝置上，可在 App 內刪除，或解除安裝即刪除 |

說明：
- 照片：只在裝置上儲存，不上傳 → 不算收集。
- 購買：由 Google Play 處理，App 不取得付款資料 → 不算收集。
- Android 系統備份：由作業系統依使用者設定執行，備份到使用者自己的 Google 帳號，開發者無法存取。
- 沒有使用任何分析、廣告或當機回報 SDK。
