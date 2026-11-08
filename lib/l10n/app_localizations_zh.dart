// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Pawdian';

  @override
  String get navHome => '首頁';

  @override
  String get navPets => '寵物';

  @override
  String get navSettings => '設定';

  @override
  String get actionSave => '儲存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionEdit => '編輯';

  @override
  String get actionDone => '完成';

  @override
  String get actionOk => '好';

  @override
  String get notSet => '未設定';

  @override
  String get homeNoPetsTitle => '歡迎使用 Pawdian';

  @override
  String get homeNoPetsBody => '新增第一隻寵物，開始收到疫苗、驅蟲與用藥提醒。';

  @override
  String get addPet => '新增寵物';

  @override
  String get homeEmptyTitle => '今天沒有待辦事項';

  @override
  String get homeEmptyBody => '未來 7 天沒有提醒。';

  @override
  String get homeOverdue => '已逾期';

  @override
  String get homeToday => '今天';

  @override
  String get homeUpcoming => '未來 7 天';

  @override
  String reminderCompletedSnack(String title) {
    return '已完成「$title」';
  }

  @override
  String get petsEmptyTitle => '還沒有寵物';

  @override
  String get petsEmptyBody => '你的寵物會顯示在這裡。';

  @override
  String get petsArchivedSection => '已封存';

  @override
  String get petFormNewTitle => '新增寵物';

  @override
  String get petFormEditTitle => '編輯寵物';

  @override
  String get fieldName => '名字';

  @override
  String get fieldNameRequired => '請輸入名字';

  @override
  String get fieldSpecies => '物種';

  @override
  String get fieldBreed => '品種';

  @override
  String get fieldSex => '性別';

  @override
  String get fieldNeutered => '已結紮';

  @override
  String get fieldBirthDate => '生日';

  @override
  String get fieldBirthDateEstimated => '估計日期';

  @override
  String get fieldMicrochip => '晶片號碼';

  @override
  String get fieldColor => '毛色';

  @override
  String get fieldNotes => '備註';

  @override
  String get fieldVetName => '獸醫院';

  @override
  String get fieldVetPhone => '獸醫院電話';

  @override
  String get choosePhoto => '選擇照片';

  @override
  String get removePhoto => '移除照片';

  @override
  String get speciesDog => '狗';

  @override
  String get speciesCat => '貓';

  @override
  String get speciesRabbit => '兔';

  @override
  String get speciesRodent => '鼠類';

  @override
  String get speciesBird => '鳥';

  @override
  String get speciesReptile => '爬蟲';

  @override
  String get speciesOther => '其他';

  @override
  String get sexUnknown => '不確定';

  @override
  String get sexMale => '公';

  @override
  String get sexFemale => '母';

  @override
  String petAgeYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: ' $months 個月',
      zero: '',
    );
    return '$years 歲$_temp0';
  }

  @override
  String petAgeMonths(int months) {
    return '$months 個月';
  }

  @override
  String petAgeEstimated(String age) {
    return '約 $age';
  }

  @override
  String get sectionReminders => '照護提醒';

  @override
  String get sectionRecentRecords => '最近紀錄';

  @override
  String get noReminders => '尚未設定提醒';

  @override
  String get noRecords => '尚無紀錄';

  @override
  String get addReminder => '新增提醒';

  @override
  String get applyTemplates => '套用建議排程';

  @override
  String get archivePet => '封存';

  @override
  String get unarchivePet => '取消封存';

  @override
  String archivePetConfirm(String name) {
    return '要封存 $name 嗎？提醒會停止，紀錄會保留。';
  }

  @override
  String get deletePet => '刪除寵物';

  @override
  String deletePetConfirm(String name) {
    return '要刪除 $name 及所有紀錄嗎？此動作無法復原。';
  }

  @override
  String get archivedBadge => '已封存';

  @override
  String nextDue(String date) {
    return '下次：$date';
  }

  @override
  String get reminderFinished => '已結束';

  @override
  String get reminderPaused => '已暫停';

  @override
  String get reminderTypeVaccine => '疫苗';

  @override
  String get reminderTypeDewormInternal => '體內驅蟲';

  @override
  String get reminderTypeDewormExternal => '體外驅蟲';

  @override
  String get reminderTypeHeartworm => '心絲蟲預防';

  @override
  String get reminderTypeMedication => '用藥';

  @override
  String get reminderTypeGrooming => '洗澡／美容';

  @override
  String get reminderTypeCheckup => '健康檢查';

  @override
  String get reminderTypeCustom => '其他';

  @override
  String get repeatOnce => '單次';

  @override
  String repeatEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 天',
      one: '每天',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 週',
      one: '每週',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 個月',
      one: '每月',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '每 $count 年',
      one: '每年',
    );
    return '$_temp0';
  }

  @override
  String get unitNone => '不重複';

  @override
  String get unitDay => '天';

  @override
  String get unitWeek => '週';

  @override
  String get unitMonth => '個月';

  @override
  String get unitYear => '年';

  @override
  String get reminderFormNewTitle => '新增提醒';

  @override
  String get reminderFormEditTitle => '編輯提醒';

  @override
  String get fieldReminderType => '類型';

  @override
  String get fieldTitleOptional => '標題（選填）';

  @override
  String get fieldNextDate => '下次日期';

  @override
  String get fieldTimes => '提醒時間';

  @override
  String get addTime => '新增時間';

  @override
  String get fieldRepeat => '重複';

  @override
  String get fieldRepeatEvery => '每';

  @override
  String get fieldAdvanceNotice => '提前通知';

  @override
  String get advanceNone => '不提前';

  @override
  String advanceDays(int count) {
    return '提前 $count 天';
  }

  @override
  String get fieldActive => '啟用';

  @override
  String get deleteReminderConfirm => '要刪除這個提醒嗎？';

  @override
  String get templatesTitle => '建議照護排程';

  @override
  String templatesIntro(String species, String region) {
    return '以下是$region地區$species的常見照護頻率，請勾選適用的項目並設定下次日期。';
  }

  @override
  String get templatesDisclaimer => '僅供參考，非醫療建議，實際頻率請依獸醫指示調整。';

  @override
  String templatesApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新增 $count 個提醒',
      zero: '新增提醒',
    );
    return '$_temp0';
  }

  @override
  String get templatesSkip => '略過';

  @override
  String get templatesNone => '此物種沒有建議排程，可以自行新增提醒。';

  @override
  String get templateRabies => '狂犬病疫苗';

  @override
  String get templateCoreVaccineDog => '綜合疫苗';

  @override
  String get templateCoreVaccineCat => '貓三合一疫苗';

  @override
  String get settingsRegion => '照護範本地區';

  @override
  String get regionAuto => '自動';

  @override
  String get regionTw => '台灣';

  @override
  String get regionUs => '美國';

  @override
  String get settingsDefaultTime => '預設提醒時間';

  @override
  String get settingsNotifications => '通知';

  @override
  String get notifAllowed => '通知：已允許';

  @override
  String get notifBlocked => '通知：未允許，點此開啟';

  @override
  String get exactAllowed => '準時提醒：已允許';

  @override
  String get exactBlocked => '準時提醒：未允許，點此開啟';

  @override
  String get reminderHelpTitle => '提醒沒跳出來？';

  @override
  String get reminderHelpIntro => '部分手機為了省電會關閉背景中的 App，導致提醒延遲或不出現。請檢查：';

  @override
  String get reminderHelpStep1 => '允許 Pawdian 的通知與準時提醒（見上方設定）。';

  @override
  String get reminderHelpStep2 =>
      '把 Pawdian 的電池用量設為「不受限制」（設定 > 應用程式 > Pawdian > 電池）。';

  @override
  String get reminderHelpStep3 => '小米、OPPO、vivo、華為等手機，請另外開啟 Pawdian 的「自動啟動」。';

  @override
  String get reminderHelpStep4 => '手機重新開機後，打開 Pawdian 一次以重新排定提醒。';

  @override
  String get debugPro => '開發者：解鎖 Pro';

  @override
  String get proTitle => 'Pawdian Pro';

  @override
  String get proMultiplePets => '免費版可管理 1 隻寵物，Pawdian Pro 可不限數量。';

  @override
  String get notifChannelName => '照護提醒';

  @override
  String get notifChannelDescription => '疫苗、驅蟲與用藥提醒';

  @override
  String notifTitle(String pet, String title) {
    return '$pet：$title';
  }

  @override
  String get notifBodyDue => '時間到了，完成後按「完成」即可記錄。';

  @override
  String notifBodyAdvance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天後到期',
      one: '明天到期',
    );
    return '$_temp0';
  }

  @override
  String get notifBodySnoozed => '再次提醒';

  @override
  String get notifActionDone => '完成';

  @override
  String get notifActionSnooze => '1 小時後';

  @override
  String get notifActionTomorrow => '明天';

  @override
  String get settingsLanguage => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseTraditional => '繁體中文';

  @override
  String get recordTypeFeeding => '餵食';

  @override
  String get recordTypeWater => '喝水';

  @override
  String get recordTypePoop => '便便';

  @override
  String get recordTypeUrine => '尿尿';

  @override
  String get recordTypeVomit => '嘔吐';

  @override
  String get recordTypeCough => '咳嗽';

  @override
  String get recordTypeLethargy => '精神不佳';

  @override
  String get recordTypeAppetiteLoss => '食慾不佳';

  @override
  String get recordTypeVetVisit => '看診';

  @override
  String get recordTypeNote => '備註';

  @override
  String get severityNone => '未指定';

  @override
  String get severityMild => '輕微';

  @override
  String get severityModerate => '中等';

  @override
  String get severitySevere => '嚴重';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryCare => '照護';

  @override
  String get categoryMedication => '用藥';

  @override
  String get categoryDaily => '日常';

  @override
  String get categorySymptom => '症狀';

  @override
  String get categoryVet => '看診';

  @override
  String get categoryWeight => '體重';

  @override
  String get quickLogTitle => '快速記錄';

  @override
  String quickLogDone(String type, String pet) {
    return '已記錄 $pet 的「$type」';
  }

  @override
  String get quickLogAddNote => '補充內容';

  @override
  String get quickLogPickPet => '要記錄哪一隻？';

  @override
  String get addRecord => '新增紀錄';

  @override
  String get recordFormNewTitle => '新增紀錄';

  @override
  String get recordFormEditTitle => '編輯紀錄';

  @override
  String get fieldDate => '日期';

  @override
  String get fieldTime => '時間';

  @override
  String get fieldSeverity => '程度';

  @override
  String get fieldDiagnosis => '診斷摘要';

  @override
  String get fieldCost => '花費';

  @override
  String get fieldNextVisit => '下次回診';

  @override
  String get revisitReminderTitle => '回診';

  @override
  String get deleteRecordConfirm => '要刪除這筆紀錄嗎？';

  @override
  String costLabel(String amount) {
    return '花費 $amount';
  }

  @override
  String get weightTitle => '體重';

  @override
  String get addWeight => '記錄體重';

  @override
  String get fieldWeight => '體重';

  @override
  String get weightInvalid => '請輸入有效的體重';

  @override
  String get weightEmpty => '尚無體重紀錄';

  @override
  String weightLatest(String value) {
    return '最新 $value';
  }

  @override
  String weightEntryTitle(String value) {
    return '體重 $value';
  }

  @override
  String get rangeMonth => '1 個月';

  @override
  String get range3Months => '3 個月';

  @override
  String get rangeYear => '1 年';

  @override
  String get rangeAll => '全部';

  @override
  String get proWeightHistory => '免費版可查看近 3 個月的體重曲線，Pawdian Pro 可查看完整歷史。';

  @override
  String get deleteWeightConfirm => '要刪除這筆體重紀錄嗎？';

  @override
  String get settingsWeightUnit => '體重單位';

  @override
  String get settingsQuickLog => '快速記錄按鈕';

  @override
  String get timelineTitle => '時間軸';

  @override
  String get viewAll => '查看全部';

  @override
  String get searchHint => '搜尋備註';

  @override
  String get timelineEmpty => '沒有符合的紀錄';

  @override
  String get proLearnMore => '了解 Pro';

  @override
  String get proHeadline => '解鎖全部功能，好好照顧毛孩';

  @override
  String get proFeaturePets => '不限寵物數量';

  @override
  String get proFeatureHistory => '完整體重歷史';

  @override
  String get proFeatureReport => '就醫報告 PDF';

  @override
  String get proFeatureAttachments => '每筆紀錄不限照片數量';

  @override
  String get proFeatureCsv => '匯出 CSV 資料';

  @override
  String get proYearly => '年訂閱';

  @override
  String get proMonthly => '月訂閱';

  @override
  String get proLifetime => '終身買斷（一次付清）';

  @override
  String get proRestore => '恢復購買';

  @override
  String get proUnavailable => '目前無法連線到 Google Play，請稍後再試。';

  @override
  String get proActive => '已啟用 Pawdian Pro，謝謝你的支持！';

  @override
  String get proPending => '付款處理中…';

  @override
  String proFailed(String message) {
    return '購買失敗：$message';
  }

  @override
  String get proRestored => '已恢復購買';

  @override
  String get proNothingToRestore => '這個 Google 帳號沒有 Pro 購買紀錄';

  @override
  String get proTerms => '訂閱會自動續訂，可隨時在 Google Play > 訂閱 中取消。';

  @override
  String get settingsPro => 'Pawdian Pro';

  @override
  String get settingsProActive => '已啟用';

  @override
  String get settingsProFree => '免費版';

  @override
  String get proAttachments => '免費版每筆紀錄可附 1 張照片，Pawdian Pro 不限數量。';

  @override
  String get proReport => '就醫報告 PDF 是 Pawdian Pro 功能。';

  @override
  String get proCsv => '匯出 CSV 是 Pawdian Pro 功能。';

  @override
  String get settingsData => '資料';

  @override
  String get backupTitle => '備份與還原';

  @override
  String get backupIntro =>
      '資料只存在這支手機上。Android 也會自動把紀錄和設定備份到你的 Google 帳號（不含照片）。若要包含照片的完整備份，請建立備份檔並存到安全的地方。';

  @override
  String get backupCreateShare => '建立備份並分享';

  @override
  String get backupCreateSave => '建立備份並存到檔案';

  @override
  String get backupRestore => '從備份檔還原';

  @override
  String get backupRestoreConfirm => '還原會用備份檔取代這支手機上的「全部」資料，且無法復原。要繼續嗎？';

  @override
  String get backupRestoreAction => '取代資料';

  @override
  String get backupDone => '已建立備份';

  @override
  String get backupRestored => '已還原備份';

  @override
  String get backupInvalid => '這不是有效的 Pawdian 備份檔';

  @override
  String get backupTooNew => '這個備份來自較新版本的 Pawdian，請先更新 App。';

  @override
  String backupLast(String date) {
    return '上次備份：$date';
  }

  @override
  String get backupNever => '尚未建立備份檔';

  @override
  String get backupStale => '距離上次備份已超過 30 天';

  @override
  String get csvExport => '匯出 CSV';

  @override
  String get csvExportHint => '所有寵物的紀錄與體重，可用 Excel 或 Google 試算表開啟';

  @override
  String get attachmentsTitle => '照片';

  @override
  String get attachmentAddGallery => '選擇照片';

  @override
  String get attachmentAddCamera => '拍照';

  @override
  String get reportTitle => '就醫報告';

  @override
  String get reportRange => '期間';

  @override
  String reportDays(int count) {
    return '近 $count 天';
  }

  @override
  String reportGenerated(String date) {
    return '產生日期 $date';
  }

  @override
  String reportPeriod(String from, String to) {
    return '期間：$from – $to';
  }

  @override
  String get reportProfile => '基本資料';

  @override
  String get reportWeights => '體重';

  @override
  String get reportSymptoms => '症狀';

  @override
  String get reportMedication => '用藥';

  @override
  String get reportCare => '疫苗、驅蟲與照護';

  @override
  String get reportVetVisits => '看診紀錄';

  @override
  String get reportNone => '無紀錄';

  @override
  String get reportColDate => '日期';

  @override
  String get reportColItem => '項目';

  @override
  String get reportColDetails => '內容';

  @override
  String get reportDisclaimer => '本報告由飼主使用 Pawdian 記錄，僅供參考，非醫療紀錄。';

  @override
  String get widgetNoReminders => '沒有即將到來的提醒';

  @override
  String get widgetOverdue => '已逾期';
}
