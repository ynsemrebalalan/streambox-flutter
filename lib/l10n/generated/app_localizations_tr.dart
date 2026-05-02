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
}
