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
  String get playerAirplayTooltip => 'AirPlay (Pro)';

  @override
  String get playerAirplayUnavailable => 'AirPlay على iOS فقط';

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
}
