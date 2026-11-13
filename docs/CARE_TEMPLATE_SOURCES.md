# 照護範本頻率與資料來源

`lib/features/templates/care_templates.dart` 的建議頻率依據（2026-11 查證）。範本只是一般性建議，App 內已標示「實際頻率請依獸醫指示」，使用者可以自行修改每個提醒的週期。

| 項目 | 台灣 | 美國 | 依據 |
|---|---|---|---|
| 狂犬病疫苗 | 每年 | 每年（預設） | 台灣：《動物傳染病防治條例》第 13 條，犬貓每年 1 劑，未施打可處 3～15 萬元罰鍰；2025-07 起完全室內飼養的貓可免除。美國：有 1 年與 3 年效期疫苗，依疫苗標示與各州法規，App 預設較保守的每年，使用者可改成 3 年 |
| 核心疫苗（犬：DHPP；貓：FVRCP） | 每年 | **每 3 年** | 台灣動物醫院多建議每年補強。美國：AAHA 犬疫苗指引、AAHA/AAFP 貓疫苗指引，成犬／成貓完成幼年系列與 1 年後補強後，低風險者每 3 年；戶外或高風險貓可能每年 |
| 心絲蟲預防 | 每月（狗）；貓預設不勾選 | 每月（狗） | CAPC：全年、每月投藥 |
| 體外驅蟲（跳蚤、壁蝨） | 每月 | 每月 | CAPC：全年防治；ESCCAP：跳蚤為全年風險 |
| 體內驅蟲 | 每 3 個月 | 每 3 個月，預設不勾選 | ESCCAP：每年少於 4 次不足以防範蛔蟲；CAPC 建議每月控制腸道寄生蟲，美國多數每月心絲蟲藥已涵蓋，所以預設不勾選 |
| 健康檢查 | 每年 | 每年 | AAHA／AVMA 預防醫學：成年犬貓每年；高齡寵物獸醫可能建議每半年 |

## 這次的修改
- 美國犬貓核心疫苗：每年 → **每 3 年**，提前通知 7 → 14 天。
- 其他項目查證後符合來源，維持原設定。

## 參考資料
- 台灣狂犬病規定：[TVBS 健康 2.0](https://health.tvbs.com.tw/life/359006)、[風傳媒](https://www.storm.mg/lifestyle/5318883)、[NOWnews（室內貓免除）](https://www.nownews.com/news/6722995)；正式規定以農業部動植物防疫檢疫署公告為準
- [2022 AAHA Canine Vaccination Guidelines](https://aaha.org/?p=4056)、[Today's Veterinary Practice 重點整理](https://todaysveterinarypractice.com/preventive-medicine/canine-vaccination-guidelines-key-points-for-veterinary-practice/)
- [AAHA/AAFP Feline Vaccination Guidelines 摘要（CFA）](https://cfa.org/cat-talk/aaha-aafp-feline-vaccination-guide-for-cats/)、[PetMD](https://Petmd.Com/cat/wellness/essential-cat-vaccinations)
- [CAPC General Guidelines](https://capcvet.org/guidelines/general-guidelines/)
- [ESCCAP Scheme for individual deworming of dogs](https://testweb.esccap.org/uploads/docs/5j1pedrm_Scheme_for_individual_deworming_of_dogs.pdf)、[ESCCAP General Recommendations](https://testweb.esccap.org/uploads/docs/t58tbu33_0687_ESCCAP_General_Recommendations_update_v5.pdf)

上架前建議請一位台灣執業獸醫看過這張表。
