// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get error => 'خطأ';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageTurkish => 'التركية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageGerman => 'الألمانية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageItalian => 'الإيطالية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageRomanian => 'الرومانية';

  @override
  String errorWithDetails(String details) {
    return 'خطأ: $details';
  }

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonDeleteConfirm => 'حذف';

  @override
  String get errorTimeoutProvider => 'لم يستجب المزود. يرجى المحاولة لاحقًا.';

  @override
  String get errorNoConnection => 'لا يوجد اتصال بالإنترنت أو لا يمكن الوصول إلى المزود.';

  @override
  String get errorDatabaseTemporary => 'قاعدة البيانات غير متاحة مؤقتًا. يرجى المحاولة مرة أخرى.';

  @override
  String get errorGenericRetry => 'حدثت مشكلة. يرجى المحاولة مرة أخرى.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get settingsAppearanceSection => 'المظهر';

  @override
  String get settingsThemeDark => 'الوضع الداكن';

  @override
  String get settingsThemeLight => 'الوضع الفاتح';

  @override
  String get settingsThemeSystem => 'وضع النظام';

  @override
  String get settingsEpgSection => 'دليل البرامج (EPG)';

  @override
  String get settingsEpgUrlLabel => 'رابط EPG (.xml أو .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'تحديث EPG الآن';

  @override
  String get settingsSelectPlaylistFirst => 'اختر قائمة تشغيل أولًا';

  @override
  String get settingsEpgUpdated => 'تم تحديث EPG بنجاح';

  @override
  String settingsEpgError(String details) {
    return 'خطأ في EPG: $details';
  }

  @override
  String get settingsSubtitleSection => 'الترجمة';

  @override
  String get settingsSubtitleFontSize => 'حجم الخط';

  @override
  String get subtitleSizeSmall => 'صغير';

  @override
  String get subtitleSizeNormal => 'عادي';

  @override
  String get subtitleSizeLarge => 'كبير';

  @override
  String get subtitleSizeExtraLarge => 'كبير جدًا';

  @override
  String get settingsSubtitleTextColor => 'لون النص';

  @override
  String get subtitleColorWhite => 'أبيض';

  @override
  String get subtitleColorYellow => 'أصفر';

  @override
  String get subtitleColorGreen => 'أخضر';

  @override
  String get subtitleColorCyan => 'سماوي';

  @override
  String get settingsSubtitleBgColor => 'الخلفية';

  @override
  String get subtitleBgSemi => 'شبه شفاف';

  @override
  String get subtitleBgOpaque => 'أسود';

  @override
  String get subtitleBgNone => 'بلا';

  @override
  String get settingsAboutSection => 'حول';

  @override
  String settingsAppVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsPlaylistManagement => 'إدارة قوائم التشغيل';

  @override
  String get settingsCategoryFilterSubtitle => 'إخفاء/إظهار الفئات';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'أضف قائمة تشغيل للبدء';

  @override
  String get homeAddPlaylist => 'إضافة قائمة تشغيل';

  @override
  String get homeSearchHint => 'ابحث عن قنوات، أفلام، مسلسلات…';

  @override
  String get homePlaylistsTooltip => 'قوائم التشغيل';

  @override
  String get homeMore => 'المزيد';

  @override
  String get homePlaylistSyncing => 'جارٍ مزامنة قائمة التشغيل…';

  @override
  String get homeSearchTooltip => 'بحث';

  @override
  String get watchlistAddTooltip => 'إضافة إلى قائمتي';

  @override
  String get watchlistRemoveTooltip => 'إزالة من قائمتي';

  @override
  String get playerPlayAction => 'تشغيل';

  @override
  String get playerPauseAction => 'إيقاف مؤقت';

  @override
  String get playlistsActiveLabel => 'نشطة';

  @override
  String get homeCategoryManagement => 'إدارة الفئات';

  @override
  String get homeTabHome => 'الرئيسية';

  @override
  String get homeTabLive => 'البث المباشر';

  @override
  String get homeTabMovie => 'أفلام';

  @override
  String get homeTabSeries => 'مسلسلات';

  @override
  String get homeTabFavorites => 'المفضلة';

  @override
  String get homeFavoritesAll => 'الكل';

  @override
  String get homeFavoritesLive => 'البث المباشر';

  @override
  String get homeFavoritesMovie => 'أفلام';

  @override
  String get homeFavoritesSeries => 'مسلسلات';

  @override
  String get homeEmptyFavorites => 'لا توجد مفضلات بعد';

  @override
  String get homeEmptyFavoritesType => 'لا توجد مفضلات من هذا النوع';

  @override
  String get homeEmptyCategory => 'لا يوجد محتوى في هذه الفئة';

  @override
  String get homeRowContinueWatching => 'تابع المشاهدة';

  @override
  String get homeRowRecentlyWatched => 'شُوهد مؤخرًا';

  @override
  String get homeRowNewMovies => 'أفلام جديدة';

  @override
  String get homeRowNewSeries => 'مسلسلات جديدة';

  @override
  String get homeRowNewChannels => 'قنوات جديدة';

  @override
  String get homeEmptyContent => 'لا يوجد محتوى بعد';

  @override
  String get homeEmptyContentHint => 'تصفح علامات تبويب الأفلام / المسلسلات / المباشر للبدء';

  @override
  String get homeRecentlyWatchedHeader => 'شُوهد مؤخرًا';

  @override
  String get homeSearchEmpty => 'ابدأ الكتابة للبحث';

  @override
  String homeSearchNoResults(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String homeContentCount(int count) {
    return '$count عنصر';
  }

  @override
  String get sortDialogTitle => 'الترتيب';

  @override
  String get sortLabelDefault => 'افتراضي';

  @override
  String get sortLabelAZ => 'أ → ي';

  @override
  String get sortLabelZA => 'ي → أ';

  @override
  String get sortLabelShortAZ => 'أ→ي';

  @override
  String get sortLabelShortZA => 'ي→أ';

  @override
  String get sortLabelShort => 'ترتيب';

  @override
  String get playlistsTitle => 'قوائم التشغيل';

  @override
  String get playlistsEmpty => 'لا توجد قوائم تشغيل بعد';

  @override
  String get playlistsRefreshTooltip => 'تحديث';

  @override
  String get playlistsDeleteTooltip => 'حذف';

  @override
  String get playlistsRetryAction => 'إعادة';

  @override
  String get playlistsUpdated => 'تم تحديث قائمة التشغيل.';

  @override
  String get playlistsDeleteTitle => 'حذف قائمة التشغيل';

  @override
  String playlistsDeleteConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get playlistsAddTitle => 'إضافة قائمة تشغيل';

  @override
  String get playlistsTypeM3u => 'رابط M3U';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsTypeStalker => 'Stalker / MAG';

  @override
  String get playlistsStalkerCardTitle => 'Stalker Portal / صندوق MAG';

  @override
  String get playlistsStalkerCardBody => 'يجب أن يكون عنوان MAC الخاص بك مسجلًا لدى مزود IPTV. يجرب التطبيق أولًا مسار M3U السريع، ثم يتحول إلى بروتوكول Stalker الكامل عند الحاجة.';

  @override
  String get playlistsStalkerPortalLabel => 'رابط البوابة';

  @override
  String get playlistsStalkerPortalHint => 'http://provider.com:8080';

  @override
  String get playlistsStalkerMacLabel => 'عنوان MAC';

  @override
  String get playlistsStalkerMacHint => '00:1A:79:XX:XX:XX';

  @override
  String get playlistsStalkerMacGenerate => 'إنشاء';

  @override
  String get playlistsStalkerMacHelp => 'صيغة MAC: XX:XX:XX:XX:XX:XX (أحرف كبيرة، مفصولة بنقطتين)';

  @override
  String get playlistsValidationStalkerMac => 'أدخل عنوان MAC صالحًا (XX:XX:XX:XX:XX:XX).';

  @override
  String get editPlaylistStalkerBadge => 'Stalker / MAG';

  @override
  String get progressTryingPortalList => 'جارٍ محاولة جلب القائمة من البوابة…';

  @override
  String get progressPortalConnecting => 'جارٍ الاتصال بالبوابة…';

  @override
  String get loadErrPortalConnect => 'تعذّر الاتصال بالبوابة. تحقّق من عنوان البوابة ومن أن عنوان MAC الخاص بك مسجّل لدى مزوّد الخدمة.';

  @override
  String get loadErrPortalList => 'تعذّر جلب قائمة القنوات. تأكّد من مزوّد الخدمة أن عنوان MAC الخاص بك مسجّل في البوابة.';

  @override
  String get playlistsNameLabel => 'اسم قائمة التشغيل';

  @override
  String get playlistsM3uUrlLabel => 'رابط M3U';

  @override
  String get playlistsM3uUrlHint => 'http://… أو https://…';

  @override
  String get playlistsPasteFromClipboard => 'لصق من الحافظة';

  @override
  String get playlistsClipboardEmpty => 'الحافظة فارغة';

  @override
  String get playlistsServerUrlLabel => 'رابط الخادم';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'اسم المستخدم';

  @override
  String get playlistsPasswordLabel => 'كلمة المرور';

  @override
  String get playlistsContentTypes => 'أنواع المحتوى';

  @override
  String get playlistsContentLive => 'البث المباشر';

  @override
  String get playlistsContentMovie => 'أفلام';

  @override
  String get playlistsContentSeries => 'مسلسلات';

  @override
  String get playlistsValidationNameUrl => 'الاسم والرابط مطلوبان';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream يتطلب اسم مستخدم وكلمة مرور';

  @override
  String get playlistsErrorTlsHandshake => 'تعذر إنشاء اتصال آمن (خطأ TLS). جرّب http:// أو تحقق من عنوان المزود.';

  @override
  String get playlistsErrorTimeout => 'لم يستجب المزود (انتهت المهلة). يرجى المحاولة لاحقًا.';

  @override
  String get playlistsErrorConnection => 'لا يوجد اتصال بالإنترنت أو لا يمكن الوصول إلى المزود.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'تعذر تحديث قائمة التشغيل: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'أرجع المزود قائمة تشغيل فارغة. تم الاحتفاظ بالبيانات السابقة.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'إعادة الاتصال ($attempt)…';
  }

  @override
  String get playerReconnecting => 'إعادة الاتصال…';

  @override
  String get playerLoading => 'جارٍ التحميل…';

  @override
  String get playerStreamRepeatedError => 'البث ينقطع باستمرار. جرّب قناة أخرى.';

  @override
  String get playerReconnectTooltip => 'إعادة الاتصال';

  @override
  String get playerSubtitleEnable => 'تفعيل ترجمة الذكاء الاصطناعي';

  @override
  String get playerSubtitleDisable => 'إيقاف ترجمة الذكاء الاصطناعي';

  @override
  String get playerMuteTooltip => 'كتم الصوت';

  @override
  String get playerUnmuteTooltip => 'إلغاء كتم الصوت';

  @override
  String get playerLiveLabel => 'مباشر';

  @override
  String get playerSeekHint => '◄ ١٠ث ►';

  @override
  String get playerAudioTrackTooltip => 'المسار الصوتي';

  @override
  String get playerAudioTrackDialog => 'المسار الصوتي';

  @override
  String playerAudioTrackFallback(int n) {
    return 'المسار $n';
  }

  @override
  String get playerSpeedDialog => 'سرعة التشغيل';

  @override
  String get playerSubtitleDialogTitle => 'الترجمة';

  @override
  String get playerSubtitleAi => 'ترجمة AI';

  @override
  String get playerSubtitleAiActive => '(نشط)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'مدمج $n';
  }

  @override
  String get playerSubtitleOff => 'إيقاف';

  @override
  String get playerScreenSizeTooltip => 'حجم الشاشة';

  @override
  String get playerScreenSizeDialog => 'حجم الشاشة';

  @override
  String get playerFitOriginal => 'الأصلي';

  @override
  String get playerFitCover => 'ملء الشاشة (قص)';

  @override
  String get playerFitStretch => 'تمديد';

  @override
  String get playerResolutionTooltip => 'الدقة';

  @override
  String get playerResolutionDialog => 'الدقة';

  @override
  String get playerResolutionAuto => 'تلقائي';

  @override
  String get playerSingleQuality => 'يقدم هذا البث جودة واحدة فقط.';

  @override
  String get playerErrorUnsupportedFormat => 'لا يمكن تشغيل صيغة الفيديو أو الصوت لهذا البث على هذا الجهاز. جرّب مصدرًا آخر أو مشغلًا خارجيًا.';

  @override
  String get playerErrorCorruptStream => 'تعذّرت قراءة بيانات البث. قد تكون القناة معطلة مؤقتًا؛ حاول لاحقًا.';

  @override
  String get aiSubErrUnavailable => 'خدمة ترجمة الذكاء الاصطناعي غير متاحة حاليًا. يُرجى المحاولة لاحقًا.';

  @override
  String get aiSubErrProRequired => 'انتهت الفترة التجريبية لترجمة الذكاء الاصطناعي. انتقل إلى Pro للمتابعة.';

  @override
  String get aiSubErrQuota => 'تم استنفاد حصة استخدام ترجمة الذكاء الاصطناعي.';

  @override
  String get aiSubErrBusy => 'خدمة ترجمة الذكاء الاصطناعي مشغولة جدًا حاليًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get aiSubErrInvalidKey => 'مفتاح API لترجمة الذكاء الاصطناعي غير صالح أو منتهي الصلاحية. تحقّق منه في الإعدادات > ترجمة الذكاء الاصطناعي.';

  @override
  String get aiSubErrRejected => 'لم تقبل خدمة ترجمة الذكاء الاصطناعي الطلب. يُرجى المحاولة لاحقًا.';

  @override
  String get aiSubErrEmptyResponse => 'أرسلت خدمة ترجمة الذكاء الاصطناعي ردًا فارغًا. يُرجى المحاولة مرة أخرى.';

  @override
  String get aiSubErrNoSpeech => 'لم يتم التعرّف على كلام في هذا الجزء. حاول مرة أخرى في جزء آخر من الفيديو.';

  @override
  String get aiSubErrGeneric => 'تعذّر إنشاء الترجمة. يُرجى المحاولة مرة أخرى.';

  @override
  String get aiSubErrUnreachable => 'تعذّر الوصول إلى خدمة ترجمة الذكاء الاصطناعي. تحقّق من اتصالك بالإنترنت.';

  @override
  String get aiSubErrConnectTimeout => 'انتهت المهلة أثناء الاتصال بخدمة ترجمة الذكاء الاصطناعي. يُرجى المحاولة مرة أخرى.';

  @override
  String get aiSubErrExtract => 'تعذّر قراءة الصوت لترجمة الذكاء الاصطناعي. صيغة هذا البث غير مدعومة على بعض الأجهزة. جرّب مصدرًا بجودة أقل أو شاهد في مشغّل خارجي.';

  @override
  String get aiSubErrNoOpenAiKey => 'لم يتم إدخال مفتاح OpenAI API. أضفه من الإعدادات > ترجمة الذكاء الاصطناعي.';

  @override
  String aiTrialStarted(int days) {
    return 'بدأت تجربتك المجانية لترجمة الذكاء الاصطناعي لمدة $days أيام';
  }

  @override
  String get paywallAiTrialEnded => 'انتهت تجربة ترجمة الذكاء الاصطناعي. انتقل إلى Pro لمواصلة استخدامها.';

  @override
  String get playerAiPreparing => 'جارٍ تجهيز ترجمة الذكاء الاصطناعي';

  @override
  String playerSecondsShort(int seconds) {
    return '$seconds ث';
  }

  @override
  String playerBannerWhisper(String lang) {
    return 'ترجمة الذكاء الاصطناعي (التعرّف على الكلام): $lang';
  }

  @override
  String get playerOrientationLock => 'قفل اتجاه الشاشة';

  @override
  String playerResumeQuestion(String position) {
    return 'هل تريد المتابعة من $position؟';
  }

  @override
  String get playerResumeContinue => 'متابعة';

  @override
  String get playerResumeFromBeginning => 'البدء من الأول';

  @override
  String get playerErrorStreamUnavailable => 'تعذّر فتح هذه القناة. مصدر البث لا يستجيب أو انقطع الاتصال.';

  @override
  String get playerErrorBackToList => 'العودة إلى قائمة القنوات';

  @override
  String get playerReportError => 'الإبلاغ عن خطأ';

  @override
  String get errorReportTitle => 'الإبلاغ عن خطأ';

  @override
  String get errorReportThanks => 'شكرًا لك!';

  @override
  String get errorReportReceived => 'تم إرسال بلاغ الخطأ.';

  @override
  String errorReportChannel(String name) {
    return 'القناة: $name';
  }

  @override
  String errorReportError(String error) {
    return 'الخطأ: $error';
  }

  @override
  String errorReportDevice(String device) {
    return 'الجهاز: $device';
  }

  @override
  String errorReportVersion(String version) {
    return 'الإصدار: $version';
  }

  @override
  String get errorReportNoteLabel => 'ملاحظة إضافية (اختياري):';

  @override
  String get errorReportNotePlaceholder => 'ماذا كنت تفعل؟';

  @override
  String get errorReportSend => 'إرسال';

  @override
  String playerPanelChannels(int count) {
    return 'القنوات ($count)';
  }

  @override
  String get playerSeekForward => '▶▶ +١٠ ث';

  @override
  String get playerSeekBackward => '◀◀ -١٠ ث';

  @override
  String get playerWatchlistAdded => 'تمت الإضافة إلى القائمة';

  @override
  String get playerWatchlistRemoved => 'تمت الإزالة من القائمة';

  @override
  String get playerWatchlistTooltip => 'المشاهدة لاحقاً';

  @override
  String get settingsAiSection => 'ترجمة بالذكاء الاصطناعي';

  @override
  String get settingsAiTargetLangTitle => 'لغة الترجمة المستهدفة';

  @override
  String get settingsAiTargetLangSubtitle => 'باللغة التي ستظهر بها الترجمة';

  @override
  String get settingsAiTargetLangAuto => 'تلقائي (لغة الجهاز)';

  @override
  String get settingsAiTargetLangDialogTitle => 'اختر لغة الهدف';

  @override
  String get settingsAiBannerTitle => 'شريط ترجمة الذكاء الاصطناعي';

  @override
  String get settingsAiBannerSubtitle => 'إظهار لغة المصدر/الهدف في الأعلى';

  @override
  String get settingsAiWhisperTitle => 'ترجمة Whisper بالذكاء الاصطناعي';

  @override
  String get settingsAiWhisperSubtitle => 'إنشاء ترجمات تلقائية في المشغل';

  @override
  String get settingsAiProviderGroq => 'Groq';

  @override
  String get settingsAiProviderGroqBadge => 'Pro';

  @override
  String get settingsAiProviderOpenai => 'OpenAI';

  @override
  String get settingsAiProviderOpenaiBadge => 'مدفوع';

  @override
  String settingsAiGroqInfo(int days) {
    return 'خدمة Groq المدمجة — ميزة Pro، تجربة مجانية لمدة $days أيام';
  }

  @override
  String get settingsAiOpenaiCost => 'التكلفة التقديرية: ~\$0.006/طلب · ~\$0.006/دقيقة · openai.com/account/billing';

  @override
  String get settingsAiOpenaiKeyLabel => 'مفتاح OpenAI API';

  @override
  String get settingsAiOpenaiKeyPlaceholder => 'sk-…';

  @override
  String get settingsAiOpenaiKeySaved => '✓ تم حفظ مفتاح OpenAI';

  @override
  String get settingsSubtitleDefaultOn => 'تفعيل الترجمة افتراضيًا';

  @override
  String get settingsSubtitleDefaultOnSubtitle => 'تفعيل الترجمة عند فتح المشغل';

  @override
  String get settingsBufferDuration => 'مدة التخزين المؤقت';

  @override
  String settingsBufferSeconds(int seconds) {
    return '$seconds ثانية';
  }

  @override
  String aiTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'تجربة الترجمة بالذكاء الاصطناعي: $days يوم متبقٍ',
      many: 'تجربة الترجمة بالذكاء الاصطناعي: $days يومًا متبقيًا',
      few: 'تجربة الترجمة بالذكاء الاصطناعي: $days أيام متبقية',
      two: 'تجربة الترجمة بالذكاء الاصطناعي: يومان متبقيان',
      one: 'تجربة الترجمة بالذكاء الاصطناعي: يوم واحد متبقٍ',
      zero: 'تجربة الترجمة بالذكاء الاصطناعي: $days يوم متبقٍ',
    );
    return '$_temp0';
  }

  @override
  String get playerPaused => 'متوقف مؤقتًا';

  @override
  String get playerPlaying => 'جارٍ التشغيل';

  @override
  String get playerMuted => 'صامت';

  @override
  String get playerUnmuted => 'الصوت مفعّل';

  @override
  String playerFeedbackAudio(String label) {
    return 'الصوت: $label';
  }

  @override
  String playerFeedbackSpeed(String speed) {
    return 'السرعة $speed';
  }

  @override
  String get playerFeedbackSubtitleOff => 'الترجمة متوقفة';

  @override
  String playerFeedbackSubtitle(String lang) {
    return 'الترجمة: $lang';
  }

  @override
  String get playerFeedbackSubtitleLoading => 'جارٍ تحميل الترجمة…';

  @override
  String playerFeedbackResolution(String value) {
    return 'الدقة: $value';
  }

  @override
  String playerFeedbackFit(String mode) {
    return 'العرض: $mode';
  }

  @override
  String get playerFavoriteAdd => 'أضف إلى المفضلة';

  @override
  String get playerFavoriteRemove => 'إزالة من المفضلة';

  @override
  String get playerNextChannel => 'القناة التالية';

  @override
  String get playerPrevChannel => 'القناة السابقة';

  @override
  String get playerOrientationUnlocked => 'تم إلغاء قفل التدوير';

  @override
  String playerNextEpisode(String title) {
    return 'الحلقة التالية: $title';
  }

  @override
  String get playerOpenExternal => 'افتح في مشغل خارجي (VLC)';

  @override
  String get playerExternalNotFound => 'لم يتم العثور على مشغل خارجي. ثبّت VLC من App Store.';

  @override
  String get playerChannelPanelTooltip => 'قائمة القنوات';

  @override
  String get disclaimerWelcome => 'مرحبًا';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources.\n\nThis app does not provide, host, or distribute any content. You must supply your own legally obtained playlist URL.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player هو مشغل وسائط لقوائم تشغيل M3U الخاصة بك ومصادر Xtream Codes. التطبيق لا يقدم أو يستضيف أو يوزع أي محتوى.';

  @override
  String get disclaimerLegalNoticeButton => 'إشعار قانوني';

  @override
  String get disclaimerContinue => 'متابعة';

  @override
  String get disclaimerFooter => 'بالمتابعة فإنك توافق على الإشعار القانوني.';

  @override
  String get legalNoticeTitle => 'إشعار قانوني';

  @override
  String get legalSection1Title => '١. طبيعة التطبيق';

  @override
  String get legalSection1En => 'IPTV AI Player is a general-purpose media player (similar to VLC or MX Player). It does NOT provide, host, distribute, or redirect to any TV broadcasts, movies, series, sports events, or other content. The app is a tool that plays M3U / M3U8 playlist URLs or Xtream Codes credentials supplied by the user.';

  @override
  String get legalSection1Tr => 'IPTV AI Player هو مشغل وسائط متعدد الأغراض (مماثل لـ VLC أو MX Player). لا يقدم أو يستضيف أو يوزع أي محتوى؛ يقوم فقط بتشغيل روابط M3U/M3U8 أو بيانات اعتماد Xtream التي يوفرها المستخدم.';

  @override
  String get legalSection2Title => '٢. مسؤولية المحتوى';

  @override
  String get legalSection2En => 'The user is solely responsible for all content accessed via the app. The developer has no knowledge of and bears no responsibility for content accessed through the app.';

  @override
  String get legalSection2Tr => 'يتحمل المستخدم وحده المسؤولية عن جميع المحتويات التي يتم الوصول إليها عبر التطبيق. ليس لدى المطور أي علم بها ولا يتحمل أي مسؤولية عنها.';

  @override
  String get legalSection3Title => '٣. الإطار القانوني التركي';

  @override
  String get legalSection3Item1 => 'المادتان ٧١-٧٢ من القانون رقم ٥٨٤٦ (FSEK، تركيا): انتهاك حقوق النشر يستوجب عقوبات مدنية وجنائية.';

  @override
  String get legalSection3Item2 => 'المادة ١٦٣/٢ من قانون العقوبات التركي: الاستخدام غير المصرح به للبث المشفر/غير المشفر.';

  @override
  String get legalSection3Item3 => 'المادة الإضافية ٤ من FSEK: انتهاك حقوق النشر على الإنترنت.';

  @override
  String get legalSection3Item4 => 'يمكن لـ RTÜK و BTK فرض حظر الوصول بموجب القانونين رقم ٦١١٢ و ٥٦٥١.';

  @override
  String get legalSection4Title => '٤. التزامات المستخدم';

  @override
  String get legalSection4Body => 'باستخدامك لهذا التطبيق فإنك تقر بأنك ستصل فقط إلى المحتوى المشترك فيه قانونيًا، ولن تصل إلى محتوى محمي بحقوق النشر دون إذن، ولن تستخدم التطبيق لعمليات البث المقرصنة أو خدمات IPTV غير المرخصة.';

  @override
  String get legalSection5Title => '٥. حماية البيانات';

  @override
  String get legalSection5Body => 'يخزن التطبيق روابط قوائم التشغيل وبيانات الاعتماد محليًا فقط على جهازك. لا تتم مشاركتها مع أي طرف ثالث.';

  @override
  String get legalSection6Title => '٦. تحديد المسؤولية';

  @override
  String get legalSection6Body => 'يُقدَّم التطبيق \"كما هو\". لا يتحمل المطور المسؤولية عن أي أضرار تنشأ عن استخدام التطبيق.';

  @override
  String get legalSection7Title => '٧. التعاون القانوني';

  @override
  String get legalSection7Body => 'يلتزم المطور بالطلبات القانونية من السلطات المختصة (RTÜK، BTK، النيابة العامة).';

  @override
  String get legalReminder => 'تذكير: استخدام هذا التطبيق للوصول إلى محتوى غير مصرح به أو محمي بحقوق النشر أمر غير قانوني. يتحمل المستخدم المسؤولية القانونية الكاملة.';

  @override
  String get searchHint => 'ابحث عن قنوات، أفلام، مسلسلات…';

  @override
  String get searchMinChars => 'أدخل حرفين على الأقل';

  @override
  String searchNoResults(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get categoryFilterTitle => 'فلتر الفئات';

  @override
  String get categoryFilterShowAll => 'إظهار الكل';

  @override
  String get categoryFilterHideAll => 'إخفاء الكل';

  @override
  String get categoryFilterEmpty => 'لا توجد فئات بعد';

  @override
  String get categoryFilterSectionLive => 'البث المباشر';

  @override
  String get categoryFilterSectionMovie => 'أفلام';

  @override
  String get categoryFilterSectionSeries => 'مسلسلات';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total نشط)';
  }

  @override
  String get seriesEmptyCategory => 'لا توجد مسلسلات في هذه الفئة';

  @override
  String seriesSeasonCount(int count) {
    return '$count موسم';
  }

  @override
  String get seriesSpecialSeason => 'حلقات خاصة';

  @override
  String seriesSeasonNumber(int n) {
    return 'الموسم $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count حلقة';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'إزالة من سجل المشاهدة';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return 'هل تريد إزالة $name من سجل المشاهدة؟';
  }

  @override
  String get homeRemoveFromHistoryAction => 'إزالة';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return 'تمت إزالة $name من سجل المشاهدة';
  }

  @override
  String homeFavoriteAdded(String name) {
    return 'تمت إضافة $name إلى المفضلة';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return 'تمت إزالة $name من المفضلة';
  }

  @override
  String get homeRowPopular => 'الأكثر شعبية';

  @override
  String get homeRowWatchedMovies => 'الأفلام التي شاهدتها';

  @override
  String get homeRowWatchedSeries => 'المسلسلات التي شاهدتها';

  @override
  String get badgeMovieUppercase => 'فيلم';

  @override
  String get badgeSeriesUppercase => 'مسلسل';

  @override
  String get settingsEpgPresetsTitle => 'مصادر جاهزة';

  @override
  String get menuMyPlaylists => 'قوائم التشغيل الخاصة بي';

  @override
  String get menuEpgSettings => 'إعدادات EPG';

  @override
  String get menuNewlyAdded => 'المضافة حديثًا';

  @override
  String get menuContinueWatching => 'تابع المشاهدة';

  @override
  String get authSignInTitle => 'تسجيل الدخول';

  @override
  String get authSignUpTitle => 'إنشاء حساب';

  @override
  String get authAccountTitle => 'حسابي';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authSignInButton => 'تسجيل الدخول';

  @override
  String get authSignUpButton => 'إنشاء حساب';

  @override
  String get authSignOutButton => 'تسجيل الخروج';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور';

  @override
  String get authResetPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordHint => 'سنرسل رابط إعادة التعيين إلى بريدك الإلكتروني.';

  @override
  String get authResetPasswordSent => 'تم إرسال الرابط. تحقق من صندوق الوارد.';

  @override
  String get authNoAccountQuestion => 'ليس لديك حساب؟ سجّل';

  @override
  String get authHaveAccountQuestion => 'لدي حساب بالفعل';

  @override
  String get authOrDivider => 'أو';

  @override
  String get authSignInWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authSignInWithApple => 'المتابعة باستخدام Apple';

  @override
  String get authAcceptTerms => 'أوافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get authViewTerms => 'عرض الشروط';

  @override
  String get authErrorInvalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get authErrorWeakPassword => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get authErrorPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authErrorEmailInUse => 'هذا البريد الإلكتروني قيد الاستخدام بالفعل';

  @override
  String get authErrorWrongPassword => 'بريد إلكتروني أو كلمة مرور خاطئة';

  @override
  String get authErrorTooManyRequests => 'محاولات كثيرة جدًا. حاول لاحقًا.';

  @override
  String get authErrorNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String authErrorGeneric(String message) {
    return 'حدث خطأ ما: $message';
  }

  @override
  String get authVerifyEmailHint => 'أرسلنا لك رابط تحقق إلى بريدك الإلكتروني.';

  @override
  String get authAppleHiddenEmail => 'مستخدم Apple';

  @override
  String get authAppleHiddenEmailHint => 'البريد مخفي عبر Apple — لم تتم مشاركته';

  @override
  String get authResendVerification => 'إعادة إرسال التحقق';

  @override
  String get authChangePassword => 'تغيير كلمة المرور';

  @override
  String get authDeleteAccount => 'حذف الحساب';

  @override
  String get authDeleteAccountWarning => 'حذف حسابك يزيل جميع بيانات السحابة بشكل دائم. لا يمكن التراجع عن هذا.';

  @override
  String get authDeleteAccountConfirm => 'نعم، احذف حسابي';

  @override
  String get authAccountSection => 'الحساب';

  @override
  String get authNotSignedIn => 'لم يتم تسجيل الدخول';

  @override
  String get authSignInPromptTitle => 'أنشئ حسابًا → جرّب Pro';

  @override
  String get authSignInPromptDesc => 'سجّل للحصول على قوائم تشغيل غير محدودة وترجمة الذكاء الاصطناعي والمزامنة عبر الأجهزة.';

  @override
  String get authProActive => 'عضو Pro';

  @override
  String get authFreeTier => 'الخطة المجانية';

  @override
  String get authUpgradeToPro => 'الترقية إلى Pro';

  @override
  String get authRequiresRecentLogin => 'هذا الإجراء يتطلب تسجيل دخول حديث. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get paywallTitle => 'احصل على Pro، أزِل القيود';

  @override
  String get paywallSubtitle => 'ترجمة الذكاء الاصطناعي، قوائم تشغيل غير محدودة، مزامنة عبر الأجهزة — كل ذلك بشراء واحد.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'قوائم تشغيل غير محدودة';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream، M3U، Stalker — بلا حدود';

  @override
  String get paywallBenefitAiSubtitles => 'ترجمة الذكاء الاصطناعي';

  @override
  String get paywallBenefitAiSubtitlesDesc => 'أكثر من 100 لغة (40 ساعة/شهر)';

  @override
  String get paywallBenefitCloudSync => 'مزامنة سحابية';

  @override
  String get paywallBenefitCloudSyncDesc => 'المفضلة والسجل عبر الأجهزة';

  @override
  String get paywallBenefitTvApps => 'TV + هاتف';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV، Google TV، iPhone، iPad';

  @override
  String get paywallPlanMonthly => 'شهري';

  @override
  String get paywallPlanYearly => 'سنوي';

  @override
  String get paywallPlanLifetime => 'مدى الحياة';

  @override
  String get paywallBadgeBest => 'الأفضل';

  @override
  String get paywallBadgePopular => 'شائع';

  @override
  String get paywallSubscribeButton => 'احصل على Pro';

  @override
  String get paywallRestoreButton => 'استعادة المشتريات';

  @override
  String get paywallSignInRequired => 'سجّل الدخول للمتابعة.';

  @override
  String get paywallSignInButton => 'سجّل الدخول أولاً';

  @override
  String get paywallTermsFooter => 'تتجدد الاشتراكات تلقائيًا. يمكنك الإدارة من الإعدادات.';

  @override
  String get paywallPrivacyLink => 'سياسة الخصوصية';

  @override
  String get paywallTermsLink => 'شروط الاستخدام';

  @override
  String get paywallPurchaseSuccess => 'تم تفعيل Pro. استمتع!';

  @override
  String get paywallPurchaseCancelled => 'تم إلغاء الشراء.';

  @override
  String paywallPurchaseError(String message) {
    return 'فشل الشراء: $message';
  }

  @override
  String get paywallNotConfigured => 'لم يتم تكوين عمليات الشراء بعد. حاول لاحقًا.';

  @override
  String get paywallNoOfferings => 'لا توجد عروض متاحة.';

  @override
  String get paywallTriggerSecondPlaylist => 'Pro مطلوب لإضافة قائمة تشغيل ثانية';

  @override
  String get paywallTriggerAiSubtitle => 'Pro مطلوب للترجمة بالذكاء الاصطناعي';

  @override
  String get paywallTriggerCloudSync => 'Pro مطلوب للمزامنة السحابية';

  @override
  String get welcomeTitle => 'مرحبًا';

  @override
  String get welcomeSubtitle => 'أفلام ومسلسلات وبث مباشر بلا حدود في انتظارك.';

  @override
  String get welcomeFeatureUnlimited => 'قنوات ومفضلات بلا حدود';

  @override
  String get welcomeFeatureSubtitles => 'ترجمات ذكية (أكثر من 100 لغة)';

  @override
  String get welcomeFeatureSync => 'مزامنة عبر الأجهزة';

  @override
  String get welcomeStartFreeButton => 'أنشئ حسابًا → جرّب Pro';

  @override
  String get welcomeSkipButton => 'تخطّى الآن';

  @override
  String get welcomeSignInLink => 'لدي حساب بالفعل';

  @override
  String get watchlistTitle => 'قائمة المشاهدة';

  @override
  String get watchlistEmpty => 'قائمتك فارغة';

  @override
  String get watchlistEmptyHint => 'عند حفظ فيلم أو مسلسل، سيظهر هنا.';

  @override
  String get themePickerTitle => 'السمة';

  @override
  String get themeDefaultDark => 'الافتراضي الداكن';

  @override
  String get themeDefaultLight => 'الافتراضي الفاتح';

  @override
  String get themeCrimson => 'الفجر القرمزي';

  @override
  String get themeRoyal => 'البنفسجي الملكي';

  @override
  String get themeForest => 'الغابة العميقة';

  @override
  String get themeOcean => 'أزرق المحيط';

  @override
  String get parentalLockTitle => 'قفل الأبوي';

  @override
  String get parentalLockEnable => 'تفعيل قفل الأبوي';

  @override
  String get parentalLockEnabledHint => 'مطلوب رمز PIN للفئات المقفلة.';

  @override
  String get parentalLockSetupFirst => 'أنشئ رمز PIN مكون من 4 أرقام أولاً.';

  @override
  String get parentalSetupPin => 'إنشاء PIN';

  @override
  String get parentalChangePin => 'تغيير PIN';

  @override
  String get parentalRemovePin => 'إزالة قفل الأبوي';

  @override
  String get parentalLockedCategoriesTitle => 'الفئات المقفلة';

  @override
  String get parentalNoCategories => 'لا توجد فئات بعد. حمّل قائمة تشغيل أولاً.';

  @override
  String get parentalEnterPin => 'أدخل رمز PIN';

  @override
  String get parentalNewPin => 'PIN جديد';

  @override
  String get parentalCurrentPin => 'PIN الحالي';

  @override
  String get parentalConfirmPin => 'تأكيد PIN';

  @override
  String get parentalPinIncorrect => 'PIN غير صحيح';

  @override
  String get parentalPinFourDigits => 'يجب أن يكون PIN مكونًا من 4 أرقام';

  @override
  String get parentalPinMismatch => 'رموز PIN غير متطابقة';

  @override
  String get parentalPinChanged => 'تم تحديث PIN';

  @override
  String get parentalSubmit => 'موافق';

  @override
  String get parentalNext => 'التالي';

  @override
  String get cloudSyncTitle => 'مزامنة سحابية';

  @override
  String get cloudSyncProRequired => 'اشتراك Pro مطلوب';

  @override
  String get cloudSyncSignInRequired => 'سجّل الدخول ثم زامن';

  @override
  String get cloudSyncNever => 'لم تتم المزامنة بعد';

  @override
  String get cloudSyncSyncNow => 'زامن الآن';

  @override
  String get cloudSyncJustNow => 'للتو';

  @override
  String cloudSyncMinutesAgo(int n) {
    return 'قبل $n د';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return 'قبل $n س';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return 'قبل $n يوم';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'آخر مزامنة: $when';
  }

  @override
  String get epgGuideTitle => 'دليل البرامج';

  @override
  String get epgToday => 'اليوم';

  @override
  String get epgYesterday => 'أمس';

  @override
  String get epgTomorrow => 'غدًا';

  @override
  String get epgRowEmpty => 'لا برامج لهذه القناة';

  @override
  String get epgNoData => 'لا توجد بيانات EPG';

  @override
  String get epgNoDataHint => 'انتقل إلى الإعدادات → EPG، أدخل عنوان URL ثم اضغط \'تحديث الآن\'.';

  @override
  String epgError(String msg) {
    return 'خطأ EPG: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'تحديث تلقائي';

  @override
  String get epgAutoRefreshOff => 'إيقاف';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'كل $h ساعة';
  }

  @override
  String get playerPipTooltip => 'نافذة صغيرة (Pro)';

  @override
  String get playerPipUnavailable => 'PiP غير مدعوم على هذا الجهاز';

  @override
  String get playerPipEntered => 'يتم التشغيل في نافذة صغيرة';

  @override
  String get playerAirplayTooltip => 'AirPlay (الصوت)';

  @override
  String get playerAirplayUnavailable => 'AirPlay غير متوفر على هذا الجهاز';

  @override
  String get playerAirplayAudioOnlyHint => 'يرسل AirPlay الصوت إلى التلفزيون. للفيديو استخدم مركز التحكم > نسخ الشاشة.';

  @override
  String get playerCastTooltip => 'Cast (قريبًا)';

  @override
  String get settingsPipSection => 'نافذة صغيرة';

  @override
  String get settingsPipAuto => 'PiP تلقائي عند زر Home';

  @override
  String get settingsPipAutoSubtitle => 'Pro — عند فتح المشغل والضغط على Home ينتقل التشغيل إلى نافذة صغيرة';

  @override
  String get settingsAdsSection => 'الإعلانات';

  @override
  String get settingsAdsRemoved => 'Pro: بدون إعلانات';

  @override
  String get settingsAdsFreeNotice => 'الإصدار المجاني يعرض إعلانًا في الأسفل. اشترك في Pro لتجربة بدون إعلانات.';

  @override
  String get settingsProSection => 'مزايا Pro';

  @override
  String get settingsContentSection => 'المحتوى';

  @override
  String get settingsPlayerSection => 'المشغّل';

  @override
  String get settingsLegalNotice => 'إشعار قانوني';

  @override
  String get settingsDataDeletion => 'طلب حذف البيانات';

  @override
  String get settingsDataDeletionSubtitle => 'طلب إزالة الحساب والبيانات';

  @override
  String get settingsTapToSignIn => 'سجّل الدخول أو أنشئ حسابًا';

  @override
  String get commonHide => 'إخفاء';

  @override
  String get commonShow => 'إظهار';

  @override
  String get profileSwitcherTitle => 'الملفات الشخصية';

  @override
  String get profileDefaultName => 'افتراضي';

  @override
  String get profileAdd => 'ملف جديد';

  @override
  String get profileEdit => 'تعديل الملف';

  @override
  String get profileDelete => 'حذف الملف';

  @override
  String get profileDeleteConfirm => 'سيتم حذف هذا الملف والمفضلة وقائمة المشاهدة الخاصة به. متابعة؟';

  @override
  String get profileNameLabel => 'اسم الملف';

  @override
  String get profileEmptyName => 'لا يمكن أن يكون اسم الملف فارغًا';

  @override
  String get profileSwitched => 'تم تبديل الملف';

  @override
  String get profileMaxFreeReached => 'الإصدار المجاني يدعم ملفًا واحدًا. Pro يفتح ملفات غير محدودة.';

  @override
  String get profileSection => 'الملف';

  @override
  String get otherAppsTitle => 'تطبيقاتنا الأخرى';

  @override
  String get otherAppsSubtitle => 'تطبيقات أخرى من تطوير فريقنا';

  @override
  String get otherAppsEmpty => 'تعذّر تحميل القائمة. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get otherAppsRetry => 'إعادة المحاولة';

  @override
  String get otherAppsOpenFailed => 'تعذّر فتح المتجر.';

  @override
  String get otherAppsGateTitle => 'تحقق الوالدين';

  @override
  String get otherAppsGateQuestion => 'للمتابعة، اكتب ناتج العملية:';

  @override
  String get otherAppsCancel => 'إلغاء';

  @override
  String get otherAppsContinue => 'متابعة';

  @override
  String get editPlaylistTitle => 'تعديل قائمة التشغيل';

  @override
  String get editPlaylistNotFound => 'قائمة التشغيل غير موجودة';

  @override
  String get editPlaylistXtreamBadge => 'Xtream Codes';

  @override
  String get editPlaylistM3uBadge => 'قائمة M3U';

  @override
  String get editPlaylistAddedAt => 'تمت الإضافة في';

  @override
  String get editPlaylistExpiry => 'تنتهي في';

  @override
  String get editPlaylistExpiredLabel => '⚠ منتهية';

  @override
  String get editPlaylistValidLabel => '✓ سارية';

  @override
  String get editPlaylistUrlLabel => 'رابط الخادم';

  @override
  String get editPlaylistRefreshButton => 'تحديث القنوات';

  @override
  String get editPlaylistDeleteButton => 'حذف قائمة التشغيل';

  @override
  String get deletePlaylistDialogTitle => 'حذف قائمة التشغيل';

  @override
  String get deletePlaylistDialogQuestion => 'كيف تريد حذفها؟';

  @override
  String get deleteDeviceExplain => 'تُزال من هذا الجهاز فقط. تبقى النسخة السحابية، ويمكنك استعادتها في أي وقت عبر \"تنزيل من السحابة\".';

  @override
  String get deleteDeviceExplainLocal => 'تُزال من هذا الجهاز. هذه القائمة غير محفوظة في السحابة، لذا ستحتاج إلى إضافتها من جديد لاستعادتها.';

  @override
  String get deletePlaylistFromCloud => 'حذف من السحابة';

  @override
  String get deletePlaylistFromDevice => 'حذف من الجهاز';

  @override
  String get deleteCloudExplain => 'تُحذف نهائيًا من هذا الجهاز ومن السحابة، ولن تظهر مجددًا على أجهزتك الأخرى.';

  @override
  String get progressDownloadingList => 'جارٍ تنزيل قائمة القنوات…';

  @override
  String progressRetrying(int attempt) {
    return 'جارٍ إعادة المحاولة ($attempt/3)…';
  }

  @override
  String get progressParsingList => 'جارٍ معالجة قائمة القنوات…';

  @override
  String progressChannelsSaved(int count) {
    return 'تم حفظ $count قناة…';
  }

  @override
  String get progressServerConnecting => 'جارٍ الاتصال بالخادم…';

  @override
  String get progressLoadingLive => 'جارٍ تحميل القنوات المباشرة…';

  @override
  String get progressLoadingMovies => 'جارٍ تحميل الأفلام…';

  @override
  String get progressLoadingSeries => 'جارٍ تحميل المسلسلات…';

  @override
  String get loadErrM3uNotFound => 'لم يُعثر على قائمة قنوات في هذا العنوان. تأكّد من أن العنوان يخص قائمة M3U.';

  @override
  String loadErrIncomplete(int count, int total) {
    return 'وصلت القائمة ناقصة ($count / $total قناة) — ربما انقطع الاتصال. تم الاحتفاظ بقائمتك الحالية، حاول مرة أخرى.';
  }

  @override
  String get loadErrServerEmpty => 'أرسل الخادم قائمة فارغة. تأكّد من أن اشتراكك يتضمن قنوات، وإذا استمرت المشكلة فتواصل مع مزوّد الخدمة.';

  @override
  String get loadErrSeriesInfo => 'تعذّر تحميل بيانات هذا المسلسل. حدّث القائمة وحاول مرة أخرى.';

  @override
  String get loadErrNoEpisodes => 'لم يرسل مزوّد الخدمة أي حلقات لهذا المسلسل.';

  @override
  String loadErrDrasticShrink(int count, int total) {
    return 'أرسل الخادم $count قناة فقط (سابقًا $total). ربما انتهى اشتراكك؛ تم الاحتفاظ بقائمتك الحالية.';
  }

  @override
  String syncShrinkKept(String type) {
    return '$type: أرسل الخادم محتوى أقل بكثير من السابق، لذلك تم الاحتفاظ بالمحتوى الحالي.';
  }

  @override
  String get playlistSyncQueued => 'تم حفظ التغييرات. سيُعاد تنزيل القائمة عند انتهاء التحديث الجاري.';

  @override
  String get errorReportPreviewLabel => 'النص الذي سيُرسل (بيانات الدخول مخفية):';

  @override
  String paywallPricePerMonths(String price, int months) {
    return '$price / $months أشهر';
  }

  @override
  String paywallPlanMonths(int months) {
    return '$months أشهر';
  }

  @override
  String paywallIntroPriceThen(String intro, String price) {
    return '$intro سعر تمهيدي، ثم $price';
  }

  @override
  String get watchlistClearAll => 'مسح القائمة';

  @override
  String get watchlistClearConfirm => 'حذف جميع العناصر؟';

  @override
  String get categoryFilterPlaylist => 'قائمة التشغيل';

  @override
  String get settingsRefreshOff => 'إيقاف';

  @override
  String get settingsRefreshOnOpen => 'عند كل تشغيل';

  @override
  String get settingsRefresh1Day => 'كل يوم';

  @override
  String get settingsRefresh1Week => 'كل أسبوع';

  @override
  String get settingsRefresh1Month => 'كل شهر';

  @override
  String get settingsRefresh1Year => 'كل سنة';

  @override
  String get settingsClearHistoryTitle => 'Geçmişi Temizle';

  @override
  String get settingsClearHistorySubtitle => 'Son İzlenenler, Nerede Kaldım ve İzlenenler listelerini temizler. Favorileriniz silinmez';

  @override
  String get settingsClearHistoryDialogTitle => 'İzleme geçmişi temizlensin mi?';

  @override
  String get settingsClearHistoryDialogMessage => 'Son İzlenenler, Nerede Kaldım ve İzlenenler listelerindeki tüm kayıtlar silinecek. Bu işlem geri alınamaz.';

  @override
  String get settingsClearHistoryAction => 'Temizle';

  @override
  String epgNextProgram(String title) {
    return 'التالي: $title';
  }

  @override
  String get xtreamBadLogin => 'اسم المستخدم أو كلمة المرور غير صحيحة. تحقّق من بياناتك لدى مزوّد الخدمة وحاول مرة أخرى.';

  @override
  String get xtreamExpired => 'انتهت صلاحية اشتراكك. تواصل مع مزوّد الخدمة لتجديده.';

  @override
  String xtreamExpiredOn(String date) {
    return 'انتهت صلاحية اشتراكك في $date. تواصل مع مزوّد الخدمة لتجديده.';
  }

  @override
  String get xtreamDisabled => 'قام مزوّد الخدمة بإيقاف حسابك. تواصل مع مزوّد الخدمة.';

  @override
  String get epgAutoRefreshAuto => 'تلقائي — يُحدَّث عندما يوشك الدليل على الانتهاء';

  @override
  String xtreamPartialLoad(String type) {
    return 'تعذّر تحميل بعض المحتوى: $type';
  }

  @override
  String get settingsPlaylistAutoRefreshTitle => 'التحديث التلقائي لقائمة التشغيل';

  @override
  String settingsEpgUrlForPlaylist(String name) {
    return 'لقائمة التشغيل النشطة: $name';
  }

  @override
  String get settingsClearHistoryDone => 'تم مسح سجل المشاهدة';

  @override
  String get settingsSupportSection => 'الدعم';

  @override
  String get settingsFeedbackTitle => 'إرسال ملاحظات';

  @override
  String get settingsFeedbackSubtitle => 'اقتراحات أو بلاغات أخطاء أو ملاحظات عامة';

  @override
  String get feedbackDialogTitle => 'الملاحظات';

  @override
  String get feedbackThanks => 'شكرًا لك!';

  @override
  String get feedbackReceived => 'تم استلام ملاحظاتك.';

  @override
  String get feedbackChooseType => 'اختر النوع:';

  @override
  String get feedbackTypeSuggestion => 'اقتراح';

  @override
  String get feedbackTypeBug => 'بلاغ خطأ';

  @override
  String get feedbackTypeGeneral => 'عام';

  @override
  String get feedbackNameLabel => 'الاسم';

  @override
  String get feedbackNamePlaceholder => 'اختياري';

  @override
  String get feedbackEmailLabel => 'البريد الإلكتروني *';

  @override
  String get feedbackEmailPlaceholder => 'example@mail.com';

  @override
  String get feedbackEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get feedbackMessageLabel => 'رسالتك *';

  @override
  String get feedbackMessagePlaceholder => 'اكتب لنا أفكارك…';

  @override
  String get feedbackScreenshotLabel => 'لقطات الشاشة (٣ كحد أقصى)';

  @override
  String get feedbackAddImage => 'إضافة صورة';

  @override
  String feedbackError(String details) {
    return 'تعذّر الإرسال: $details';
  }

  @override
  String get feedbackImageTooLarge => 'لا يمكن إرفاق صور أكبر من 5 ميغابايت';

  @override
  String get commonSend => 'إرسال';

  @override
  String get commonSending => 'جارٍ الإرسال…';

  @override
  String get settingsRateApp => 'قيّم التطبيق';

  @override
  String get settingsRateAppSubtitle => 'قيّم واكتب مراجعة في App Store';

  @override
  String paywallBenefitPlaylistsUpTo(int count) {
    return 'حتى $count قوائم تشغيل';
  }

  @override
  String get paywallBenefitAiWhisper => 'ترجمة Whisper بالذكاء الاصطناعي';

  @override
  String get paywallBenefitCloudSyncDevices => 'مزامنة سحابية بين الأجهزة';

  @override
  String get paywallBenefitThemes => 'سمات Premium';

  @override
  String get paywallBenefitWatchlist => 'قائمة المشاهدة';

  @override
  String get paywallBenefitEpgAuto => 'تحديث EPG التلقائي';

  @override
  String paywallPricePerYear(String price) {
    return '$price / سنة';
  }

  @override
  String paywallPricePerMonth(String price) {
    return '$price / شهر';
  }

  @override
  String paywallPricePerWeek(String price) {
    return '$price / أسبوع';
  }

  @override
  String paywallPriceOneTime(String price) {
    return '$price لمرة واحدة';
  }

  @override
  String paywallMonthlyEquivalent(String price) {
    return 'فقط $price / شهر';
  }

  @override
  String paywallTrialThen(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'أول $days يوم مجانًا',
      many: 'أول $days يومًا مجانًا',
      few: 'أول $days أيام مجانًا',
      two: 'أول يومين مجانًا',
      one: 'أول يوم مجانًا',
    );
    return '$_temp0، ثم $price. يمكنك الإلغاء في أي وقت.';
  }

  @override
  String get paywallLifetimeHint => '✦ دفعة واحدة · وصول مدى الحياة';

  @override
  String get paywallPurchase => 'شراء';

  @override
  String get paywallTermsFooterApple => 'يتم تحصيل الدفعة من حساب Apple ID عند تأكيد الشراء. تتجدد الاشتراكات تلقائيًا ما لم يتم إلغاؤها قبل 24 ساعة على الأقل من نهاية الفترة الحالية. يمكنك إدارتها أو إلغاؤها من إعدادات حساب App Store.';

  @override
  String get paywallActivationPending => 'تمت عملية الشراء لكن Pro لم يُفعَّل بعد. جرّب استعادة مشترياتك؛ وإذا استمرت المشكلة، تواصل مع الدعم.';

  @override
  String get paywallLoadError => 'تعذّر تحميل الخطط. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String playlistDeviceLimit(int count) {
    return 'يدعم هذا الجهاز $count قائمة كحدّ أقصى.';
  }

  @override
  String get authReauthTitle => 'أكّد هويتك';

  @override
  String get authReauthPasswordMessage => 'أدخل كلمة المرور لحذف حسابك.';

  @override
  String get authAccountDeleted => 'تم حذف حسابك.';

  @override
  String get playerUrlMissing => 'لم يتم العثور على رابط البث';

  @override
  String parentalPinWrongAttempts(int remaining) {
    return 'رمز PIN خاطئ. المحاولات المتبقية: $remaining.';
  }

  @override
  String parentalPinCooldown(int seconds) {
    return 'محاولات خاطئة كثيرة. انتظر $seconds ثانية.';
  }

  @override
  String get paywallRestoreNothing => 'لم يتم العثور على مشتريات سابقة لحساب Apple ID هذا.';
}
