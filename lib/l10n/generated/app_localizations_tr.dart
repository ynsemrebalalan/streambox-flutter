// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'İPTV Ai Player';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get error => 'Hata';

  @override
  String get errorGeneric => 'Bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageGerman => 'Almanca';

  @override
  String get languageArabic => 'Arapça';

  @override
  String get languageItalian => 'İtalyanca';

  @override
  String get languageSpanish => 'İspanyolca';

  @override
  String get languageRomanian => 'Rumence';

  @override
  String errorWithDetails(String details) {
    return 'Hata: $details';
  }

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonRefresh => 'Yenile';

  @override
  String get commonDeleteConfirm => 'Sil';

  @override
  String get errorTimeoutProvider => 'Sağlayıcı cevap veremedi. Birazdan tekrar deneyin.';

  @override
  String get errorNoConnection => 'İnternet bağlantısı yok veya sağlayıcıya ulaşılamıyor.';

  @override
  String get errorDatabaseTemporary => 'Veri tabanı geçici olarak yanıt vermedi. Lütfen tekrar deneyin.';

  @override
  String get errorGenericRetry => 'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSaved => 'Ayarlar kaydedildi';

  @override
  String get settingsAppearanceSection => 'Görünüm';

  @override
  String get settingsThemeDark => 'Koyu Tema';

  @override
  String get settingsThemeLight => 'Açık Tema';

  @override
  String get settingsThemeSystem => 'Sistem Teması';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'EPG URL (.xml veya .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'EPG\'yi Şimdi Güncelle';

  @override
  String get settingsSelectPlaylistFirst => 'Önce bir playlist seçin';

  @override
  String get settingsEpgUpdated => 'EPG başarıyla güncellendi';

  @override
  String settingsEpgError(String details) {
    return 'EPG hatası: $details';
  }

  @override
  String get settingsSubtitleSection => 'Altyazı';

  @override
  String get settingsSubtitleFontSize => 'Yazı Boyutu';

  @override
  String get subtitleSizeSmall => 'Küçük';

  @override
  String get subtitleSizeNormal => 'Normal';

  @override
  String get subtitleSizeLarge => 'Büyük';

  @override
  String get subtitleSizeExtraLarge => 'Çok Büyük';

  @override
  String get settingsSubtitleTextColor => 'Yazı Rengi';

  @override
  String get subtitleColorWhite => 'Beyaz';

  @override
  String get subtitleColorYellow => 'Sarı';

  @override
  String get subtitleColorGreen => 'Yeşil';

  @override
  String get subtitleColorCyan => 'Camgöbeği';

  @override
  String get settingsSubtitleBgColor => 'Arka Plan';

  @override
  String get subtitleBgSemi => 'Yarı Saydam';

  @override
  String get subtitleBgOpaque => 'Siyah';

  @override
  String get subtitleBgNone => 'Yok';

  @override
  String get settingsAboutSection => 'Hakkında';

  @override
  String settingsAppVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsPlaylistManagement => 'Playlist Yönetimi';

  @override
  String get settingsCategoryFilterSubtitle => 'Kategorileri gizle/göster';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Başlamak için bir playlist ekleyin';

  @override
  String get homeAddPlaylist => 'Playlist Ekle';

  @override
  String get homeSearchHint => 'Kanal, film, dizi ara...';

  @override
  String get homePlaylistsTooltip => 'Playlist\'ler';

  @override
  String get homeMore => 'Daha Fazla';

  @override
  String get homePlaylistSyncing => 'Playlist senkronize ediliyor…';

  @override
  String get homeSearchTooltip => 'Ara';

  @override
  String get watchlistAddTooltip => 'Listeme Ekle';

  @override
  String get watchlistRemoveTooltip => 'Listeden Çıkar';

  @override
  String get playerPlayAction => 'Oynat';

  @override
  String get playerPauseAction => 'Duraklat';

  @override
  String get playlistsActiveLabel => 'Aktif';

  @override
  String get homeCategoryManagement => 'Kategori Yönetimi';

  @override
  String get homeTabHome => 'Ana Sayfa';

  @override
  String get homeTabLive => 'Canlı';

  @override
  String get homeTabMovie => 'Film';

  @override
  String get homeTabSeries => 'Dizi';

  @override
  String get homeTabFavorites => 'Favoriler';

  @override
  String get homeFavoritesAll => 'Tümü';

  @override
  String get homeFavoritesLive => 'Canlı';

  @override
  String get homeFavoritesMovie => 'Filmler';

  @override
  String get homeFavoritesSeries => 'Diziler';

  @override
  String get homeEmptyFavorites => 'Favori eklenmemiş';

  @override
  String get homeEmptyFavoritesType => 'Bu tipte favori yok';

  @override
  String get homeEmptyCategory => 'Bu kategoride içerik yok';

  @override
  String get homeRowContinueWatching => 'Devam Et';

  @override
  String get homeRowRecentlyWatched => 'Son İzlenenler';

  @override
  String get homeRowNewMovies => 'Yeni Filmler';

  @override
  String get homeRowNewSeries => 'Yeni Diziler';

  @override
  String get homeRowNewChannels => 'Yeni Kanallar';

  @override
  String get homeEmptyContent => 'Henüz içerik yok';

  @override
  String get homeEmptyContentHint => 'Film / Dizi / Canlı sekmelerinden göz atmaya başlayın';

  @override
  String get homeRecentlyWatchedHeader => 'SON İZLENENLER';

  @override
  String get homeSearchEmpty => 'Aramak için yazmaya başlayın';

  @override
  String homeSearchNoResults(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String homeContentCount(int count) {
    return '$count içerik';
  }

  @override
  String get sortDialogTitle => 'Sıralama';

  @override
  String get sortLabelDefault => 'Varsayılan';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Sıralama';

  @override
  String get playlistsTitle => 'Playlist\'ler';

  @override
  String get playlistsEmpty => 'Henüz playlist yok';

  @override
  String get playlistsRefreshTooltip => 'Yenile';

  @override
  String get playlistsDeleteTooltip => 'Sil';

  @override
  String get playlistsRetryAction => 'TEKRAR';

  @override
  String get playlistsUpdated => 'Playlist güncellendi.';

  @override
  String get playlistsDeleteTitle => 'Playlist Sil';

  @override
  String playlistsDeleteConfirm(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get playlistsAddTitle => 'Playlist Ekle';

  @override
  String get playlistsTypeM3u => 'M3U URL';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsTypeStalker => 'Stalker / MAG';

  @override
  String get playlistsStalkerCardTitle => 'Stalker Portal / MAG Kutu';

  @override
  String get playlistsStalkerCardBody => 'MAC adresinizin IPTV sağlayıcınıza kayıtlı olması gerekir. Uygulama önce hızlı M3U yolunu dener, başarısız olursa tam Stalker protokolüne geçer.';

  @override
  String get playlistsStalkerPortalLabel => 'Portal URL';

  @override
  String get playlistsStalkerPortalHint => 'http://provider.com:8080';

  @override
  String get playlistsStalkerMacLabel => 'MAC Adresi';

  @override
  String get playlistsStalkerMacHint => '00:1A:79:XX:XX:XX';

  @override
  String get playlistsStalkerMacGenerate => 'Üret';

  @override
  String get playlistsStalkerMacHelp => 'MAC biçimi: XX:XX:XX:XX:XX:XX (büyük harf, iki nokta üst üste ile ayrılmış)';

  @override
  String get playlistsValidationStalkerMac => 'Geçerli bir MAC adresi girin (XX:XX:XX:XX:XX:XX).';

  @override
  String get editPlaylistStalkerBadge => 'Stalker / MAG';

  @override
  String get progressTryingPortalList => 'Liste portaldan alınmaya çalışılıyor…';

  @override
  String get progressPortalConnecting => 'Portala bağlanılıyor…';

  @override
  String get loadErrPortalConnect => 'Portala bağlanılamadı. Portal adresini ve MAC adresinizin sağlayıcıya kayıtlı olduğunu kontrol edin.';

  @override
  String get loadErrPortalList => 'Kanal listesi alınamadı. MAC adresinizin portala kayıtlı olduğunu sağlayıcınızdan doğrulayın.';

  @override
  String get playlistsNameLabel => 'Playlist Adı';

  @override
  String get playlistsM3uUrlLabel => 'M3U URL';

  @override
  String get playlistsM3uUrlHint => 'http://... veya https://...';

  @override
  String get playlistsPasteFromClipboard => 'Panodan Yapıştır';

  @override
  String get playlistsClipboardEmpty => 'Pano boş';

  @override
  String get playlistsServerUrlLabel => 'Sunucu URL';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'Kullanıcı Adı';

  @override
  String get playlistsPasswordLabel => 'Şifre';

  @override
  String get playlistsContentTypes => 'İçerik Tipleri';

  @override
  String get playlistsContentLive => 'Canlı';

  @override
  String get playlistsContentMovie => 'Film';

  @override
  String get playlistsContentSeries => 'Dizi';

  @override
  String get playlistsValidationNameUrl => 'Ad ve URL zorunlu';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream için kullanıcı adı ve şifre gerekli';

  @override
  String get playlistsErrorTlsHandshake => 'Güvenli bağlantı kurulamadı (TLS hatası). URL\'yi http:// ile deneyin veya sağlayıcı adresini kontrol edin.';

  @override
  String get playlistsErrorTimeout => 'Sağlayıcı cevap veremedi (timeout). Birazdan tekrar deneyin.';

  @override
  String get playlistsErrorConnection => 'İnternet bağlantısı yok veya sağlayıcıya ulaşılamıyor.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'Playlist güncellenemedi: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'Sağlayıcı boş playlist döndü. Eski veri korundu.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Yeniden bağlanılıyor ($attempt)...';
  }

  @override
  String get playerReconnecting => 'Yeniden bağlanılıyor...';

  @override
  String get playerLoading => 'Yükleniyor...';

  @override
  String get playerStreamRepeatedError => 'Yayın kaynağında sürekli kesinti. Kanalı değiştirmeyi deneyin.';

  @override
  String get playerReconnectTooltip => 'Yeniden bağlan';

  @override
  String get playerSubtitleEnable => 'AI Altyazı Aç';

  @override
  String get playerSubtitleDisable => 'AI Altyazı Kapat';

  @override
  String get playerMuteTooltip => 'Sessize al';

  @override
  String get playerUnmuteTooltip => 'Sesi aç';

  @override
  String get playerLiveLabel => 'CANLI';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Ses parçası';

  @override
  String get playerAudioTrackDialog => 'Ses parçası';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Parça $n';
  }

  @override
  String get playerSpeedDialog => 'Oynatma hızı';

  @override
  String get playerSubtitleDialogTitle => 'Altyazı';

  @override
  String get playerSubtitleAi => 'AI Altyazı';

  @override
  String get playerSubtitleAiActive => '(Aktif)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Yerleşik $n';
  }

  @override
  String get playerSubtitleOff => 'Kapalı';

  @override
  String get playerScreenSizeTooltip => 'Ekran Boyutu';

  @override
  String get playerScreenSizeDialog => 'Ekran Boyutu';

  @override
  String get playerFitOriginal => 'Orijinal';

  @override
  String get playerFitCover => 'Ekranı Doldur (Kırp)';

  @override
  String get playerFitStretch => 'Esnet';

  @override
  String get playerResolutionTooltip => 'Çözünürlük';

  @override
  String get playerResolutionDialog => 'Çözünürlük';

  @override
  String get playerResolutionAuto => 'Otomatik';

  @override
  String get playerSingleQuality => 'Bu yayın tek kalite sunuyor.';

  @override
  String get playerErrorUnsupportedFormat => 'Bu yayının görüntü veya ses biçimi bu cihazda oynatılamıyor. Başka bir kaynak deneyin ya da harici oynatıcıyı kullanın.';

  @override
  String get playerErrorCorruptStream => 'Yayın verisi okunamadı. Kanal geçici olarak bozuk olabilir; biraz sonra tekrar deneyin.';

  @override
  String get aiSubErrUnavailable => 'AI altyazı servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get aiSubErrProRequired => 'AI altyazı denemen bitti. Devam etmek için Pro sürümüne geç.';

  @override
  String get aiSubErrQuota => 'AI altyazı kullanım kotası doldu.';

  @override
  String get aiSubErrBusy => 'AI altyazı servisi şu an çok yoğun. Biraz bekleyip tekrar deneyin.';

  @override
  String get aiSubErrInvalidKey => 'AI altyazı API anahtarı geçersiz veya süresi dolmuş. Ayarlar > AI Altyazı bölümünden kontrol edin.';

  @override
  String get aiSubErrRejected => 'AI altyazı servisi isteği kabul etmedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get aiSubErrEmptyResponse => 'AI altyazı servisi boş yanıt gönderdi. Lütfen tekrar deneyin.';

  @override
  String get aiSubErrNoSpeech => 'Bu bölümde konuşma algılanamadı. Videonun farklı bir anında tekrar deneyin.';

  @override
  String get aiSubErrGeneric => 'Altyazı oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get aiSubErrUnreachable => 'AI altyazı servisine ulaşılamıyor. İnternet bağlantınızı kontrol edin.';

  @override
  String get aiSubErrConnectTimeout => 'AI altyazı servisine bağlanırken zaman aşımı oldu. Lütfen tekrar deneyin.';

  @override
  String get aiSubErrExtract => 'AI altyazı için ses alınamadı. Bu yayının biçimi bazı cihazlarda desteklenmiyor. Daha düşük kaliteli bir kaynak deneyin ya da harici oynatıcıda izleyin.';

  @override
  String get aiSubErrNoOpenAiKey => 'OpenAI API anahtarı girilmedi. Ayarlar > AI Altyazı bölümünden ekleyin.';

  @override
  String aiTrialStarted(int days) {
    return '$days günlük ücretsiz AI altyazı denemen başladı';
  }

  @override
  String get paywallAiTrialEnded => 'AI altyazı denemesi bitti. Kullanmaya devam etmek için Pro\'ya geç.';

  @override
  String get playerAiPreparing => 'AI altyazı hazırlanıyor';

  @override
  String playerSecondsShort(int seconds) {
    return '$seconds sn';
  }

  @override
  String playerBannerWhisper(String lang) {
    return 'AI altyazı (ses tanıma): $lang';
  }

  @override
  String get playerOrientationLock => 'Ekran yönünü kilitle';

  @override
  String playerResumeQuestion(String position) {
    return '$position konumundan devam edilsin mi?';
  }

  @override
  String get playerResumeContinue => 'Devam Et';

  @override
  String get playerResumeFromBeginning => 'Baştan Başla';

  @override
  String get playerErrorStreamUnavailable => 'Kanal şu anda açılamadı. Yayın kaynağı yanıt vermiyor ya da bağlantı koptu.';

  @override
  String get playerErrorBackToList => 'Kanal listesine dön';

  @override
  String get playerReportError => 'Hatayı Bildir';

  @override
  String get errorReportTitle => 'Hatayı Bildir';

  @override
  String get errorReportThanks => 'Teşekkürler!';

  @override
  String get errorReportReceived => 'Hata raporunuz iletildi.';

  @override
  String errorReportChannel(String name) {
    return 'Kanal: $name';
  }

  @override
  String errorReportError(String error) {
    return 'Hata: $error';
  }

  @override
  String errorReportDevice(String device) {
    return 'Cihaz: $device';
  }

  @override
  String errorReportVersion(String version) {
    return 'Versiyon: $version';
  }

  @override
  String get errorReportNoteLabel => 'Ek not (isteğe bağlı):';

  @override
  String get errorReportNotePlaceholder => 'Ne yapıyordunuz?';

  @override
  String get errorReportSend => 'Gönder';

  @override
  String playerPanelChannels(int count) {
    return 'Kanallar ($count)';
  }

  @override
  String get playerSeekForward => '▶▶ +10sn';

  @override
  String get playerSeekBackward => '◀◀ -10sn';

  @override
  String get playerWatchlistAdded => 'Listeye eklendi';

  @override
  String get playerWatchlistRemoved => 'Listeden çıkarıldı';

  @override
  String get playerWatchlistTooltip => 'Daha Sonra İzle';

  @override
  String get settingsAiSection => 'AI Altyazı';

  @override
  String get settingsAiTargetLangTitle => 'AI Altyazı Hedef Dili';

  @override
  String get settingsAiTargetLangSubtitle => 'Çeviri sonucu hangi dilde gözüksün';

  @override
  String get settingsAiTargetLangAuto => 'Otomatik (cihaz dili)';

  @override
  String get settingsAiTargetLangDialogTitle => 'Hedef Dil Seç';

  @override
  String get settingsAiBannerTitle => 'AI Altyazı Banner';

  @override
  String get settingsAiBannerSubtitle => 'Üstte kaynak/hedef dil bilgisi gözüksün';

  @override
  String get settingsAiWhisperTitle => 'AI Whisper Altyazı';

  @override
  String get settingsAiWhisperSubtitle => 'Oynatıcıda otomatik altyazı üretimi için';

  @override
  String get settingsAiProviderGroq => 'Groq';

  @override
  String get settingsAiProviderGroqBadge => 'Pro';

  @override
  String get settingsAiProviderOpenai => 'OpenAI';

  @override
  String get settingsAiProviderOpenaiBadge => 'Ücretli';

  @override
  String settingsAiGroqInfo(int days) {
    return 'Yerleşik Groq servisi — Pro özelliği, ilk $days gün ücretsiz deneme';
  }

  @override
  String get settingsAiOpenaiCost => 'Tahmini maliyet: ~\$0.006/istek · ~\$0.006/dk · openai.com/account/billing';

  @override
  String get settingsAiOpenaiKeyLabel => 'OpenAI API Key';

  @override
  String get settingsAiOpenaiKeyPlaceholder => 'sk-...';

  @override
  String get settingsAiOpenaiKeySaved => '✓ OpenAI anahtarı kayıtlı';

  @override
  String get settingsSubtitleDefaultOn => 'Altyazı varsayılan açık';

  @override
  String get settingsSubtitleDefaultOnSubtitle => 'Oynatıcı açılınca altyazı aktif olsun';

  @override
  String get settingsBufferDuration => 'Önbellek süresi';

  @override
  String settingsBufferSeconds(int seconds) {
    return '$seconds saniye';
  }

  @override
  String aiTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'AI altyazı denemesi: $days gün kaldı',
      one: 'AI altyazı denemesi: $days gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get playerPaused => 'Duraklatıldı';

  @override
  String get playerPlaying => 'Oynatılıyor';

  @override
  String get playerMuted => 'Sessiz';

  @override
  String get playerUnmuted => 'Ses açık';

  @override
  String playerFeedbackAudio(String label) {
    return 'Ses: $label';
  }

  @override
  String playerFeedbackSpeed(String speed) {
    return 'Hız $speed';
  }

  @override
  String get playerFeedbackSubtitleOff => 'Altyazı kapalı';

  @override
  String playerFeedbackSubtitle(String lang) {
    return 'Altyazı: $lang';
  }

  @override
  String get playerFeedbackSubtitleLoading => 'Altyazı yükleniyor…';

  @override
  String playerFeedbackResolution(String value) {
    return 'Çözünürlük: $value';
  }

  @override
  String playerFeedbackFit(String mode) {
    return 'Görüntü: $mode';
  }

  @override
  String get playerFavoriteAdd => 'Favorilere Ekle';

  @override
  String get playerFavoriteRemove => 'Favoriden Çıkar';

  @override
  String get playerNextChannel => 'Sonraki kanal';

  @override
  String get playerPrevChannel => 'Önceki kanal';

  @override
  String get playerOrientationUnlocked => 'Ekran yönü serbest';

  @override
  String playerNextEpisode(String title) {
    return 'Sıradaki bölüm: $title';
  }

  @override
  String get playerOpenExternal => 'Harici oynatıcıda aç (VLC)';

  @override
  String get playerExternalNotFound => 'Harici oynatıcı bulunamadı. App Store\'dan VLC kurun.';

  @override
  String get playerChannelPanelTooltip => 'Kanal listesi';

  @override
  String get disclaimerWelcome => 'Welcome';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources.\n\nThis app does not provide, host, or distribute any content. You must supply your own legally obtained playlist URL.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player, kendi M3U veya Xtream Codes oynatma listeleriniz için bir medya oynatıcıdır. İçerik sunmaz, barındırmaz.';

  @override
  String get disclaimerLegalNoticeButton => 'Legal Notice / Yasal Bildirim';

  @override
  String get disclaimerContinue => 'Continue';

  @override
  String get disclaimerFooter => 'By continuing you agree to the Legal Notice.';

  @override
  String get legalNoticeTitle => 'Legal Notice / Yasal Bildirim';

  @override
  String get legalSection1Title => '1. Nature of the App / Uygulamanın Niteliği';

  @override
  String get legalSection1En => 'IPTV AI Player is a general-purpose media player (similar to VLC or MX Player). It does NOT provide, host, distribute, or redirect to any TV broadcasts, movies, series, sports events, or other content. The app is a tool that plays M3U / M3U8 playlist URLs or Xtream Codes credentials supplied by the user.';

  @override
  String get legalSection1Tr => 'IPTV AI Player, genel amaçlı bir medya oynatıcıdır (VLC, MX Player benzeri). Herhangi bir televizyon yayını, film, dizi veya içerik SAĞLAMAZ, BARINDIRMAZ, DAĞITMAZ. Uygulama, kullanıcının kendi temin ettiği oynatma listesi URL\'lerini veya Xtream Codes kimlik bilgilerini oynatır.';

  @override
  String get legalSection2Title => '2. Content Responsibility / İçerik Sorumluluğu';

  @override
  String get legalSection2En => 'The user is solely responsible for all content accessed via the app. The developer has no knowledge of and bears no responsibility for content accessed through the app.';

  @override
  String get legalSection2Tr => 'Uygulama üzerinden erişilen TÜM içeriklerden yalnızca KULLANICI sorumludur. Geliştirici, kullanıcıların uygulamayı kullanarak eriştikleri içerikler hakkında hiçbir bilgiye sahip değildir.';

  @override
  String get legalSection3Title => '3. Türkiye Yasal Çerçevesi';

  @override
  String get legalSection3Item1 => '5846 sayılı FSEK madde 71-72: Telif hakkı ihlali hukuki ve cezai yaptırım.';

  @override
  String get legalSection3Item2 => 'TCK madde 163/2: Şifreli/şifresiz yayınların izinsiz kullanımı.';

  @override
  String get legalSection3Item3 => 'FSEK Ek Madde 4: İnternet ortamında telif ihlali.';

  @override
  String get legalSection3Item4 => 'RTÜK ve BTK, 6112 ve 5651 sayılı Kanunlar kapsamında erişim engellemesi uygulayabilir.';

  @override
  String get legalSection4Title => '4. User Obligations / Kullanıcı Yükümlülükleri';

  @override
  String get legalSection4Body => 'By using this app you acknowledge that you will only access content you are legally subscribed to, you will not access copyrighted content without permission, and you will not use the app for pirated broadcasts or unlicensed IPTV services.';

  @override
  String get legalSection5Title => '5. Data Protection / KVKK';

  @override
  String get legalSection5Body => 'The app stores your playlist URLs and credentials only locally on your device. They are not shared with third parties. / Uygulama, girdiğiniz oynatma listesi URL ve kimlik bilgilerini yalnızca cihazınızda yerel olarak saklar.';

  @override
  String get legalSection6Title => '6. Limitation of Liability / Sorumluluk Sınırlaması';

  @override
  String get legalSection6Body => 'The app is provided \"AS IS\". The developer is not liable for any damages arising from the use of the app. / Uygulama \"OLDUĞU GİBİ\" sunulmaktadır. Geliştirici, uygulamanın kullanımından kaynaklanan hiçbir zarardan sorumlu değildir.';

  @override
  String get legalSection7Title => '7. Legal Cooperation / Yasal İşbirliği';

  @override
  String get legalSection7Body => 'The developer complies with lawful requests from competent authorities (RTÜK, BTK, prosecutors). / Geliştirici, yetkili makamların (RTÜK, BTK, Savcılıklar) yasal taleplerine uyum sağlar.';

  @override
  String get legalReminder => 'Reminder: Using this app to access unauthorized / copyrighted content is illegal. The user bears full legal responsibility.';

  @override
  String get searchHint => 'Kanal, film, dizi ara...';

  @override
  String get searchMinChars => 'En az 2 karakter girin';

  @override
  String searchNoResults(String query) {
    return '\"$query\" için sonuç bulunamadı';
  }

  @override
  String get categoryFilterTitle => 'Kategori Filtresi';

  @override
  String get categoryFilterShowAll => 'Tümünü Göster';

  @override
  String get categoryFilterHideAll => 'Tümünü Gizle';

  @override
  String get categoryFilterEmpty => 'Henüz kategori yok';

  @override
  String get categoryFilterSectionLive => 'Canlı';

  @override
  String get categoryFilterSectionMovie => 'Film';

  @override
  String get categoryFilterSectionSeries => 'Dizi';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total aktif)';
  }

  @override
  String get seriesEmptyCategory => 'Bu kategoride dizi yok';

  @override
  String seriesSeasonCount(int count) {
    return '$count sezon';
  }

  @override
  String get seriesSpecialSeason => 'Özel';

  @override
  String seriesSeasonNumber(int n) {
    return 'Sezon $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count bölüm';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'İzleme geçmişinden çıkar';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name izleme geçmişinden silinecek. Onaylıyor musun?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Kaldır';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name izleme geçmişinden kaldırıldı';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name favorilere eklendi';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name favorilerden çıkarıldı';
  }

  @override
  String get homeRowPopular => 'Popüler';

  @override
  String get homeRowWatchedMovies => 'İzlediğin Filmler';

  @override
  String get homeRowWatchedSeries => 'İzlediğin Diziler';

  @override
  String get badgeMovieUppercase => 'FİLM';

  @override
  String get badgeSeriesUppercase => 'DİZİ';

  @override
  String get settingsEpgPresetsTitle => 'Hazır Kaynaklar';

  @override
  String get menuMyPlaylists => 'Oynatma Listelerim';

  @override
  String get menuEpgSettings => 'EPG Ayarları';

  @override
  String get menuNewlyAdded => 'Yeni Eklenenler';

  @override
  String get menuContinueWatching => 'Nerede Kaldım';

  @override
  String get authSignInTitle => 'Giriş yap';

  @override
  String get authSignUpTitle => 'Hesap aç';

  @override
  String get authAccountTitle => 'Hesabım';

  @override
  String get authEmailLabel => 'E-posta';

  @override
  String get authPasswordLabel => 'Şifre';

  @override
  String get authConfirmPasswordLabel => 'Şifreyi tekrarla';

  @override
  String get authSignInButton => 'Giriş yap';

  @override
  String get authSignUpButton => 'Hesap aç';

  @override
  String get authSignOutButton => 'Çıkış yap';

  @override
  String get authForgotPassword => 'Şifremi unuttum';

  @override
  String get authResetPasswordTitle => 'Şifre sıfırla';

  @override
  String get authResetPasswordHint => 'E-posta adresine sıfırlama bağlantısı gönderelim.';

  @override
  String get authResetPasswordSent => 'Sıfırlama bağlantısı gönderildi. Gelen kutunu kontrol et.';

  @override
  String get authNoAccountQuestion => 'Hesabın yok mu? Kayıt ol';

  @override
  String get authHaveAccountQuestion => 'Zaten hesabım var';

  @override
  String get authOrDivider => 'veya';

  @override
  String get authSignInWithGoogle => 'Google ile devam et';

  @override
  String get authSignInWithApple => 'Apple ile devam et';

  @override
  String get authAcceptTerms => 'Kullanım Koşulları ve Gizlilik Politikası\'nı kabul ediyorum';

  @override
  String get authViewTerms => 'Koşulları görüntüle';

  @override
  String get authErrorInvalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get authErrorWeakPassword => 'Şifre en az 6 karakter olmalı';

  @override
  String get authErrorPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get authErrorEmailInUse => 'Bu e-posta zaten kullanımda';

  @override
  String get authErrorWrongPassword => 'E-posta veya şifre hatalı';

  @override
  String get authErrorTooManyRequests => 'Çok fazla deneme. Bir süre sonra tekrar dene.';

  @override
  String get authErrorNetwork => 'Ağ hatası. İnternet bağlantını kontrol et.';

  @override
  String authErrorGeneric(String message) {
    return 'Bir şeyler ters gitti: $message';
  }

  @override
  String get authVerifyEmailHint => 'E-posta adresine doğrulama bağlantısı gönderdik.';

  @override
  String get authAppleHiddenEmail => 'Apple Kullanıcısı';

  @override
  String get authAppleHiddenEmailHint => 'E-posta Apple üzerinden gizli — paylaşılmadı';

  @override
  String get authResendVerification => 'Doğrulama tekrar gönder';

  @override
  String get authChangePassword => 'Şifreyi değiştir';

  @override
  String get authDeleteAccount => 'Hesabı sil';

  @override
  String get authDeleteAccountWarning => 'Hesabını silersen tüm cloud verisin kalıcı olarak kaldırılır. Bu işlem geri alınamaz.';

  @override
  String get authDeleteAccountConfirm => 'Evet, hesabımı sil';

  @override
  String get authAccountSection => 'Hesap';

  @override
  String get authNotSignedIn => 'Giriş yapılmadı';

  @override
  String get authSignInPromptTitle => 'Hesap aç → Pro\'yu dene';

  @override
  String get authSignInPromptDesc => 'Sınırsız playlist, AI altyazı ve cihazlar arası senkron için bir hesap oluştur.';

  @override
  String get authProActive => 'Pro üye';

  @override
  String get authFreeTier => 'Ücretsiz plan';

  @override
  String get authUpgradeToPro => 'Pro\'ya Geç';

  @override
  String get authRequiresRecentLogin => 'Bu işlem için son zamanlarda giriş yapmış olman gerekiyor. Lütfen tekrar giriş yap.';

  @override
  String get paywallTitle => 'Pro\'ya Geç, Sınırları Kaldır';

  @override
  String get paywallSubtitle => 'AI altyazı, sınırsız playlist, cihazlar arası senkron — hepsi tek seferlik ödeme ile.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Sınırsız Playlist';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker fark etmez';

  @override
  String get paywallBenefitAiSubtitles => 'AI Altyazı';

  @override
  String get paywallBenefitAiSubtitlesDesc => '100+ dilde otomatik altyazı (40 saat/ay)';

  @override
  String get paywallBenefitCloudSync => 'Cloud Senkron';

  @override
  String get paywallBenefitCloudSyncDesc => 'Favoriler ve geçmiş cihazlar arası';

  @override
  String get paywallBenefitTvApps => 'TV + Telefon';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Aylık';

  @override
  String get paywallPlanYearly => 'Yıllık';

  @override
  String get paywallPlanLifetime => 'Yaşam Boyu';

  @override
  String get paywallBadgeBest => 'EN İYİ';

  @override
  String get paywallBadgePopular => 'POPÜLER';

  @override
  String get paywallSubscribeButton => 'Pro\'ya Geç';

  @override
  String get paywallRestoreButton => 'Satın Alımları Geri Yükle';

  @override
  String get paywallSignInRequired => 'Devam etmek için önce hesap aç.';

  @override
  String get paywallSignInButton => 'Önce hesap aç';

  @override
  String get paywallTermsFooter => 'Abonelikler otomatik yenilenir. Ayarlar\'dan yönetebilirsin.';

  @override
  String get paywallPrivacyLink => 'Gizlilik Politikası';

  @override
  String get paywallTermsLink => 'Kullanım Koşulları';

  @override
  String get paywallPurchaseSuccess => 'Pro aktif. İyi seyirler!';

  @override
  String get paywallPurchaseCancelled => 'Satın alma iptal edildi.';

  @override
  String paywallPurchaseError(String message) {
    return 'Satın alma başarısız: $message';
  }

  @override
  String get paywallNotConfigured => 'Satın alma şu anda yapılandırılmadı. Daha sonra tekrar dene.';

  @override
  String get paywallNoOfferings => 'Şu an aktif paket yok.';

  @override
  String get paywallTriggerSecondPlaylist => 'İkinci playlist için Pro gerekiyor';

  @override
  String get paywallTriggerAiSubtitle => 'AI altyazı için Pro gerekiyor';

  @override
  String get paywallTriggerCloudSync => 'Cloud senkron için Pro gerekiyor';

  @override
  String get welcomeTitle => 'Hoş geldin';

  @override
  String get welcomeSubtitle => 'İPTV Ai Player ile sınırsız film, dizi ve canlı yayın seni bekliyor.';

  @override
  String get welcomeFeatureUnlimited => 'Sınırsız kanal & favoriler';

  @override
  String get welcomeFeatureSubtitles => 'Akıllı altyazı (100+ dil)';

  @override
  String get welcomeFeatureSync => 'Cihazlar arası senkron';

  @override
  String get welcomeStartFreeButton => 'Hesap aç → Pro\'yu dene';

  @override
  String get welcomeSkipButton => 'Şimdi atla';

  @override
  String get welcomeSignInLink => 'Zaten hesabım var';

  @override
  String get watchlistTitle => 'İzleme Listem';

  @override
  String get watchlistEmpty => 'Listen boş';

  @override
  String get watchlistEmptyHint => 'Bir film veya diziyi yer imine eklediğinde burada görünür.';

  @override
  String get themePickerTitle => 'Tema';

  @override
  String get themeDefaultDark => 'Varsayılan Koyu';

  @override
  String get themeDefaultLight => 'Varsayılan Açık';

  @override
  String get themeCrimson => 'Kızıl Şafak';

  @override
  String get themeRoyal => 'Kraliyet Moru';

  @override
  String get themeForest => 'Koyu Orman';

  @override
  String get themeOcean => 'Okyanus Mavisi';

  @override
  String get parentalLockTitle => 'Ebeveyn Kilidi';

  @override
  String get parentalLockEnable => 'Ebeveyn Kilidini Aç';

  @override
  String get parentalLockEnabledHint => 'Kilitli kategoriler için PIN istenir.';

  @override
  String get parentalLockSetupFirst => 'Önce 4 haneli bir PIN oluştur.';

  @override
  String get parentalSetupPin => 'PIN Oluştur';

  @override
  String get parentalChangePin => 'PIN Değiştir';

  @override
  String get parentalRemovePin => 'Ebeveyn Kilidini Kaldır';

  @override
  String get parentalLockedCategoriesTitle => 'Kilitlenecek Kategoriler';

  @override
  String get parentalNoCategories => 'Hiç kategori yok. Önce bir oynatma listesi yükle.';

  @override
  String get parentalEnterPin => 'PIN\'i Gir';

  @override
  String get parentalNewPin => 'Yeni PIN';

  @override
  String get parentalCurrentPin => 'Mevcut PIN';

  @override
  String get parentalConfirmPin => 'PIN Tekrar';

  @override
  String get parentalPinIncorrect => 'PIN hatalı';

  @override
  String get parentalPinFourDigits => 'PIN 4 haneli rakam olmalı';

  @override
  String get parentalPinMismatch => 'PIN\'ler eşleşmiyor';

  @override
  String get parentalPinChanged => 'PIN güncellendi';

  @override
  String get parentalSubmit => 'Tamam';

  @override
  String get parentalNext => 'İleri';

  @override
  String get cloudSyncTitle => 'Bulut Senkronu';

  @override
  String get cloudSyncProRequired => 'Pro abonelik gerekli';

  @override
  String get cloudSyncSignInRequired => 'Giriş yap, sonra senkronla';

  @override
  String get cloudSyncNever => 'Henüz senkron yok';

  @override
  String get cloudSyncSyncNow => 'Şimdi Senkronla';

  @override
  String get cloudSyncJustNow => 'az önce';

  @override
  String cloudSyncMinutesAgo(int n) {
    return '$n dk önce';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return '$n sa önce';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return '$n gün önce';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Son senkron: $when';
  }

  @override
  String get epgGuideTitle => 'TV Rehberi';

  @override
  String get epgToday => 'Bugün';

  @override
  String get epgYesterday => 'Dün';

  @override
  String get epgTomorrow => 'Yarın';

  @override
  String get epgRowEmpty => 'Bu kanal için program yok';

  @override
  String get epgNoData => 'EPG verisi yok';

  @override
  String get epgNoDataHint => 'Ayarlar → EPG bölümünden bir URL girip \'Şimdi Yenile\'ye dokunun.';

  @override
  String epgError(String msg) {
    return 'EPG hatası: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Otomatik Yenile';

  @override
  String get epgAutoRefreshOff => 'Kapalı';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'Her $h saatte bir';
  }

  @override
  String get playerPipTooltip => 'Pencereye Küçült (Pro)';

  @override
  String get playerPipUnavailable => 'Bu cihazda PiP desteklenmiyor';

  @override
  String get playerPipEntered => 'Küçük pencerede oynatılıyor';

  @override
  String get playerAirplayTooltip => 'AirPlay (ses)';

  @override
  String get playerAirplayUnavailable => 'AirPlay bu cihazda kullanılamıyor';

  @override
  String get playerAirplayAudioOnlyHint => 'AirPlay sesi TV\'ye gönderir. Görüntü için Kontrol Merkezi > Ekran Yansıtma\'yı kullanın.';

  @override
  String get playerCastTooltip => 'Cast (yakında)';

  @override
  String get settingsPipSection => 'Picture-in-Picture';

  @override
  String get settingsPipAuto => 'Home tuşuna basınca otomatik PiP';

  @override
  String get settingsPipAutoSubtitle => 'Pro — Player açıkken Home tuşuna basınca yayın küçük pencereye geçer';

  @override
  String get settingsAdsSection => 'Reklam';

  @override
  String get settingsAdsRemoved => 'Pro: reklam yok';

  @override
  String get settingsAdsFreeNotice => 'Free sürümde alt kısımda banner reklam görüntülenir. Pro abonelikle kalıcı reklamsız.';

  @override
  String get settingsProSection => 'Pro Özellikler';

  @override
  String get settingsContentSection => 'İçerik';

  @override
  String get settingsPlayerSection => 'Oynatıcı';

  @override
  String get settingsLegalNotice => 'Yasal Bildirim';

  @override
  String get settingsDataDeletion => 'Veri Silme Talebi';

  @override
  String get settingsDataDeletionSubtitle => 'Hesap ve veri silme talebi';

  @override
  String get settingsTapToSignIn => 'Giriş yap veya hesap oluştur';

  @override
  String get commonHide => 'Gizle';

  @override
  String get commonShow => 'Göster';

  @override
  String get profileSwitcherTitle => 'Profiller';

  @override
  String get profileDefaultName => 'Varsayılan';

  @override
  String get profileAdd => 'Yeni Profil';

  @override
  String get profileEdit => 'Profili Düzenle';

  @override
  String get profileDelete => 'Profili Sil';

  @override
  String get profileDeleteConfirm => 'Bu profil ve özel favori/izleme listesi silinecek. Devam edilsin mi?';

  @override
  String get profileNameLabel => 'Profil Adı';

  @override
  String get profileEmptyName => 'Profil adı boş olamaz';

  @override
  String get profileSwitched => 'Profil değiştirildi';

  @override
  String get profileMaxFreeReached => 'Free sürümde 1 profil. Pro ile sınırsız profil.';

  @override
  String get profileSection => 'Profil';

  @override
  String get otherAppsTitle => 'Diğer Uygulamalarımız';

  @override
  String get otherAppsSubtitle => 'Ekibimizin geliştirdiği diğer uygulamalar';

  @override
  String get otherAppsEmpty => 'Liste şu an yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get otherAppsRetry => 'Tekrar Dene';

  @override
  String get otherAppsOpenFailed => 'Mağaza açılamadı.';

  @override
  String get otherAppsGateTitle => 'Ebeveyn kontrolü';

  @override
  String get otherAppsGateQuestion => 'Devam etmek için işlemin sonucunu yazın:';

  @override
  String get otherAppsCancel => 'Vazgeç';

  @override
  String get otherAppsContinue => 'Devam';

  @override
  String get editPlaylistTitle => 'Playlist Düzenle';

  @override
  String get editPlaylistNotFound => 'Playlist bulunamadı';

  @override
  String get editPlaylistXtreamBadge => 'Xtream Codes';

  @override
  String get editPlaylistM3uBadge => 'M3U Playlist';

  @override
  String get editPlaylistAddedAt => 'Eklenme tarihi';

  @override
  String get editPlaylistExpiry => 'Son kullanma tarihi';

  @override
  String get editPlaylistExpiredLabel => '⚠ Geçmiş';

  @override
  String get editPlaylistValidLabel => '✓ Geçerli';

  @override
  String get editPlaylistUrlLabel => 'Sunucu URL';

  @override
  String get editPlaylistRefreshButton => 'Kanalları Yenile';

  @override
  String get editPlaylistDeleteButton => 'Playlistı Sil';

  @override
  String get deletePlaylistDialogTitle => 'Playlist Sil';

  @override
  String get deletePlaylistDialogQuestion => 'Nasıl silmek istiyorsunuz?';

  @override
  String get deleteDeviceExplain => 'Yalnızca bu cihazdan kaldırılır. Bulut kaydı durur; istediğinizde \"Buluttan İndir\" ile geri alabilirsiniz.';

  @override
  String get deleteDeviceExplainLocal => 'Bu cihazdan kaldırılır. Bu liste bulutta kayıtlı değil; geri almak için yeniden eklemeniz gerekir.';

  @override
  String get deletePlaylistFromCloud => 'Buluttan Sil';

  @override
  String get deletePlaylistFromDevice => 'Cihazdan Sil';

  @override
  String get deleteCloudExplain => 'Hem bu cihazdan hem buluttan kalıcı olarak silinir; diğer cihazlarınıza da bir daha gelmez.';

  @override
  String get progressDownloadingList => 'Kanal listesi indiriliyor…';

  @override
  String progressRetrying(int attempt) {
    return 'Yeniden deneniyor ($attempt/3)…';
  }

  @override
  String get progressParsingList => 'Kanal listesi işleniyor…';

  @override
  String progressChannelsSaved(int count) {
    return '$count kanal kaydedildi…';
  }

  @override
  String get progressServerConnecting => 'Sunucuya bağlanılıyor…';

  @override
  String get progressLoadingLive => 'Canlı kanallar yükleniyor…';

  @override
  String get progressLoadingMovies => 'Filmler yükleniyor…';

  @override
  String get progressLoadingSeries => 'Diziler yükleniyor…';

  @override
  String get loadErrM3uNotFound => 'Bu adreste kanal listesi bulunamadı. Adresin bir M3U listesine ait olduğundan emin olun.';

  @override
  String loadErrIncomplete(int count, int total) {
    return 'Liste eksik geldi ($count / $total kanal) — bağlantı yarıda kesilmiş olabilir. Mevcut listeniz korundu, tekrar deneyin.';
  }

  @override
  String get loadErrServerEmpty => 'Sunucu boş bir liste gönderdi. Aboneliğinizde kanal tanımlı olduğundan emin olun; sorun sürerse sağlayıcınıza danışın.';

  @override
  String get loadErrSeriesInfo => 'Bu dizinin bilgisi alınamadı. Listeyi yenileyip tekrar deneyin.';

  @override
  String get loadErrNoEpisodes => 'Sağlayıcı bu dizi için bölüm göndermedi.';

  @override
  String loadErrDrasticShrink(int count, int total) {
    return 'Sunucu yalnızca $count kanal gönderdi (önceden $total). Aboneliğinizin süresi dolmuş olabilir; mevcut listeniz korundu.';
  }

  @override
  String syncShrinkKept(String type) {
    return '$type: sunucu öncekinden çok daha az içerik gönderdi, mevcut içerik korundu.';
  }

  @override
  String get playlistSyncQueued => 'Değişiklikler kaydedildi. Liste, süren güncelleme bitince yeniden indirilecek.';

  @override
  String get errorReportPreviewLabel => 'Gönderilecek metin (giriş bilgileri gizlendi):';

  @override
  String paywallPricePerMonths(String price, int months) {
    return '$price / $months ay';
  }

  @override
  String paywallPlanMonths(int months) {
    return '$months Aylık';
  }

  @override
  String paywallIntroPriceThen(String intro, String price) {
    return '$intro tanıtım fiyatı, sonra $price';
  }

  @override
  String get watchlistClearAll => 'Listeyi temizle';

  @override
  String get watchlistClearConfirm => 'Tüm öğeler silinsin mi?';

  @override
  String get categoryFilterPlaylist => 'Playlist';

  @override
  String get settingsRefreshOff => 'Kapalı';

  @override
  String get settingsRefreshOnOpen => 'Her Açılışta';

  @override
  String get settingsRefresh1Day => 'Her 1 Gün';

  @override
  String get settingsRefresh1Week => 'Her 1 Hafta';

  @override
  String get settingsRefresh1Month => 'Her 1 Ay';

  @override
  String get settingsRefresh1Year => 'Her 1 Yıl';

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
    return 'Sonra: $title';
  }

  @override
  String get xtreamBadLogin => 'Kullanıcı adı veya şifre hatalı. Bilgileri sağlayıcınızdan kontrol edip tekrar deneyin.';

  @override
  String get xtreamExpired => 'Aboneliğinizin süresi dolmuş. Yenilemek için sağlayıcınızla iletişime geçin.';

  @override
  String xtreamExpiredOn(String date) {
    return 'Aboneliğinizin süresi $date tarihinde dolmuş. Yenilemek için sağlayıcınızla iletişime geçin.';
  }

  @override
  String get xtreamDisabled => 'Hesabınız sağlayıcı tarafından kapatılmış. Sağlayıcınızla iletişime geçin.';

  @override
  String get epgAutoRefreshAuto => 'Otomatik — rehber bitmek üzereyken yenilenir';

  @override
  String xtreamPartialLoad(String type) {
    return 'Bazı içerikler yüklenemedi: $type';
  }

  @override
  String get settingsPlaylistAutoRefreshTitle => 'Playlist otomatik yenileme';

  @override
  String settingsEpgUrlForPlaylist(String name) {
    return 'Aktif playlist için: $name';
  }

  @override
  String get settingsClearHistoryDone => 'İzleme geçmişi temizlendi';

  @override
  String get settingsSupportSection => 'Destek';

  @override
  String get settingsFeedbackTitle => 'Geri Bildirim Gönder';

  @override
  String get settingsFeedbackSubtitle => 'Öneri, hata bildirimi veya genel görüş';

  @override
  String get feedbackDialogTitle => 'Geri Bildirim';

  @override
  String get feedbackThanks => 'Teşekkürler!';

  @override
  String get feedbackReceived => 'Geri bildiriminiz iletildi.';

  @override
  String get feedbackChooseType => 'Türü seçin:';

  @override
  String get feedbackTypeSuggestion => 'Öneri';

  @override
  String get feedbackTypeBug => 'Hata Bildirimi';

  @override
  String get feedbackTypeGeneral => 'Genel';

  @override
  String get feedbackNameLabel => 'Ad Soyad';

  @override
  String get feedbackNamePlaceholder => 'İsteğe bağlı';

  @override
  String get feedbackEmailLabel => 'E-posta *';

  @override
  String get feedbackEmailPlaceholder => 'ornek@mail.com';

  @override
  String get feedbackEmailInvalid => 'Geçerli bir e-posta adresi girin';

  @override
  String get feedbackMessageLabel => 'Mesajınız *';

  @override
  String get feedbackMessagePlaceholder => 'Düşüncelerinizi yazın...';

  @override
  String get feedbackScreenshotLabel => 'Ekran görüntüsü (en fazla 3)';

  @override
  String get feedbackAddImage => 'Resim Ekle';

  @override
  String feedbackError(String details) {
    return 'Gönderilemedi: $details';
  }

  @override
  String get feedbackImageTooLarge => '5 MB\'tan büyük görseller eklenemez';

  @override
  String get commonSend => 'Gönder';

  @override
  String get commonSending => 'Gönderiliyor...';

  @override
  String get settingsRateApp => 'Uygulamayı değerlendir';

  @override
  String get settingsRateAppSubtitle => 'App Store\'da puan ver ve yorum yaz';

  @override
  String paywallBenefitPlaylistsUpTo(int count) {
    return '$count playlist\'e kadar';
  }

  @override
  String get paywallBenefitAiWhisper => 'AI Whisper altyazı';

  @override
  String get paywallBenefitCloudSyncDevices => 'Bulut senkronu (cihazlar arası)';

  @override
  String get paywallBenefitThemes => 'Premium temalar';

  @override
  String get paywallBenefitWatchlist => 'İzleme listem';

  @override
  String get paywallBenefitEpgAuto => 'TV rehberi otomatik yenileme';

  @override
  String paywallPricePerYear(String price) {
    return '$price / yıl';
  }

  @override
  String paywallPricePerMonth(String price) {
    return '$price / ay';
  }

  @override
  String paywallPricePerWeek(String price) {
    return '$price / hafta';
  }

  @override
  String paywallPriceOneTime(String price) {
    return '$price tek seferlik';
  }

  @override
  String paywallMonthlyEquivalent(String price) {
    return 'Aylık yalnızca $price';
  }

  @override
  String paywallTrialThen(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'İlk $days gün ücretsiz',
    );
    return '$_temp0, ardından $price. İstediğin zaman iptal et.';
  }

  @override
  String get paywallLifetimeHint => '✦ Tek seferlik ödeme · Ömür boyu erişim';

  @override
  String get paywallPurchase => 'Satın Al';

  @override
  String get paywallTermsFooterApple => 'Ödeme, satın alma onayında Apple Kimliğinizden tahsil edilir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir. App Store hesap ayarlarından yönetebilir veya iptal edebilirsiniz.';

  @override
  String get paywallActivationPending => 'Satın alma tamamlandı ancak Pro henüz etkinleşmedi. Satın alımları geri yüklemeyi deneyin; sorun sürerse destekle iletişime geçin.';

  @override
  String get paywallLoadError => 'Planlar yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String playlistDeviceLimit(int count) {
    return 'Bu cihaz en fazla $count playlist destekliyor.';
  }

  @override
  String get authReauthTitle => 'Kimliğini doğrula';

  @override
  String get authReauthPasswordMessage => 'Hesabını silmek için şifreni gir.';

  @override
  String get authAccountDeleted => 'Hesabın silindi.';

  @override
  String get playerUrlMissing => 'Yayın URL\'si bulunamadı';

  @override
  String parentalPinWrongAttempts(int remaining) {
    return 'Yanlış PIN. $remaining deneme hakkınız kaldı.';
  }

  @override
  String parentalPinCooldown(int seconds) {
    return 'Çok fazla yanlış giriş. $seconds saniye bekleyin.';
  }

  @override
  String get paywallRestoreNothing => 'Bu Apple Kimliği için geri yüklenecek satın alma bulunamadı.';
}
