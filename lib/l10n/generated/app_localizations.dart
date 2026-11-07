import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ro.dart';
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
    Locale('es'),
    Locale('it'),
    Locale('ro'),
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

  /// No description provided for @languageItalian.
  ///
  /// In tr, this message translates to:
  /// **'İtalyanca'**
  String get languageItalian;

  /// No description provided for @languageSpanish.
  ///
  /// In tr, this message translates to:
  /// **'İspanyolca'**
  String get languageSpanish;

  /// No description provided for @languageRomanian.
  ///
  /// In tr, this message translates to:
  /// **'Rumence'**
  String get languageRomanian;

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

  /// No description provided for @homePlaylistSyncing.
  ///
  /// In tr, this message translates to:
  /// **'Playlist senkronize ediliyor…'**
  String get homePlaylistSyncing;

  /// No description provided for @homeSearchTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get homeSearchTooltip;

  /// No description provided for @watchlistAddTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Listeme Ekle'**
  String get watchlistAddTooltip;

  /// No description provided for @watchlistRemoveTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Listeden Çıkar'**
  String get watchlistRemoveTooltip;

  /// No description provided for @playerPlayAction.
  ///
  /// In tr, this message translates to:
  /// **'Oynat'**
  String get playerPlayAction;

  /// No description provided for @playerPauseAction.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get playerPauseAction;

  /// No description provided for @playlistsActiveLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get playlistsActiveLabel;

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

  /// No description provided for @playlistsTypeStalker.
  ///
  /// In tr, this message translates to:
  /// **'Stalker / MAG'**
  String get playlistsTypeStalker;

  /// No description provided for @playlistsStalkerCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Stalker Portal / MAG Kutu'**
  String get playlistsStalkerCardTitle;

  /// No description provided for @playlistsStalkerCardBody.
  ///
  /// In tr, this message translates to:
  /// **'MAC adresinizin IPTV sağlayıcınıza kayıtlı olması gerekir. Uygulama önce hızlı M3U yolunu dener, başarısız olursa tam Stalker protokolüne geçer.'**
  String get playlistsStalkerCardBody;

  /// No description provided for @playlistsStalkerPortalLabel.
  ///
  /// In tr, this message translates to:
  /// **'Portal URL'**
  String get playlistsStalkerPortalLabel;

  /// No description provided for @playlistsStalkerPortalHint.
  ///
  /// In tr, this message translates to:
  /// **'http://provider.com:8080'**
  String get playlistsStalkerPortalHint;

  /// No description provided for @playlistsStalkerMacLabel.
  ///
  /// In tr, this message translates to:
  /// **'MAC Adresi'**
  String get playlistsStalkerMacLabel;

  /// No description provided for @playlistsStalkerMacHint.
  ///
  /// In tr, this message translates to:
  /// **'00:1A:79:XX:XX:XX'**
  String get playlistsStalkerMacHint;

  /// No description provided for @playlistsStalkerMacGenerate.
  ///
  /// In tr, this message translates to:
  /// **'Üret'**
  String get playlistsStalkerMacGenerate;

  /// No description provided for @playlistsStalkerMacHelp.
  ///
  /// In tr, this message translates to:
  /// **'MAC biçimi: XX:XX:XX:XX:XX:XX (büyük harf, iki nokta üst üste ile ayrılmış)'**
  String get playlistsStalkerMacHelp;

  /// No description provided for @playlistsValidationStalkerMac.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir MAC adresi girin (XX:XX:XX:XX:XX:XX).'**
  String get playlistsValidationStalkerMac;

  /// No description provided for @editPlaylistStalkerBadge.
  ///
  /// In tr, this message translates to:
  /// **'Stalker / MAG'**
  String get editPlaylistStalkerBadge;

  /// No description provided for @progressTryingPortalList.
  ///
  /// In tr, this message translates to:
  /// **'Liste portaldan alınmaya çalışılıyor…'**
  String get progressTryingPortalList;

  /// No description provided for @progressPortalConnecting.
  ///
  /// In tr, this message translates to:
  /// **'Portala bağlanılıyor…'**
  String get progressPortalConnecting;

  /// No description provided for @loadErrPortalConnect.
  ///
  /// In tr, this message translates to:
  /// **'Portala bağlanılamadı. Portal adresini ve MAC adresinizin sağlayıcıya kayıtlı olduğunu kontrol edin.'**
  String get loadErrPortalConnect;

  /// No description provided for @loadErrPortalList.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesi alınamadı. MAC adresinizin portala kayıtlı olduğunu sağlayıcınızdan doğrulayın.'**
  String get loadErrPortalList;

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

  /// No description provided for @playerSubtitleDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı'**
  String get playerSubtitleDialogTitle;

  /// No description provided for @playerSubtitleAi.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı'**
  String get playerSubtitleAi;

  /// No description provided for @playerSubtitleAiActive.
  ///
  /// In tr, this message translates to:
  /// **'(Aktif)'**
  String get playerSubtitleAiActive;

  /// No description provided for @playerSubtitleEmbedded.
  ///
  /// In tr, this message translates to:
  /// **'Yerleşik {n}'**
  String playerSubtitleEmbedded(int n);

  /// No description provided for @playerSubtitleOff.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get playerSubtitleOff;

  /// No description provided for @playerScreenSizeTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Ekran Boyutu'**
  String get playerScreenSizeTooltip;

  /// No description provided for @playerScreenSizeDialog.
  ///
  /// In tr, this message translates to:
  /// **'Ekran Boyutu'**
  String get playerScreenSizeDialog;

  /// No description provided for @playerFitOriginal.
  ///
  /// In tr, this message translates to:
  /// **'Orijinal'**
  String get playerFitOriginal;

  /// No description provided for @playerFitCover.
  ///
  /// In tr, this message translates to:
  /// **'Ekranı Doldur (Kırp)'**
  String get playerFitCover;

  /// No description provided for @playerFitStretch.
  ///
  /// In tr, this message translates to:
  /// **'Esnet'**
  String get playerFitStretch;

  /// No description provided for @playerResolutionTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Çözünürlük'**
  String get playerResolutionTooltip;

  /// No description provided for @playerResolutionDialog.
  ///
  /// In tr, this message translates to:
  /// **'Çözünürlük'**
  String get playerResolutionDialog;

  /// No description provided for @playerResolutionAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik'**
  String get playerResolutionAuto;

  /// No description provided for @playerSingleQuality.
  ///
  /// In tr, this message translates to:
  /// **'Bu yayın tek kalite sunuyor.'**
  String get playerSingleQuality;

  /// No description provided for @playerErrorUnsupportedFormat.
  ///
  /// In tr, this message translates to:
  /// **'Bu yayının görüntü veya ses biçimi bu cihazda oynatılamıyor. Başka bir kaynak deneyin ya da harici oynatıcıyı kullanın.'**
  String get playerErrorUnsupportedFormat;

  /// No description provided for @playerErrorCorruptStream.
  ///
  /// In tr, this message translates to:
  /// **'Yayın verisi okunamadı. Kanal geçici olarak bozuk olabilir; biraz sonra tekrar deneyin.'**
  String get playerErrorCorruptStream;

  /// No description provided for @aiSubErrUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.'**
  String get aiSubErrUnavailable;

  /// No description provided for @aiSubErrProRequired.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı denemen bitti. Devam etmek için Pro sürümüne geç.'**
  String get aiSubErrProRequired;

  /// No description provided for @aiSubErrQuota.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı kullanım kotası doldu.'**
  String get aiSubErrQuota;

  /// No description provided for @aiSubErrBusy.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisi şu an çok yoğun. Biraz bekleyip tekrar deneyin.'**
  String get aiSubErrBusy;

  /// No description provided for @aiSubErrInvalidKey.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı API anahtarı geçersiz veya süresi dolmuş. Ayarlar > AI Altyazı bölümünden kontrol edin.'**
  String get aiSubErrInvalidKey;

  /// No description provided for @aiSubErrRejected.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisi isteği kabul etmedi. Lütfen daha sonra tekrar deneyin.'**
  String get aiSubErrRejected;

  /// No description provided for @aiSubErrEmptyResponse.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisi boş yanıt gönderdi. Lütfen tekrar deneyin.'**
  String get aiSubErrEmptyResponse;

  /// No description provided for @aiSubErrNoSpeech.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölümde konuşma algılanamadı. Videonun farklı bir anında tekrar deneyin.'**
  String get aiSubErrNoSpeech;

  /// No description provided for @aiSubErrGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı oluşturulamadı. Lütfen tekrar deneyin.'**
  String get aiSubErrGeneric;

  /// No description provided for @aiSubErrUnreachable.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisine ulaşılamıyor. İnternet bağlantınızı kontrol edin.'**
  String get aiSubErrUnreachable;

  /// No description provided for @aiSubErrConnectTimeout.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı servisine bağlanırken zaman aşımı oldu. Lütfen tekrar deneyin.'**
  String get aiSubErrConnectTimeout;

  /// No description provided for @aiSubErrExtract.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı için ses alınamadı. Bu yayının biçimi bazı cihazlarda desteklenmiyor. Daha düşük kaliteli bir kaynak deneyin ya da harici oynatıcıda izleyin.'**
  String get aiSubErrExtract;

  /// No description provided for @aiSubErrNoOpenAiKey.
  ///
  /// In tr, this message translates to:
  /// **'OpenAI API anahtarı girilmedi. Ayarlar > AI Altyazı bölümünden ekleyin.'**
  String get aiSubErrNoOpenAiKey;

  /// No description provided for @aiTrialStarted.
  ///
  /// In tr, this message translates to:
  /// **'{days} günlük ücretsiz AI altyazı denemen başladı'**
  String aiTrialStarted(int days);

  /// No description provided for @paywallAiTrialEnded.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı denemesi bitti. Kullanmaya devam etmek için Pro\'ya geç.'**
  String get paywallAiTrialEnded;

  /// No description provided for @playerAiPreparing.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı hazırlanıyor'**
  String get playerAiPreparing;

  /// No description provided for @playerSecondsShort.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} sn'**
  String playerSecondsShort(int seconds);

  /// No description provided for @playerBannerWhisper.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı (ses tanıma): {lang}'**
  String playerBannerWhisper(String lang);

  /// No description provided for @playerOrientationLock.
  ///
  /// In tr, this message translates to:
  /// **'Ekran yönünü kilitle'**
  String get playerOrientationLock;

  /// No description provided for @playerResumeQuestion.
  ///
  /// In tr, this message translates to:
  /// **'{position} konumundan devam edilsin mi?'**
  String playerResumeQuestion(String position);

  /// No description provided for @playerResumeContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get playerResumeContinue;

  /// No description provided for @playerResumeFromBeginning.
  ///
  /// In tr, this message translates to:
  /// **'Baştan Başla'**
  String get playerResumeFromBeginning;

  /// No description provided for @playerErrorStreamUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Kanal şu anda açılamadı. Yayın kaynağı yanıt vermiyor ya da bağlantı koptu.'**
  String get playerErrorStreamUnavailable;

  /// No description provided for @playerErrorBackToList.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesine dön'**
  String get playerErrorBackToList;

  /// No description provided for @playerReportError.
  ///
  /// In tr, this message translates to:
  /// **'Hatayı Bildir'**
  String get playerReportError;

  /// No description provided for @errorReportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatayı Bildir'**
  String get errorReportTitle;

  /// No description provided for @errorReportThanks.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler!'**
  String get errorReportThanks;

  /// No description provided for @errorReportReceived.
  ///
  /// In tr, this message translates to:
  /// **'Hata raporunuz iletildi.'**
  String get errorReportReceived;

  /// No description provided for @errorReportChannel.
  ///
  /// In tr, this message translates to:
  /// **'Kanal: {name}'**
  String errorReportChannel(String name);

  /// No description provided for @errorReportError.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {error}'**
  String errorReportError(String error);

  /// No description provided for @errorReportDevice.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz: {device}'**
  String errorReportDevice(String device);

  /// No description provided for @errorReportVersion.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon: {version}'**
  String errorReportVersion(String version);

  /// No description provided for @errorReportNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ek not (isteğe bağlı):'**
  String get errorReportNoteLabel;

  /// No description provided for @errorReportNotePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Ne yapıyordunuz?'**
  String get errorReportNotePlaceholder;

  /// No description provided for @errorReportSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get errorReportSend;

  /// No description provided for @playerPanelChannels.
  ///
  /// In tr, this message translates to:
  /// **'Kanallar ({count})'**
  String playerPanelChannels(int count);

  /// No description provided for @playerSeekForward.
  ///
  /// In tr, this message translates to:
  /// **'▶▶ +10sn'**
  String get playerSeekForward;

  /// No description provided for @playerSeekBackward.
  ///
  /// In tr, this message translates to:
  /// **'◀◀ -10sn'**
  String get playerSeekBackward;

  /// No description provided for @playerWatchlistAdded.
  ///
  /// In tr, this message translates to:
  /// **'Listeye eklendi'**
  String get playerWatchlistAdded;

  /// No description provided for @playerWatchlistRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Listeden çıkarıldı'**
  String get playerWatchlistRemoved;

  /// No description provided for @playerWatchlistTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Daha Sonra İzle'**
  String get playerWatchlistTooltip;

  /// No description provided for @settingsAiSection.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı'**
  String get settingsAiSection;

  /// No description provided for @settingsAiTargetLangTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı Hedef Dili'**
  String get settingsAiTargetLangTitle;

  /// No description provided for @settingsAiTargetLangSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Çeviri sonucu hangi dilde gözüksün'**
  String get settingsAiTargetLangSubtitle;

  /// No description provided for @settingsAiTargetLangAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik (cihaz dili)'**
  String get settingsAiTargetLangAuto;

  /// No description provided for @settingsAiTargetLangDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Dil Seç'**
  String get settingsAiTargetLangDialogTitle;

  /// No description provided for @settingsAiBannerTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı Banner'**
  String get settingsAiBannerTitle;

  /// No description provided for @settingsAiBannerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Üstte kaynak/hedef dil bilgisi gözüksün'**
  String get settingsAiBannerSubtitle;

  /// No description provided for @settingsAiWhisperTitle.
  ///
  /// In tr, this message translates to:
  /// **'AI Whisper Altyazı'**
  String get settingsAiWhisperTitle;

  /// No description provided for @settingsAiWhisperSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Oynatıcıda otomatik altyazı üretimi için'**
  String get settingsAiWhisperSubtitle;

  /// No description provided for @settingsAiProviderGroq.
  ///
  /// In tr, this message translates to:
  /// **'Groq'**
  String get settingsAiProviderGroq;

  /// No description provided for @settingsAiProviderGroqBadge.
  ///
  /// In tr, this message translates to:
  /// **'Pro'**
  String get settingsAiProviderGroqBadge;

  /// No description provided for @settingsAiProviderOpenai.
  ///
  /// In tr, this message translates to:
  /// **'OpenAI'**
  String get settingsAiProviderOpenai;

  /// No description provided for @settingsAiProviderOpenaiBadge.
  ///
  /// In tr, this message translates to:
  /// **'Ücretli'**
  String get settingsAiProviderOpenaiBadge;

  /// No description provided for @settingsAiGroqInfo.
  ///
  /// In tr, this message translates to:
  /// **'Yerleşik Groq servisi — Pro özelliği, ilk {days} gün ücretsiz deneme'**
  String settingsAiGroqInfo(int days);

  /// No description provided for @settingsAiOpenaiCost.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini maliyet: ~\$0.006/istek · ~\$0.006/dk · openai.com/account/billing'**
  String get settingsAiOpenaiCost;

  /// No description provided for @settingsAiOpenaiKeyLabel.
  ///
  /// In tr, this message translates to:
  /// **'OpenAI API Key'**
  String get settingsAiOpenaiKeyLabel;

  /// No description provided for @settingsAiOpenaiKeyPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'sk-...'**
  String get settingsAiOpenaiKeyPlaceholder;

  /// No description provided for @settingsAiOpenaiKeySaved.
  ///
  /// In tr, this message translates to:
  /// **'✓ OpenAI anahtarı kayıtlı'**
  String get settingsAiOpenaiKeySaved;

  /// No description provided for @settingsSubtitleDefaultOn.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı varsayılan açık'**
  String get settingsSubtitleDefaultOn;

  /// No description provided for @settingsSubtitleDefaultOnSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Oynatıcı açılınca altyazı aktif olsun'**
  String get settingsSubtitleDefaultOnSubtitle;

  /// No description provided for @settingsBufferDuration.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek süresi'**
  String get settingsBufferDuration;

  /// No description provided for @settingsBufferSeconds.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} saniye'**
  String settingsBufferSeconds(int seconds);

  /// No description provided for @aiTrialDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'{days, plural, one{AI altyazı denemesi: {days} gün kaldı} other{AI altyazı denemesi: {days} gün kaldı}}'**
  String aiTrialDaysLeft(int days);

  /// No description provided for @playerPaused.
  ///
  /// In tr, this message translates to:
  /// **'Duraklatıldı'**
  String get playerPaused;

  /// No description provided for @playerPlaying.
  ///
  /// In tr, this message translates to:
  /// **'Oynatılıyor'**
  String get playerPlaying;

  /// No description provided for @playerMuted.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz'**
  String get playerMuted;

  /// No description provided for @playerUnmuted.
  ///
  /// In tr, this message translates to:
  /// **'Ses açık'**
  String get playerUnmuted;

  /// No description provided for @playerFeedbackAudio.
  ///
  /// In tr, this message translates to:
  /// **'Ses: {label}'**
  String playerFeedbackAudio(String label);

  /// No description provided for @playerFeedbackSpeed.
  ///
  /// In tr, this message translates to:
  /// **'Hız {speed}'**
  String playerFeedbackSpeed(String speed);

  /// No description provided for @playerFeedbackSubtitleOff.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı kapalı'**
  String get playerFeedbackSubtitleOff;

  /// No description provided for @playerFeedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı: {lang}'**
  String playerFeedbackSubtitle(String lang);

  /// No description provided for @playerFeedbackSubtitleLoading.
  ///
  /// In tr, this message translates to:
  /// **'Altyazı yükleniyor…'**
  String get playerFeedbackSubtitleLoading;

  /// No description provided for @playerFeedbackResolution.
  ///
  /// In tr, this message translates to:
  /// **'Çözünürlük: {value}'**
  String playerFeedbackResolution(String value);

  /// No description provided for @playerFeedbackFit.
  ///
  /// In tr, this message translates to:
  /// **'Görüntü: {mode}'**
  String playerFeedbackFit(String mode);

  /// No description provided for @playerFavoriteAdd.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle'**
  String get playerFavoriteAdd;

  /// No description provided for @playerFavoriteRemove.
  ///
  /// In tr, this message translates to:
  /// **'Favoriden Çıkar'**
  String get playerFavoriteRemove;

  /// No description provided for @playerNextChannel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki kanal'**
  String get playerNextChannel;

  /// No description provided for @playerPrevChannel.
  ///
  /// In tr, this message translates to:
  /// **'Önceki kanal'**
  String get playerPrevChannel;

  /// No description provided for @playerOrientationUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Ekran yönü serbest'**
  String get playerOrientationUnlocked;

  /// No description provided for @playerNextEpisode.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki bölüm: {title}'**
  String playerNextEpisode(String title);

  /// No description provided for @playerOpenExternal.
  ///
  /// In tr, this message translates to:
  /// **'Harici oynatıcıda aç (VLC)'**
  String get playerOpenExternal;

  /// No description provided for @playerExternalNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Harici oynatıcı bulunamadı. App Store\'dan VLC kurun.'**
  String get playerExternalNotFound;

  /// No description provided for @playerChannelPanelTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesi'**
  String get playerChannelPanelTooltip;

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

  /// No description provided for @seriesEpisodeCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} bölüm'**
  String seriesEpisodeCount(int count);

  /// No description provided for @homeRemoveFromHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme geçmişinden çıkar'**
  String get homeRemoveFromHistoryTitle;

  /// No description provided for @homeRemoveFromHistoryMessage.
  ///
  /// In tr, this message translates to:
  /// **'{name} izleme geçmişinden silinecek. Onaylıyor musun?'**
  String homeRemoveFromHistoryMessage(String name);

  /// No description provided for @homeRemoveFromHistoryAction.
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get homeRemoveFromHistoryAction;

  /// No description provided for @homeRemoveFromHistorySnack.
  ///
  /// In tr, this message translates to:
  /// **'{name} izleme geçmişinden kaldırıldı'**
  String homeRemoveFromHistorySnack(String name);

  /// No description provided for @homeFavoriteAdded.
  ///
  /// In tr, this message translates to:
  /// **'{name} favorilere eklendi'**
  String homeFavoriteAdded(String name);

  /// No description provided for @homeFavoriteRemoved.
  ///
  /// In tr, this message translates to:
  /// **'{name} favorilerden çıkarıldı'**
  String homeFavoriteRemoved(String name);

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

  /// No description provided for @authAppleHiddenEmail.
  ///
  /// In tr, this message translates to:
  /// **'Apple Kullanıcısı'**
  String get authAppleHiddenEmail;

  /// No description provided for @authAppleHiddenEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Apple üzerinden gizli — paylaşılmadı'**
  String get authAppleHiddenEmailHint;

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

  /// No description provided for @paywallTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Geç, Sınırları Kaldır'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı, sınırsız playlist, cihazlar arası senkron — hepsi tek seferlik ödeme ile.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefitUnlimitedPlaylists.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Playlist'**
  String get paywallBenefitUnlimitedPlaylists;

  /// No description provided for @paywallBenefitUnlimitedPlaylistsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Xtream, M3U, Stalker fark etmez'**
  String get paywallBenefitUnlimitedPlaylistsDesc;

  /// No description provided for @paywallBenefitAiSubtitles.
  ///
  /// In tr, this message translates to:
  /// **'AI Altyazı'**
  String get paywallBenefitAiSubtitles;

  /// No description provided for @paywallBenefitAiSubtitlesDesc.
  ///
  /// In tr, this message translates to:
  /// **'100+ dilde otomatik altyazı (40 saat/ay)'**
  String get paywallBenefitAiSubtitlesDesc;

  /// No description provided for @paywallBenefitCloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Cloud Senkron'**
  String get paywallBenefitCloudSync;

  /// No description provided for @paywallBenefitCloudSyncDesc.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler ve geçmiş cihazlar arası'**
  String get paywallBenefitCloudSyncDesc;

  /// No description provided for @paywallBenefitTvApps.
  ///
  /// In tr, this message translates to:
  /// **'TV + Telefon'**
  String get paywallBenefitTvApps;

  /// No description provided for @paywallBenefitTvAppsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Android TV, Google TV, iPhone, iPad'**
  String get paywallBenefitTvAppsDesc;

  /// No description provided for @paywallPlanMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get paywallPlanMonthly;

  /// No description provided for @paywallPlanYearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get paywallPlanYearly;

  /// No description provided for @paywallPlanLifetime.
  ///
  /// In tr, this message translates to:
  /// **'Yaşam Boyu'**
  String get paywallPlanLifetime;

  /// No description provided for @paywallBadgeBest.
  ///
  /// In tr, this message translates to:
  /// **'EN İYİ'**
  String get paywallBadgeBest;

  /// No description provided for @paywallBadgePopular.
  ///
  /// In tr, this message translates to:
  /// **'POPÜLER'**
  String get paywallBadgePopular;

  /// No description provided for @paywallSubscribeButton.
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Geç'**
  String get paywallSubscribeButton;

  /// No description provided for @paywallRestoreButton.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get paywallRestoreButton;

  /// No description provided for @paywallSignInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için önce hesap aç.'**
  String get paywallSignInRequired;

  /// No description provided for @paywallSignInButton.
  ///
  /// In tr, this message translates to:
  /// **'Önce hesap aç'**
  String get paywallSignInButton;

  /// No description provided for @paywallTermsFooter.
  ///
  /// In tr, this message translates to:
  /// **'Abonelikler otomatik yenilenir. Ayarlar\'dan yönetebilirsin.'**
  String get paywallTermsFooter;

  /// No description provided for @paywallPrivacyLink.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get paywallPrivacyLink;

  /// No description provided for @paywallTermsLink.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get paywallTermsLink;

  /// No description provided for @paywallPurchaseSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Pro aktif. İyi seyirler!'**
  String get paywallPurchaseSuccess;

  /// No description provided for @paywallPurchaseCancelled.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma iptal edildi.'**
  String get paywallPurchaseCancelled;

  /// No description provided for @paywallPurchaseError.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma başarısız: {message}'**
  String paywallPurchaseError(String message);

  /// No description provided for @paywallNotConfigured.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma şu anda yapılandırılmadı. Daha sonra tekrar dene.'**
  String get paywallNotConfigured;

  /// No description provided for @paywallNoOfferings.
  ///
  /// In tr, this message translates to:
  /// **'Şu an aktif paket yok.'**
  String get paywallNoOfferings;

  /// No description provided for @paywallTriggerSecondPlaylist.
  ///
  /// In tr, this message translates to:
  /// **'İkinci playlist için Pro gerekiyor'**
  String get paywallTriggerSecondPlaylist;

  /// No description provided for @paywallTriggerAiSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'AI altyazı için Pro gerekiyor'**
  String get paywallTriggerAiSubtitle;

  /// No description provided for @paywallTriggerCloudSync.
  ///
  /// In tr, this message translates to:
  /// **'Cloud senkron için Pro gerekiyor'**
  String get paywallTriggerCloudSync;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İPTV Ai Player ile sınırsız film, dizi ve canlı yayın seni bekliyor.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeFeatureUnlimited.
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız kanal & favoriler'**
  String get welcomeFeatureUnlimited;

  /// No description provided for @welcomeFeatureSubtitles.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı altyazı (100+ dil)'**
  String get welcomeFeatureSubtitles;

  /// No description provided for @welcomeFeatureSync.
  ///
  /// In tr, this message translates to:
  /// **'Cihazlar arası senkron'**
  String get welcomeFeatureSync;

  /// No description provided for @welcomeStartFreeButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesap aç → Pro\'yu dene'**
  String get welcomeStartFreeButton;

  /// No description provided for @welcomeSkipButton.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi atla'**
  String get welcomeSkipButton;

  /// No description provided for @welcomeSignInLink.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabım var'**
  String get welcomeSignInLink;

  /// No description provided for @watchlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Listem'**
  String get watchlistTitle;

  /// No description provided for @watchlistEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Listen boş'**
  String get watchlistEmpty;

  /// No description provided for @watchlistEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir film veya diziyi yer imine eklediğinde burada görünür.'**
  String get watchlistEmptyHint;

  /// No description provided for @themePickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get themePickerTitle;

  /// No description provided for @themeDefaultDark.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Koyu'**
  String get themeDefaultDark;

  /// No description provided for @themeDefaultLight.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Açık'**
  String get themeDefaultLight;

  /// No description provided for @themeCrimson.
  ///
  /// In tr, this message translates to:
  /// **'Kızıl Şafak'**
  String get themeCrimson;

  /// No description provided for @themeRoyal.
  ///
  /// In tr, this message translates to:
  /// **'Kraliyet Moru'**
  String get themeRoyal;

  /// No description provided for @themeForest.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Orman'**
  String get themeForest;

  /// No description provided for @themeOcean.
  ///
  /// In tr, this message translates to:
  /// **'Okyanus Mavisi'**
  String get themeOcean;

  /// No description provided for @parentalLockTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn Kilidi'**
  String get parentalLockTitle;

  /// No description provided for @parentalLockEnable.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn Kilidini Aç'**
  String get parentalLockEnable;

  /// No description provided for @parentalLockEnabledHint.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli kategoriler için PIN istenir.'**
  String get parentalLockEnabledHint;

  /// No description provided for @parentalLockSetupFirst.
  ///
  /// In tr, this message translates to:
  /// **'Önce 4 haneli bir PIN oluştur.'**
  String get parentalLockSetupFirst;

  /// No description provided for @parentalSetupPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Oluştur'**
  String get parentalSetupPin;

  /// No description provided for @parentalChangePin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Değiştir'**
  String get parentalChangePin;

  /// No description provided for @parentalRemovePin.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn Kilidini Kaldır'**
  String get parentalRemovePin;

  /// No description provided for @parentalLockedCategoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kilitlenecek Kategoriler'**
  String get parentalLockedCategoriesTitle;

  /// No description provided for @parentalNoCategories.
  ///
  /// In tr, this message translates to:
  /// **'Hiç kategori yok. Önce bir oynatma listesi yükle.'**
  String get parentalNoCategories;

  /// No description provided for @parentalEnterPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN\'i Gir'**
  String get parentalEnterPin;

  /// No description provided for @parentalNewPin.
  ///
  /// In tr, this message translates to:
  /// **'Yeni PIN'**
  String get parentalNewPin;

  /// No description provided for @parentalCurrentPin.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut PIN'**
  String get parentalCurrentPin;

  /// No description provided for @parentalConfirmPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Tekrar'**
  String get parentalConfirmPin;

  /// No description provided for @parentalPinIncorrect.
  ///
  /// In tr, this message translates to:
  /// **'PIN hatalı'**
  String get parentalPinIncorrect;

  /// No description provided for @parentalPinFourDigits.
  ///
  /// In tr, this message translates to:
  /// **'PIN 4 haneli rakam olmalı'**
  String get parentalPinFourDigits;

  /// No description provided for @parentalPinMismatch.
  ///
  /// In tr, this message translates to:
  /// **'PIN\'ler eşleşmiyor'**
  String get parentalPinMismatch;

  /// No description provided for @parentalPinChanged.
  ///
  /// In tr, this message translates to:
  /// **'PIN güncellendi'**
  String get parentalPinChanged;

  /// No description provided for @parentalSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get parentalSubmit;

  /// No description provided for @parentalNext.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get parentalNext;

  /// No description provided for @cloudSyncTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Senkronu'**
  String get cloudSyncTitle;

  /// No description provided for @cloudSyncProRequired.
  ///
  /// In tr, this message translates to:
  /// **'Pro abonelik gerekli'**
  String get cloudSyncProRequired;

  /// No description provided for @cloudSyncSignInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap, sonra senkronla'**
  String get cloudSyncSignInRequired;

  /// No description provided for @cloudSyncNever.
  ///
  /// In tr, this message translates to:
  /// **'Henüz senkron yok'**
  String get cloudSyncNever;

  /// No description provided for @cloudSyncSyncNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Senkronla'**
  String get cloudSyncSyncNow;

  /// No description provided for @cloudSyncJustNow.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get cloudSyncJustNow;

  /// No description provided for @cloudSyncMinutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} dk önce'**
  String cloudSyncMinutesAgo(int n);

  /// No description provided for @cloudSyncHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} sa önce'**
  String cloudSyncHoursAgo(int n);

  /// No description provided for @cloudSyncDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün önce'**
  String cloudSyncDaysAgo(int n);

  /// No description provided for @cloudSyncLastAt.
  ///
  /// In tr, this message translates to:
  /// **'Son senkron: {when}'**
  String cloudSyncLastAt(String when);

  /// No description provided for @epgGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'TV Rehberi'**
  String get epgGuideTitle;

  /// No description provided for @epgToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get epgToday;

  /// No description provided for @epgYesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get epgYesterday;

  /// No description provided for @epgTomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get epgTomorrow;

  /// No description provided for @epgRowEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu kanal için program yok'**
  String get epgRowEmpty;

  /// No description provided for @epgNoData.
  ///
  /// In tr, this message translates to:
  /// **'EPG verisi yok'**
  String get epgNoData;

  /// No description provided for @epgNoDataHint.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar → EPG bölümünden bir URL girip \'Şimdi Yenile\'ye dokunun.'**
  String get epgNoDataHint;

  /// No description provided for @epgError.
  ///
  /// In tr, this message translates to:
  /// **'EPG hatası: {msg}'**
  String epgError(String msg);

  /// No description provided for @epgAutoRefreshTitle.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Yenile'**
  String get epgAutoRefreshTitle;

  /// No description provided for @epgAutoRefreshOff.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get epgAutoRefreshOff;

  /// No description provided for @epgAutoRefreshEvery.
  ///
  /// In tr, this message translates to:
  /// **'Her {h} saatte bir'**
  String epgAutoRefreshEvery(int h);

  /// No description provided for @playerPipTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Pencereye Küçült (Pro)'**
  String get playerPipTooltip;

  /// No description provided for @playerPipUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda PiP desteklenmiyor'**
  String get playerPipUnavailable;

  /// No description provided for @playerPipEntered.
  ///
  /// In tr, this message translates to:
  /// **'Küçük pencerede oynatılıyor'**
  String get playerPipEntered;

  /// No description provided for @playerAirplayTooltip.
  ///
  /// In tr, this message translates to:
  /// **'AirPlay (ses)'**
  String get playerAirplayTooltip;

  /// No description provided for @playerAirplayUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'AirPlay bu cihazda kullanılamıyor'**
  String get playerAirplayUnavailable;

  /// No description provided for @playerAirplayAudioOnlyHint.
  ///
  /// In tr, this message translates to:
  /// **'AirPlay sesi TV\'ye gönderir. Görüntü için Kontrol Merkezi > Ekran Yansıtma\'yı kullanın.'**
  String get playerAirplayAudioOnlyHint;

  /// No description provided for @playerCastTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Cast (yakında)'**
  String get playerCastTooltip;

  /// No description provided for @settingsPipSection.
  ///
  /// In tr, this message translates to:
  /// **'Picture-in-Picture'**
  String get settingsPipSection;

  /// No description provided for @settingsPipAuto.
  ///
  /// In tr, this message translates to:
  /// **'Home tuşuna basınca otomatik PiP'**
  String get settingsPipAuto;

  /// No description provided for @settingsPipAutoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Pro — Player açıkken Home tuşuna basınca yayın küçük pencereye geçer'**
  String get settingsPipAutoSubtitle;

  /// No description provided for @settingsAdsSection.
  ///
  /// In tr, this message translates to:
  /// **'Reklam'**
  String get settingsAdsSection;

  /// No description provided for @settingsAdsRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Pro: reklam yok'**
  String get settingsAdsRemoved;

  /// No description provided for @settingsAdsFreeNotice.
  ///
  /// In tr, this message translates to:
  /// **'Free sürümde alt kısımda banner reklam görüntülenir. Pro abonelikle kalıcı reklamsız.'**
  String get settingsAdsFreeNotice;

  /// No description provided for @settingsProSection.
  ///
  /// In tr, this message translates to:
  /// **'Pro Özellikler'**
  String get settingsProSection;

  /// No description provided for @settingsContentSection.
  ///
  /// In tr, this message translates to:
  /// **'İçerik'**
  String get settingsContentSection;

  /// No description provided for @settingsPlayerSection.
  ///
  /// In tr, this message translates to:
  /// **'Oynatıcı'**
  String get settingsPlayerSection;

  /// No description provided for @settingsLegalNotice.
  ///
  /// In tr, this message translates to:
  /// **'Yasal Bildirim'**
  String get settingsLegalNotice;

  /// No description provided for @settingsDataDeletion.
  ///
  /// In tr, this message translates to:
  /// **'Veri Silme Talebi'**
  String get settingsDataDeletion;

  /// No description provided for @settingsDataDeletionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap ve veri silme talebi'**
  String get settingsDataDeletionSubtitle;

  /// No description provided for @settingsTapToSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap veya hesap oluştur'**
  String get settingsTapToSignIn;

  /// No description provided for @commonHide.
  ///
  /// In tr, this message translates to:
  /// **'Gizle'**
  String get commonHide;

  /// No description provided for @commonShow.
  ///
  /// In tr, this message translates to:
  /// **'Göster'**
  String get commonShow;

  /// No description provided for @profileSwitcherTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profiller'**
  String get profileSwitcherTitle;

  /// No description provided for @profileDefaultName.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan'**
  String get profileDefaultName;

  /// No description provided for @profileAdd.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Profil'**
  String get profileAdd;

  /// No description provided for @profileEdit.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get profileEdit;

  /// No description provided for @profileDelete.
  ///
  /// In tr, this message translates to:
  /// **'Profili Sil'**
  String get profileDelete;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu profil ve özel favori/izleme listesi silinecek. Devam edilsin mi?'**
  String get profileDeleteConfirm;

  /// No description provided for @profileNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Profil Adı'**
  String get profileNameLabel;

  /// No description provided for @profileEmptyName.
  ///
  /// In tr, this message translates to:
  /// **'Profil adı boş olamaz'**
  String get profileEmptyName;

  /// No description provided for @profileSwitched.
  ///
  /// In tr, this message translates to:
  /// **'Profil değiştirildi'**
  String get profileSwitched;

  /// No description provided for @profileMaxFreeReached.
  ///
  /// In tr, this message translates to:
  /// **'Free sürümde 1 profil. Pro ile sınırsız profil.'**
  String get profileMaxFreeReached;

  /// No description provided for @profileSection.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileSection;

  /// No description provided for @otherAppsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Diğer Uygulamalarımız'**
  String get otherAppsTitle;

  /// No description provided for @otherAppsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ekibimizin geliştirdiği diğer uygulamalar'**
  String get otherAppsSubtitle;

  /// No description provided for @otherAppsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Liste şu an yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get otherAppsEmpty;

  /// No description provided for @otherAppsRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get otherAppsRetry;

  /// No description provided for @otherAppsOpenFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza açılamadı.'**
  String get otherAppsOpenFailed;

  /// No description provided for @otherAppsGateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ebeveyn kontrolü'**
  String get otherAppsGateTitle;

  /// No description provided for @otherAppsGateQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için işlemin sonucunu yazın:'**
  String get otherAppsGateQuestion;

  /// No description provided for @otherAppsCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get otherAppsCancel;

  /// No description provided for @otherAppsContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get otherAppsContinue;

  /// No description provided for @editPlaylistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Düzenle'**
  String get editPlaylistTitle;

  /// No description provided for @editPlaylistNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Playlist bulunamadı'**
  String get editPlaylistNotFound;

  /// No description provided for @editPlaylistXtreamBadge.
  ///
  /// In tr, this message translates to:
  /// **'Xtream Codes'**
  String get editPlaylistXtreamBadge;

  /// No description provided for @editPlaylistM3uBadge.
  ///
  /// In tr, this message translates to:
  /// **'M3U Playlist'**
  String get editPlaylistM3uBadge;

  /// No description provided for @editPlaylistAddedAt.
  ///
  /// In tr, this message translates to:
  /// **'Eklenme tarihi'**
  String get editPlaylistAddedAt;

  /// No description provided for @editPlaylistExpiry.
  ///
  /// In tr, this message translates to:
  /// **'Son kullanma tarihi'**
  String get editPlaylistExpiry;

  /// No description provided for @editPlaylistExpiredLabel.
  ///
  /// In tr, this message translates to:
  /// **'⚠ Geçmiş'**
  String get editPlaylistExpiredLabel;

  /// No description provided for @editPlaylistValidLabel.
  ///
  /// In tr, this message translates to:
  /// **'✓ Geçerli'**
  String get editPlaylistValidLabel;

  /// No description provided for @editPlaylistUrlLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu URL'**
  String get editPlaylistUrlLabel;

  /// No description provided for @editPlaylistRefreshButton.
  ///
  /// In tr, this message translates to:
  /// **'Kanalları Yenile'**
  String get editPlaylistRefreshButton;

  /// No description provided for @editPlaylistDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Playlistı Sil'**
  String get editPlaylistDeleteButton;

  /// No description provided for @deletePlaylistDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist Sil'**
  String get deletePlaylistDialogTitle;

  /// No description provided for @deletePlaylistDialogQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl silmek istiyorsunuz?'**
  String get deletePlaylistDialogQuestion;

  /// No description provided for @deleteDeviceExplain.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca bu cihazdan kaldırılır. Bulut kaydı durur; istediğinizde \"Buluttan İndir\" ile geri alabilirsiniz.'**
  String get deleteDeviceExplain;

  /// No description provided for @deleteDeviceExplainLocal.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazdan kaldırılır. Bu liste bulutta kayıtlı değil; geri almak için yeniden eklemeniz gerekir.'**
  String get deleteDeviceExplainLocal;

  /// No description provided for @deletePlaylistFromCloud.
  ///
  /// In tr, this message translates to:
  /// **'Buluttan Sil'**
  String get deletePlaylistFromCloud;

  /// No description provided for @deletePlaylistFromDevice.
  ///
  /// In tr, this message translates to:
  /// **'Cihazdan Sil'**
  String get deletePlaylistFromDevice;

  /// No description provided for @deleteCloudExplain.
  ///
  /// In tr, this message translates to:
  /// **'Hem bu cihazdan hem buluttan kalıcı olarak silinir; diğer cihazlarınıza da bir daha gelmez.'**
  String get deleteCloudExplain;

  /// No description provided for @progressDownloadingList.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesi indiriliyor…'**
  String get progressDownloadingList;

  /// No description provided for @progressRetrying.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden deneniyor ({attempt}/3)…'**
  String progressRetrying(int attempt);

  /// No description provided for @progressParsingList.
  ///
  /// In tr, this message translates to:
  /// **'Kanal listesi işleniyor…'**
  String get progressParsingList;

  /// No description provided for @progressChannelsSaved.
  ///
  /// In tr, this message translates to:
  /// **'{count} kanal kaydedildi…'**
  String progressChannelsSaved(int count);

  /// No description provided for @progressServerConnecting.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya bağlanılıyor…'**
  String get progressServerConnecting;

  /// No description provided for @progressLoadingLive.
  ///
  /// In tr, this message translates to:
  /// **'Canlı kanallar yükleniyor…'**
  String get progressLoadingLive;

  /// No description provided for @progressLoadingMovies.
  ///
  /// In tr, this message translates to:
  /// **'Filmler yükleniyor…'**
  String get progressLoadingMovies;

  /// No description provided for @progressLoadingSeries.
  ///
  /// In tr, this message translates to:
  /// **'Diziler yükleniyor…'**
  String get progressLoadingSeries;

  /// No description provided for @loadErrM3uNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Bu adreste kanal listesi bulunamadı. Adresin bir M3U listesine ait olduğundan emin olun.'**
  String get loadErrM3uNotFound;

  /// No description provided for @loadErrIncomplete.
  ///
  /// In tr, this message translates to:
  /// **'Liste eksik geldi ({count} / {total} kanal) — bağlantı yarıda kesilmiş olabilir. Mevcut listeniz korundu, tekrar deneyin.'**
  String loadErrIncomplete(int count, int total);

  /// No description provided for @loadErrServerEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu boş bir liste gönderdi. Aboneliğinizde kanal tanımlı olduğundan emin olun; sorun sürerse sağlayıcınıza danışın.'**
  String get loadErrServerEmpty;

  /// No description provided for @loadErrSeriesInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu dizinin bilgisi alınamadı. Listeyi yenileyip tekrar deneyin.'**
  String get loadErrSeriesInfo;

  /// No description provided for @loadErrNoEpisodes.
  ///
  /// In tr, this message translates to:
  /// **'Sağlayıcı bu dizi için bölüm göndermedi.'**
  String get loadErrNoEpisodes;

  /// No description provided for @loadErrDrasticShrink.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yalnızca {count} kanal gönderdi (önceden {total}). Aboneliğinizin süresi dolmuş olabilir; mevcut listeniz korundu.'**
  String loadErrDrasticShrink(int count, int total);

  /// No description provided for @syncShrinkKept.
  ///
  /// In tr, this message translates to:
  /// **'{type}: sunucu öncekinden çok daha az içerik gönderdi, mevcut içerik korundu.'**
  String syncShrinkKept(String type);

  /// No description provided for @playlistSyncQueued.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedildi. Liste, süren güncelleme bitince yeniden indirilecek.'**
  String get playlistSyncQueued;

  /// No description provided for @errorReportPreviewLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilecek metin (giriş bilgileri gizlendi):'**
  String get errorReportPreviewLabel;

  /// No description provided for @paywallPricePerMonths.
  ///
  /// In tr, this message translates to:
  /// **'{price} / {months} ay'**
  String paywallPricePerMonths(String price, int months);

  /// No description provided for @paywallPlanMonths.
  ///
  /// In tr, this message translates to:
  /// **'{months} Aylık'**
  String paywallPlanMonths(int months);

  /// No description provided for @paywallIntroPriceThen.
  ///
  /// In tr, this message translates to:
  /// **'{intro} tanıtım fiyatı, sonra {price}'**
  String paywallIntroPriceThen(String intro, String price);

  /// No description provided for @watchlistClearAll.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi temizle'**
  String get watchlistClearAll;

  /// No description provided for @watchlistClearConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm öğeler silinsin mi?'**
  String get watchlistClearConfirm;

  /// No description provided for @categoryFilterPlaylist.
  ///
  /// In tr, this message translates to:
  /// **'Playlist'**
  String get categoryFilterPlaylist;

  /// No description provided for @settingsRefreshOff.
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get settingsRefreshOff;

  /// No description provided for @settingsRefreshOnOpen.
  ///
  /// In tr, this message translates to:
  /// **'Her Açılışta'**
  String get settingsRefreshOnOpen;

  /// No description provided for @settingsRefresh1Day.
  ///
  /// In tr, this message translates to:
  /// **'Her 1 Gün'**
  String get settingsRefresh1Day;

  /// No description provided for @settingsRefresh1Week.
  ///
  /// In tr, this message translates to:
  /// **'Her 1 Hafta'**
  String get settingsRefresh1Week;

  /// No description provided for @settingsRefresh1Month.
  ///
  /// In tr, this message translates to:
  /// **'Her 1 Ay'**
  String get settingsRefresh1Month;

  /// No description provided for @settingsRefresh1Year.
  ///
  /// In tr, this message translates to:
  /// **'Her 1 Yıl'**
  String get settingsRefresh1Year;

  /// No description provided for @settingsClearHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişi Temizle'**
  String get settingsClearHistoryTitle;

  /// No description provided for @settingsClearHistorySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son İzlenenler, Nerede Kaldım ve İzlenenler listelerini temizler. Favorileriniz silinmez'**
  String get settingsClearHistorySubtitle;

  /// No description provided for @settingsClearHistoryDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme geçmişi temizlensin mi?'**
  String get settingsClearHistoryDialogTitle;

  /// No description provided for @settingsClearHistoryDialogMessage.
  ///
  /// In tr, this message translates to:
  /// **'Son İzlenenler, Nerede Kaldım ve İzlenenler listelerindeki tüm kayıtlar silinecek. Bu işlem geri alınamaz.'**
  String get settingsClearHistoryDialogMessage;

  /// No description provided for @settingsClearHistoryAction.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get settingsClearHistoryAction;

  /// No description provided for @epgNextProgram.
  ///
  /// In tr, this message translates to:
  /// **'Sonra: {title}'**
  String epgNextProgram(String title);

  /// No description provided for @xtreamBadLogin.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı veya şifre hatalı. Bilgileri sağlayıcınızdan kontrol edip tekrar deneyin.'**
  String get xtreamBadLogin;

  /// No description provided for @xtreamExpired.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğinizin süresi dolmuş. Yenilemek için sağlayıcınızla iletişime geçin.'**
  String get xtreamExpired;

  /// No description provided for @xtreamExpiredOn.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliğinizin süresi {date} tarihinde dolmuş. Yenilemek için sağlayıcınızla iletişime geçin.'**
  String xtreamExpiredOn(String date);

  /// No description provided for @xtreamDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız sağlayıcı tarafından kapatılmış. Sağlayıcınızla iletişime geçin.'**
  String get xtreamDisabled;

  /// No description provided for @epgAutoRefreshAuto.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik — rehber bitmek üzereyken yenilenir'**
  String get epgAutoRefreshAuto;

  /// No description provided for @xtreamPartialLoad.
  ///
  /// In tr, this message translates to:
  /// **'Bazı içerikler yüklenemedi: {type}'**
  String xtreamPartialLoad(String type);

  /// No description provided for @settingsPlaylistAutoRefreshTitle.
  ///
  /// In tr, this message translates to:
  /// **'Playlist otomatik yenileme'**
  String get settingsPlaylistAutoRefreshTitle;

  /// No description provided for @settingsEpgUrlForPlaylist.
  ///
  /// In tr, this message translates to:
  /// **'Aktif playlist için: {name}'**
  String settingsEpgUrlForPlaylist(String name);

  /// No description provided for @settingsClearHistoryDone.
  ///
  /// In tr, this message translates to:
  /// **'İzleme geçmişi temizlendi'**
  String get settingsClearHistoryDone;

  /// No description provided for @settingsSupportSection.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get settingsSupportSection;

  /// No description provided for @settingsFeedbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim Gönder'**
  String get settingsFeedbackTitle;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Öneri, hata bildirimi veya genel görüş'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @feedbackDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedbackDialogTitle;

  /// No description provided for @feedbackThanks.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler!'**
  String get feedbackThanks;

  /// No description provided for @feedbackReceived.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildiriminiz iletildi.'**
  String get feedbackReceived;

  /// No description provided for @feedbackChooseType.
  ///
  /// In tr, this message translates to:
  /// **'Türü seçin:'**
  String get feedbackChooseType;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Öneri'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get feedbackTypeGeneral;

  /// No description provided for @feedbackNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get feedbackNameLabel;

  /// No description provided for @feedbackNamePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı'**
  String get feedbackNamePlaceholder;

  /// No description provided for @feedbackEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta *'**
  String get feedbackEmailLabel;

  /// No description provided for @feedbackEmailPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'ornek@mail.com'**
  String get feedbackEmailPlaceholder;

  /// No description provided for @feedbackEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get feedbackEmailInvalid;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız *'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessagePlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Düşüncelerinizi yazın...'**
  String get feedbackMessagePlaceholder;

  /// No description provided for @feedbackScreenshotLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ekran görüntüsü (en fazla 3)'**
  String get feedbackScreenshotLabel;

  /// No description provided for @feedbackAddImage.
  ///
  /// In tr, this message translates to:
  /// **'Resim Ekle'**
  String get feedbackAddImage;

  /// No description provided for @feedbackError.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi: {details}'**
  String feedbackError(String details);

  /// No description provided for @feedbackImageTooLarge.
  ///
  /// In tr, this message translates to:
  /// **'5 MB\'tan büyük görseller eklenemez'**
  String get feedbackImageTooLarge;

  /// No description provided for @commonSend.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get commonSend;

  /// No description provided for @commonSending.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get commonSending;

  /// No description provided for @settingsRateApp.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı değerlendir'**
  String get settingsRateApp;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'App Store\'da puan ver ve yorum yaz'**
  String get settingsRateAppSubtitle;

  /// No description provided for @paywallBenefitPlaylistsUpTo.
  ///
  /// In tr, this message translates to:
  /// **'{count} playlist\'e kadar'**
  String paywallBenefitPlaylistsUpTo(int count);

  /// No description provided for @paywallBenefitAiWhisper.
  ///
  /// In tr, this message translates to:
  /// **'AI Whisper altyazı'**
  String get paywallBenefitAiWhisper;

  /// No description provided for @paywallBenefitCloudSyncDevices.
  ///
  /// In tr, this message translates to:
  /// **'Bulut senkronu (cihazlar arası)'**
  String get paywallBenefitCloudSyncDevices;

  /// No description provided for @paywallBenefitThemes.
  ///
  /// In tr, this message translates to:
  /// **'Premium temalar'**
  String get paywallBenefitThemes;

  /// No description provided for @paywallBenefitWatchlist.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listem'**
  String get paywallBenefitWatchlist;

  /// No description provided for @paywallBenefitEpgAuto.
  ///
  /// In tr, this message translates to:
  /// **'TV rehberi otomatik yenileme'**
  String get paywallBenefitEpgAuto;

  /// No description provided for @paywallPricePerYear.
  ///
  /// In tr, this message translates to:
  /// **'{price} / yıl'**
  String paywallPricePerYear(String price);

  /// No description provided for @paywallPricePerMonth.
  ///
  /// In tr, this message translates to:
  /// **'{price} / ay'**
  String paywallPricePerMonth(String price);

  /// No description provided for @paywallPricePerWeek.
  ///
  /// In tr, this message translates to:
  /// **'{price} / hafta'**
  String paywallPricePerWeek(String price);

  /// No description provided for @paywallPriceOneTime.
  ///
  /// In tr, this message translates to:
  /// **'{price} tek seferlik'**
  String paywallPriceOneTime(String price);

  /// No description provided for @paywallMonthlyEquivalent.
  ///
  /// In tr, this message translates to:
  /// **'Aylık yalnızca {price}'**
  String paywallMonthlyEquivalent(String price);

  /// No description provided for @paywallTrialThen.
  ///
  /// In tr, this message translates to:
  /// **'{days, plural, other{İlk {days} gün ücretsiz}}, ardından {price}. İstediğin zaman iptal et.'**
  String paywallTrialThen(int days, String price);

  /// No description provided for @paywallLifetimeHint.
  ///
  /// In tr, this message translates to:
  /// **'✦ Tek seferlik ödeme · Ömür boyu erişim'**
  String get paywallLifetimeHint;

  /// No description provided for @paywallPurchase.
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get paywallPurchase;

  /// No description provided for @paywallTermsFooterApple.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme, satın alma onayında Apple Kimliğinizden tahsil edilir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmezse otomatik olarak yenilenir. App Store hesap ayarlarından yönetebilir veya iptal edebilirsiniz.'**
  String get paywallTermsFooterApple;

  /// No description provided for @paywallActivationPending.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma tamamlandı ancak Pro henüz etkinleşmedi. Satın alımları geri yüklemeyi deneyin; sorun sürerse destekle iletişime geçin.'**
  String get paywallActivationPending;

  /// No description provided for @paywallLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Planlar yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.'**
  String get paywallLoadError;

  /// No description provided for @playlistDeviceLimit.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz en fazla {count} playlist destekliyor.'**
  String playlistDeviceLimit(int count);

  /// No description provided for @authReauthTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kimliğini doğrula'**
  String get authReauthTitle;

  /// No description provided for @authReauthPasswordMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silmek için şifreni gir.'**
  String get authReauthPasswordMessage;

  /// No description provided for @authAccountDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silindi.'**
  String get authAccountDeleted;

  /// No description provided for @playerUrlMissing.
  ///
  /// In tr, this message translates to:
  /// **'Yayın URL\'si bulunamadı'**
  String get playerUrlMissing;

  /// No description provided for @parentalPinWrongAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış PIN. {remaining} deneme hakkınız kaldı.'**
  String parentalPinWrongAttempts(int remaining);

  /// No description provided for @parentalPinCooldown.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla yanlış giriş. {seconds} saniye bekleyin.'**
  String parentalPinCooldown(int seconds);

  /// No description provided for @paywallRestoreNothing.
  ///
  /// In tr, this message translates to:
  /// **'Bu Apple Kimliği için geri yüklenecek satın alma bulunamadı.'**
  String get paywallRestoreNothing;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'it', 'ro', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'it': return AppLocalizationsIt();
    case 'ro': return AppLocalizationsRo();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
