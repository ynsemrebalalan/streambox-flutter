import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// Application display name shown in title bars.
  ///
  /// In tr, this message translates to:
  /// **'İPTV Ai Player'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Dene'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu. Lütfen tekrar deneyin.'**
  String get errorGeneric;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem dili'**
  String get languageSystem;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In tr, this message translates to:
  /// **'Almanca'**
  String get languageGerman;

  /// No description provided for @languageArabic.
  ///
  /// In tr, this message translates to:
  /// **'Arapça'**
  String get languageArabic;

  /// Error display with extra details (typically exception toString)
  ///
  /// In tr, this message translates to:
  /// **'Hata: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @commonAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get commonAdd;

  /// No description provided for @commonRefresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get commonRefresh;

  /// No description provided for @commonDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDeleteConfirm;

  /// No description provided for @errorTimeoutProvider.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı cevap veremedi. Birazdan tekrar deneyin.'**
  String get errorTimeoutProvider;

  /// No description provided for @errorNoConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok veya sağlayıcıya ulaşılamıyor.'**
  String get errorNoConnection;

  /// No description provided for @errorDatabaseTemporary.
  ///
  /// In tr, this message translates to:
  /// **'Veri tabanı geçici olarak yanıt vermedi. Lütfen tekrar deneyin.'**
  String get errorDatabaseTemporary;

  /// No description provided for @errorGenericRetry.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Lütfen tekrar deneyin.'**
  String get errorGenericRetry;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar kaydedildi'**
  String get settingsSaved;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get settingsThemeSystem;

  /// No description provided for @settingsEpgSection.
  ///
  /// In tr, this message translates to:
  /// **'EPG'**
  String get settingsEpgSection;

  /// No description provided for @settingsEpgUrlLabel.
  ///
  /// In tr, this message translates to:
  /// **'EPG URL (.xml veya .xml.gz)'**
  String get settingsEpgUrlLabel;

  /// No description provided for @settingsEpgRefreshNow.
  ///
  /// In tr, this message translates to:
  /// **'EPG\'yi Şimdi Güncelle'**
  String get settingsEpgRefreshNow;

  /// No description provided for @settingsSelectPlaylistFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce bir playlist seçin'**
  String get settingsSelectPlaylistFirst;

  /// No description provided for @settingsEpgUpdated.
  ///
  /// In tr, this message translates to:
  /// **'EPG başarıyla güncellendi'**
  String get settingsEpgUpdated;

  /// No description provided for @settingsEpgError.
  ///
  /// In tr, this message translates to:
  /// **'EPG hatası: {details}'**
  String settingsEpgError(String details);

  /// No description provided for @settingsSubtitleSection.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı'**
  String get settingsSubtitleSection;

  /// No description provided for @settingsSubtitleFontSize.
  ///
  /// In tr, this message translates to:
  /// **'Yazı Boyutu'**
  String get settingsSubtitleFontSize;

  /// No description provided for @subtitleSizeSmall.
  ///
  /// In tr, this message translates to:
  /// **'Küçük'**
  String get subtitleSizeSmall;

  /// No description provided for @subtitleSizeNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get subtitleSizeNormal;

  /// No description provided for @subtitleSizeLarge.
  ///
  /// In tr, this message translates to:
  /// **'Büyük'**
  String get subtitleSizeLarge;

  /// No description provided for @subtitleSizeExtraLarge.
  ///
  /// In tr, this message translates to:
  /// **'Çok Büyük'**
  String get subtitleSizeExtraLarge;

  /// No description provided for @settingsSubtitleTextColor.
  ///
  /// In tr, this message translates to:
  /// **'Yazı Rengi'**
  String get settingsSubtitleTextColor;

  /// No description provided for @subtitleColorWhite.
  ///
  /// In tr, this message translates to:
  /// **'Beyaz'**
  String get subtitleColorWhite;

  /// No description provided for @subtitleColorYellow.
  ///
  /// In tr, this message translates to:
  /// **'Sarı'**
  String get subtitleColorYellow;

  /// No description provided for @subtitleColorGreen.
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get subtitleColorGreen;

  /// No description provided for @subtitleColorCyan.
  ///
  /// In tr, this message translates to:
  /// **'Camgöbeği'**
  String get subtitleColorCyan;

  /// No description provided for @settingsSubtitleBgColor.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan'**
  String get settingsSubtitleBgColor;

  /// No description provided for @subtitleBgSemi.
  ///
  /// In tr, this message translates to:
  /// **'Yarı Saydam'**
  String get subtitleBgSemi;

  /// No description provided for @subtitleBgOpaque.
  ///
  /// In tr, this message translates to:
  /// **'Siyah'**
  String get subtitleBgOpaque;

  /// No description provided for @subtitleBgNone.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get subtitleBgNone;

  /// No description provided for @settingsAboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAboutSection;

  /// No description provided for @settingsAppVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String settingsAppVersion(String version);

  /// No description provided for @settingsPlaylistManagement.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Yönetimi'**
  String get settingsPlaylistManagement;

  /// No description provided for @settingsCategoryFilterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategorileri gizle/göster'**
  String get settingsCategoryFilterSubtitle;

  /// No description provided for @homeAppTitle.
  ///
  /// In tr, this message translates to:
  /// **'IPTV AI Player'**
  String get homeAppTitle;

  /// No description provided for @homeNoPlaylistMessage.
  ///
  /// In tr, this message translates to:
  /// **'Başlamak için bir playlist ekleyin'**
  String get homeNoPlaylistMessage;

  /// No description provided for @homeAddPlaylist.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Ekle'**
  String get homeAddPlaylist;

  /// No description provided for @homeSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Kanal, film, dizi ara...'**
  String get homeSearchHint;

  /// No description provided for @homePlaylistsTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Playlist\'ler'**
  String get homePlaylistsTooltip;

  /// No description provided for @homeMore.
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla'**
  String get homeMore;

  /// No description provided for @homeCategoryManagement.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Yönetimi'**
  String get homeCategoryManagement;

  /// No description provided for @homeTabHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homeTabHome;

  /// No description provided for @homeTabLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı'**
  String get homeTabLive;

  /// No description provided for @homeTabMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get homeTabMovie;

  /// No description provided for @homeTabSeries.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get homeTabSeries;

  /// No description provided for @homeTabFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get homeTabFavorites;

  /// No description provided for @homeFavoritesAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get homeFavoritesAll;

  /// No description provided for @homeFavoritesLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı'**
  String get homeFavoritesLive;

  /// No description provided for @homeFavoritesMovie.
  ///
  /// In tr, this message translates to:
  /// **'Filmler'**
  String get homeFavoritesMovie;

  /// No description provided for @homeFavoritesSeries.
  ///
  /// In tr, this message translates to:
  /// **'Diziler'**
  String get homeFavoritesSeries;

  /// No description provided for @homeEmptyFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favori eklenmemiş'**
  String get homeEmptyFavorites;

  /// No description provided for @homeEmptyFavoritesType.
  ///
  /// In tr, this message translates to:
  /// **'Bu tipte favori yok'**
  String get homeEmptyFavoritesType;

  /// No description provided for @homeEmptyCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride içerik yok'**
  String get homeEmptyCategory;

  /// No description provided for @homeRowContinueWatching.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get homeRowContinueWatching;

  /// No description provided for @homeRowRecentlyWatched.
  ///
  /// In tr, this message translates to:
  /// **'Son İzlenenler'**
  String get homeRowRecentlyWatched;

  /// No description provided for @homeRowNewMovies.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Filmler'**
  String get homeRowNewMovies;

  /// No description provided for @homeRowNewSeries.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Diziler'**
  String get homeRowNewSeries;

  /// No description provided for @homeRowNewChannels.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kanallar'**
  String get homeRowNewChannels;

  /// No description provided for @homeEmptyContent.
  ///
  /// In tr, this message translates to:
  /// **'Henüz içerik yok'**
  String get homeEmptyContent;

  /// No description provided for @homeEmptyContentHint.
  ///
  /// In tr, this message translates to:
  /// **'Film / Dizi / Canlı sekmelerinden göz atmaya başlayın'**
  String get homeEmptyContentHint;

  /// No description provided for @homeRecentlyWatchedHeader.
  ///
  /// In tr, this message translates to:
  /// **'SON İZLENENLER'**
  String get homeRecentlyWatchedHeader;

  /// No description provided for @homeSearchEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Aramak için yazmaya başlayın'**
  String get homeSearchEmpty;

  /// No description provided for @homeSearchNoResults.
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" için sonuç bulunamadı'**
  String homeSearchNoResults(String query);

  /// No description provided for @homeContentCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} içerik'**
  String homeContentCount(int count);

  /// No description provided for @sortDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sortDialogTitle;

  /// No description provided for @sortLabelDefault.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan'**
  String get sortLabelDefault;

  /// No description provided for @sortLabelAZ.
  ///
  /// In tr, this message translates to:
  /// **'A → Z'**
  String get sortLabelAZ;

  /// No description provided for @sortLabelZA.
  ///
  /// In tr, this message translates to:
  /// **'Z → A'**
  String get sortLabelZA;

  /// No description provided for @sortLabelShortAZ.
  ///
  /// In tr, this message translates to:
  /// **'A→Z'**
  String get sortLabelShortAZ;

  /// No description provided for @sortLabelShortZA.
  ///
  /// In tr, this message translates to:
  /// **'Z→A'**
  String get sortLabelShortZA;

  /// No description provided for @sortLabelShort.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sortLabelShort;

  /// No description provided for @playlistsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist\'ler'**
  String get playlistsTitle;

  /// No description provided for @playlistsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz playlist yok'**
  String get playlistsEmpty;

  /// No description provided for @playlistsRefreshTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get playlistsRefreshTooltip;

  /// No description provided for @playlistsDeleteTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get playlistsDeleteTooltip;

  /// No description provided for @playlistsRetryAction.
  ///
  /// In tr, this message translates to:
  /// **'TEKRAR'**
  String get playlistsRetryAction;

  /// No description provided for @playlistsUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Playlist güncellendi.'**
  String get playlistsUpdated;

  /// No description provided for @playlistsDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Sil'**
  String get playlistsDeleteTitle;

  /// No description provided for @playlistsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" silinsin mi?'**
  String playlistsDeleteConfirm(String name);

  /// No description provided for @playlistsAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Ekle'**
  String get playlistsAddTitle;

  /// No description provided for @playlistsTypeM3u.
  ///
  /// In tr, this message translates to:
  /// **'M3U URL'**
  String get playlistsTypeM3u;

  /// No description provided for @playlistsTypeXtream.
  ///
  /// In tr, this message translates to:
  /// **'Xtream'**
  String get playlistsTypeXtream;

  /// No description provided for @playlistsNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Adı'**
  String get playlistsNameLabel;

  /// No description provided for @playlistsM3uUrlLabel.
  ///
  /// In tr, this message translates to:
  /// **'M3U URL'**
  String get playlistsM3uUrlLabel;

  /// No description provided for @playlistsM3uUrlHint.
  ///
  /// In tr, this message translates to:
  /// **'http://... veya https://...'**
  String get playlistsM3uUrlHint;

  /// No description provided for @playlistsPasteFromClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panodan Yapıştır'**
  String get playlistsPasteFromClipboard;

  /// No description provided for @playlistsClipboardEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Pano boş'**
  String get playlistsClipboardEmpty;

  /// No description provided for @playlistsServerUrlLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu URL'**
  String get playlistsServerUrlLabel;

  /// No description provided for @playlistsServerUrlHint.
  ///
  /// In tr, this message translates to:
  /// **'http://server.com:8080'**
  String get playlistsServerUrlHint;

  /// No description provided for @playlistsUsernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get playlistsUsernameLabel;

  /// No description provided for @playlistsPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get playlistsPasswordLabel;

  /// No description provided for @playlistsContentTypes.
  ///
  /// In tr, this message translates to:
  /// **'İçerik Tipleri'**
  String get playlistsContentTypes;

  /// No description provided for @playlistsContentLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı'**
  String get playlistsContentLive;

  /// No description provided for @playlistsContentMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get playlistsContentMovie;

  /// No description provided for @playlistsContentSeries.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get playlistsContentSeries;

  /// No description provided for @playlistsValidationNameUrl.
  ///
  /// In tr, this message translates to:
  /// **'Ad ve URL zorunlu'**
  String get playlistsValidationNameUrl;

  /// No description provided for @playlistsValidationXtreamCreds.
  ///
  /// In tr, this message translates to:
  /// **'Xtream için kullanıcı adı ve şifre gerekli'**
  String get playlistsValidationXtreamCreds;

  /// No description provided for @playlistsErrorTlsHandshake.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli bağlantı kurulamadı (TLS hatası). URL\'yi http:// ile deneyin veya sağlayıcı adresini kontrol edin.'**
  String get playlistsErrorTlsHandshake;

  /// No description provided for @playlistsErrorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı cevap veremedi (timeout). Birazdan tekrar deneyin.'**
  String get playlistsErrorTimeout;

  /// No description provided for @playlistsErrorConnection.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok veya sağlayıcıya ulaşılamıyor.'**
  String get playlistsErrorConnection;

  /// No description provided for @playlistsErrorUpdateGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Playlist güncellenemedi: {details}'**
  String playlistsErrorUpdateGeneric(String details);

  /// No description provided for @playlistsErrorEmptyResponse.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı boş playlist döndü. Eski veri korundu.'**
  String get playlistsErrorEmptyResponse;

  /// No description provided for @playerReconnectingMulti.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden bağlanılıyor ({attempt})...'**
  String playerReconnectingMulti(int attempt);

  /// No description provided for @playerReconnecting.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden bağlanılıyor...'**
  String get playerReconnecting;

  /// No description provided for @playerLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get playerLoading;

  /// No description provided for @playerStreamRepeatedError.
  ///
  /// In tr, this message translates to:
  /// **'Yayın kaynağında sürekli kesinti. Kanalı değiştirmeyi deneyin.'**
  String get playerStreamRepeatedError;

  /// No description provided for @playerReconnectTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden bağlan'**
  String get playerReconnectTooltip;

  /// No description provided for @playerSubtitleEnable.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı Aç'**
  String get playerSubtitleEnable;

  /// No description provided for @playerSubtitleDisable.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı Kapat'**
  String get playerSubtitleDisable;

  /// No description provided for @playerMuteTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sessize al'**
  String get playerMuteTooltip;

  /// No description provided for @playerUnmuteTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Sesi aç'**
  String get playerUnmuteTooltip;

  /// No description provided for @playerLiveLabel.
  ///
  /// In tr, this message translates to:
  /// **'CANLI'**
  String get playerLiveLabel;

  /// No description provided for @playerSeekHint.
  ///
  /// In tr, this message translates to:
  /// **'◄ 10s ►'**
  String get playerSeekHint;

  /// No description provided for @playerAudioTrackTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ses parçası'**
  String get playerAudioTrackTooltip;

  /// No description provided for @playerAudioTrackDialog.
  ///
  /// In tr, this message translates to:
  /// **'Ses parçası'**
  String get playerAudioTrackDialog;

  /// No description provided for @playerAudioTrackFallback.
  ///
  /// In tr, this message translates to:
  /// **'Parça {n}'**
  String playerAudioTrackFallback(int n);

  /// No description provided for @playerSpeedDialog.
  ///
  /// In tr, this message translates to:
  /// **'Oynatma hızı'**
  String get playerSpeedDialog;

  /// No description provided for @disclaimerWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Welcome'**
  String get disclaimerWelcome;

  /// No description provided for @disclaimerBodyEn.
  ///
  /// In tr, this message translates to:
  /// **'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources.\n\nThis app does not provide, host, or distribute any content. You must supply your own legally obtained playlist URL.'**
  String get disclaimerBodyEn;

  /// No description provided for @disclaimerBodyTr.
  ///
  /// In tr, this message translates to:
  /// **'IPTV AI Player, kendi M3U veya Xtream Codes oynatma listeleriniz için bir medya oynatıcıdır. İçerik sunmaz, barındırmaz.'**
  String get disclaimerBodyTr;

  /// No description provided for @disclaimerLegalNoticeButton.
  ///
  /// In tr, this message translates to:
  /// **'Legal Notice / Yasal Bildirim'**
  String get disclaimerLegalNoticeButton;

  /// No description provided for @disclaimerContinue.
  ///
  /// In tr, this message translates to:
  /// **'Continue'**
  String get disclaimerContinue;

  /// No description provided for @disclaimerFooter.
  ///
  /// In tr, this message translates to:
  /// **'By continuing you agree to the Legal Notice.'**
  String get disclaimerFooter;

  /// No description provided for @legalNoticeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Legal Notice / Yasal Bildirim'**
  String get legalNoticeTitle;

  /// No description provided for @legalSection1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Nature of the App / Uygulamanın Niteliği'**
  String get legalSection1Title;

  /// No description provided for @legalSection1En.
  ///
  /// In tr, this message translates to:
  /// **'IPTV AI Player is a general-purpose media player (similar to VLC or MX Player). It does NOT provide, host, distribute, or redirect to any TV broadcasts, movies, series, sports events, or other content. The app is a tool that plays M3U / M3U8 playlist URLs or Xtream Codes credentials supplied by the user.'**
  String get legalSection1En;

  /// No description provided for @legalSection1Tr.
  ///
  /// In tr, this message translates to:
  /// **'IPTV AI Player, genel amaçlı bir medya oynatıcıdır (VLC, MX Player benzeri). Herhangi bir televizyon yayını, film, dizi veya içerik SAĞLAMAZ, BARINDIRMAZ, DAĞITMAZ. Uygulama, kullanıcının kendi temin ettiği oynatma listesi URL\'lerini veya Xtream Codes kimlik bilgilerini oynatır.'**
  String get legalSection1Tr;

  /// No description provided for @legalSection2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Content Responsibility / İçerik Sorumluluğu'**
  String get legalSection2Title;

  /// No description provided for @legalSection2En.
  ///
  /// In tr, this message translates to:
  /// **'The user is solely responsible for all content accessed via the app. The developer has no knowledge of and bears no responsibility for content accessed through the app.'**
  String get legalSection2En;

  /// No description provided for @legalSection2Tr.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama üzerinden erişilen TÜM içeriklerden yalnızca KULLANICI sorumludur. Geliştirici, kullanıcıların uygulamayı kullanarak eriştikleri içerikler hakkında hiçbir bilgiye sahip değildir.'**
  String get legalSection2Tr;

  /// No description provided for @legalSection3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Türkiye Yasal Çerçevesi'**
  String get legalSection3Title;

  /// No description provided for @legalSection3Item1.
  ///
  /// In tr, this message translates to:
  /// **'5846 sayılı FSEK madde 71-72: Telif hakkı ihlali hukuki ve cezai yaptırım.'**
  String get legalSection3Item1;

  /// No description provided for @legalSection3Item2.
  ///
  /// In tr, this message translates to:
  /// **'TCK madde 163/2: Şifreli/şifresiz yayınların izinsiz kullanımı.'**
  String get legalSection3Item2;

  /// No description provided for @legalSection3Item3.
  ///
  /// In tr, this message translates to:
  /// **'FSEK Ek Madde 4: İnternet ortamında telif ihlali.'**
  String get legalSection3Item3;

  /// No description provided for @legalSection3Item4.
  ///
  /// In tr, this message translates to:
  /// **'RTÜK ve BTK, 6112 ve 5651 sayılı Kanunlar kapsamında erişim engellemesi uygulayabilir.'**
  String get legalSection3Item4;

  /// No description provided for @legalSection4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. User Obligations / Kullanıcı Yükümlülükleri'**
  String get legalSection4Title;

  /// No description provided for @legalSection4Body.
  ///
  /// In tr, this message translates to:
  /// **'By using this app you acknowledge that you will only access content you are legally subscribed to, you will not access copyrighted content without permission, and you will not use the app for pirated broadcasts or unlicensed IPTV services.'**
  String get legalSection4Body;

  /// No description provided for @legalSection5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. Data Protection / KVKK'**
  String get legalSection5Title;

  /// No description provided for @legalSection5Body.
  ///
  /// In tr, this message translates to:
  /// **'The app stores your playlist URLs and credentials only locally on your device. They are not shared with third parties. / Uygulama, girdiğiniz oynatma listesi URL ve kimlik bilgilerini yalnızca cihazınızda yerel olarak saklar.'**
  String get legalSection5Body;

  /// No description provided for @legalSection6Title.
  ///
  /// In tr, this message translates to:
  /// **'6. Limitation of Liability / Sorumluluk Sınırlaması'**
  String get legalSection6Title;

  /// No description provided for @legalSection6Body.
  ///
  /// In tr, this message translates to:
  /// **'The app is provided \"AS IS\". The developer is not liable for any damages arising from the use of the app. / Uygulama \"OLDUĞU GİBİ\" sunulmaktadır. Geliştirici, uygulamanın kullanımından kaynaklanan hiçbir zarardan sorumlu değildir.'**
  String get legalSection6Body;

  /// No description provided for @legalSection7Title.
  ///
  /// In tr, this message translates to:
  /// **'7. Legal Cooperation / Yasal İşbirliği'**
  String get legalSection7Title;

  /// No description provided for @legalSection7Body.
  ///
  /// In tr, this message translates to:
  /// **'The developer complies with lawful requests from competent authorities (RTÜK, BTK, prosecutors). / Geliştirici, yetkili makamların (RTÜK, BTK, Savcılıklar) yasal taleplerine uyum sağlar.'**
  String get legalSection7Body;

  /// No description provided for @legalReminder.
  ///
  /// In tr, this message translates to:
  /// **'Reminder: Using this app to access unauthorized / copyrighted content is illegal. The user bears full legal responsibility.'**
  String get legalReminder;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Kanal, film, dizi ara...'**
  String get searchHint;

  /// No description provided for @searchMinChars.
  ///
  /// In tr, this message translates to:
  /// **'En az 2 karakter girin'**
  String get searchMinChars;

  /// No description provided for @searchNoResults.
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" için sonuç bulunamadı'**
  String searchNoResults(String query);

  /// No description provided for @categoryFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Filtresi'**
  String get categoryFilterTitle;

  /// No description provided for @categoryFilterShowAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Göster'**
  String get categoryFilterShowAll;

  /// No description provided for @categoryFilterHideAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gizle'**
  String get categoryFilterHideAll;

  /// No description provided for @categoryFilterEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kategori yok'**
  String get categoryFilterEmpty;

  /// No description provided for @categoryFilterSectionLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı'**
  String get categoryFilterSectionLive;

  /// No description provided for @categoryFilterSectionMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get categoryFilterSectionMovie;

  /// No description provided for @categoryFilterSectionSeries.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get categoryFilterSectionSeries;

  /// No description provided for @categoryFilterCount.
  ///
  /// In tr, this message translates to:
  /// **'{label} ({active} / {total} aktif)'**
  String categoryFilterCount(String label, int active, int total);

  /// No description provided for @seriesEmptyCategory.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride dizi yok'**
  String get seriesEmptyCategory;

  /// No description provided for @seriesSeasonCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} sezon'**
  String seriesSeasonCount(int count);

  /// No description provided for @seriesSpecialSeason.
  ///
  /// In tr, this message translates to:
  /// **'Özel'**
  String get seriesSpecialSeason;

  /// No description provided for @seriesSeasonNumber.
  ///
  /// In tr, this message translates to:
  /// **'Sezon {n}'**
  String seriesSeasonNumber(int n);

  /// No description provided for @homeRowPopular.
  ///
  /// In tr, this message translates to:
  /// **'Popüler'**
  String get homeRowPopular;

  /// No description provided for @homeRowWatchedMovies.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin Filmler'**
  String get homeRowWatchedMovies;

  /// No description provided for @homeRowWatchedSeries.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin Diziler'**
  String get homeRowWatchedSeries;

  /// No description provided for @badgeMovieUppercase.
  ///
  /// In tr, this message translates to:
  /// **'FİLM'**
  String get badgeMovieUppercase;

  /// No description provided for @badgeSeriesUppercase.
  ///
  /// In tr, this message translates to:
  /// **'DİZİ'**
  String get badgeSeriesUppercase;

  /// No description provided for @settingsEpgPresetsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Kaynaklar'**
  String get settingsEpgPresetsTitle;

  /// No description provided for @menuMyPlaylists.
  ///
  /// In tr, this message translates to:
  /// **'Oynatma Listelerim'**
  String get menuMyPlaylists;

  /// No description provided for @menuEpgSettings.
  ///
  /// In tr, this message translates to:
  /// **'EPG Ayarları'**
  String get menuEpgSettings;

  /// No description provided for @menuNewlyAdded.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Eklenenler'**
  String get menuNewlyAdded;

  /// No description provided for @menuContinueWatching.
  ///
  /// In tr, this message translates to:
  /// **'Nerede Kaldım'**
  String get menuContinueWatching;

  /// No description provided for @authSignInTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap aç'**
  String get authSignUpTitle;

  /// No description provided for @authAccountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabım'**
  String get authAccountTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi tekrarla'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get authSignInButton;

  /// No description provided for @authSignUpButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesap aç'**
  String get authSignUpButton;

  /// No description provided for @authSignOutButton.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get authSignOutButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get authForgotPassword;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırla'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresine sıfırlama bağlantısı gönderelim.'**
  String get authResetPasswordHint;

  /// No description provided for @authResetPasswordSent.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama bağlantısı gönderildi. Gelen kutunu kontrol et.'**
  String get authResetPasswordSent;

  /// No description provided for @authNoAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get authNoAccountQuestion;

  /// No description provided for @authHaveAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabım var'**
  String get authHaveAccountQuestion;

  /// No description provided for @authOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get authOrDivider;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInWithApple.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile devam et'**
  String get authSignInWithApple;

  /// No description provided for @authAcceptTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları ve Gizlilik Politikası\'nı kabul ediyorum'**
  String get authAcceptTerms;

  /// No description provided for @authViewTerms.
  ///
  /// In tr, this message translates to:
  /// **'Koşulları görüntüle'**
  String get authViewTerms;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get authErrorPasswordMismatch;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kullanımda'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme. Bir süre sonra tekrar dene.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Ağ hatası. İnternet bağlantını kontrol et.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti: {message}'**
  String authErrorGeneric(String message);

  /// No description provided for @authVerifyEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresine doğrulama bağlantısı gönderdik.'**
  String get authVerifyEmailHint;

  /// No description provided for @authResendVerification.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama tekrar gönder'**
  String get authResendVerification;

  /// No description provided for @authChangePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi değiştir'**
  String get authChangePassword;

  /// No description provided for @authDeleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get authDeleteAccount;

  /// No description provided for @authDeleteAccountWarning.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silersen tüm cloud verisin kalıcı olarak kaldırılır. Bu işlem geri alınamaz.'**
  String get authDeleteAccountWarning;

  /// No description provided for @authDeleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Evet, hesabımı sil'**
  String get authDeleteAccountConfirm;

  /// No description provided for @authAccountSection.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get authAccountSection;

  /// No description provided for @authNotSignedIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılmadı'**
  String get authNotSignedIn;

  /// No description provided for @authSignInPromptTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap aç → Pro\'yu dene'**
  String get authSignInPromptTitle;

  /// No description provided for @authSignInPromptDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız playlist, AI altyazı ve cihazlar arası senkron için bir hesap oluştur.'**
  String get authSignInPromptDesc;

  /// No description provided for @authProActive.
  ///
  /// In tr, this message translates to:
  /// **'Pro üye'**
  String get authProActive;

  /// No description provided for @authFreeTier.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz plan'**
  String get authFreeTier;

  /// No description provided for @authUpgradeToPro.
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Geç'**
  String get authUpgradeToPro;

  /// No description provided for @authRequiresRecentLogin.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için son zamanlarda giriş yapmış olman gerekiyor. Lütfen tekrar giriş yap.'**
  String get authRequiresRecentLogin;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
