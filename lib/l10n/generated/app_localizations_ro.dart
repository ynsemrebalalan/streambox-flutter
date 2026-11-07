// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anulează';

  @override
  String get save => 'Salvează';

  @override
  String get delete => 'Șterge';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  @override
  String get close => 'Închide';

  @override
  String get back => 'Înapoi';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get loading => 'Se încarcă…';

  @override
  String get error => 'Eroare';

  @override
  String get errorGeneric => 'A apărut o problemă. Încearcă din nou.';

  @override
  String get language => 'Limbă';

  @override
  String get languageSystem => 'Limba sistemului';

  @override
  String get languageTurkish => 'Turcă';

  @override
  String get languageEnglish => 'Engleză';

  @override
  String get languageGerman => 'Germană';

  @override
  String get languageArabic => 'Arabă';

  @override
  String get languageItalian => 'Italiană';

  @override
  String get languageSpanish => 'Spaniolă';

  @override
  String get languageRomanian => 'Română';

  @override
  String errorWithDetails(String details) {
    return 'Eroare: $details';
  }

  @override
  String get commonAdd => 'Adaugă';

  @override
  String get commonRefresh => 'Actualizează';

  @override
  String get commonDeleteConfirm => 'Șterge';

  @override
  String get errorTimeoutProvider => 'Furnizorul nu a răspuns. Încearcă mai târziu.';

  @override
  String get errorNoConnection => 'Nu există conexiune la internet sau furnizorul este inaccesibil.';

  @override
  String get errorDatabaseTemporary => 'Baza de date este temporar indisponibilă. Încearcă din nou.';

  @override
  String get errorGenericRetry => 'A apărut o problemă. Încearcă din nou.';

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsSaved => 'Setări salvate';

  @override
  String get settingsAppearanceSection => 'Aspect';

  @override
  String get settingsThemeDark => 'Temă întunecată';

  @override
  String get settingsThemeLight => 'Temă luminoasă';

  @override
  String get settingsThemeSystem => 'Tema sistemului';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'URL EPG (.xml sau .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'Actualizează EPG acum';

  @override
  String get settingsSelectPlaylistFirst => 'Selectează mai întâi o playlist';

  @override
  String get settingsEpgUpdated => 'EPG actualizat cu succes';

  @override
  String settingsEpgError(String details) {
    return 'Eroare EPG: $details';
  }

  @override
  String get settingsSubtitleSection => 'Subtitrări';

  @override
  String get settingsSubtitleFontSize => 'Dimensiunea fontului';

  @override
  String get subtitleSizeSmall => 'Mică';

  @override
  String get subtitleSizeNormal => 'Normală';

  @override
  String get subtitleSizeLarge => 'Mare';

  @override
  String get subtitleSizeExtraLarge => 'Foarte mare';

  @override
  String get settingsSubtitleTextColor => 'Culoarea textului';

  @override
  String get subtitleColorWhite => 'Alb';

  @override
  String get subtitleColorYellow => 'Galben';

  @override
  String get subtitleColorGreen => 'Verde';

  @override
  String get subtitleColorCyan => 'Turcoaz';

  @override
  String get settingsSubtitleBgColor => 'Fundal';

  @override
  String get subtitleBgSemi => 'Semitransparent';

  @override
  String get subtitleBgOpaque => 'Negru';

  @override
  String get subtitleBgNone => 'Fără';

  @override
  String get settingsAboutSection => 'Despre';

  @override
  String settingsAppVersion(String version) {
    return 'Versiunea $version';
  }

  @override
  String get settingsPlaylistManagement => 'Gestionare playlisturi';

  @override
  String get settingsCategoryFilterSubtitle => 'Ascunde/afișează categorii';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Adaugă o playlist pentru a începe';

  @override
  String get homeAddPlaylist => 'Adaugă playlist';

  @override
  String get homeSearchHint => 'Caută canale, filme, seriale…';

  @override
  String get homePlaylistsTooltip => 'Playlisturi';

  @override
  String get homeMore => 'Mai mult';

  @override
  String get homePlaylistSyncing => 'Se sincronizează lista…';

  @override
  String get homeSearchTooltip => 'Caută';

  @override
  String get watchlistAddTooltip => 'Adaugă în Lista mea';

  @override
  String get watchlistRemoveTooltip => 'Elimină din Lista mea';

  @override
  String get playerPlayAction => 'Redă';

  @override
  String get playerPauseAction => 'Pauză';

  @override
  String get playlistsActiveLabel => 'Activă';

  @override
  String get homeCategoryManagement => 'Gestionare categorii';

  @override
  String get homeTabHome => 'Acasă';

  @override
  String get homeTabLive => 'Live';

  @override
  String get homeTabMovie => 'Filme';

  @override
  String get homeTabSeries => 'Seriale';

  @override
  String get homeTabFavorites => 'Favorite';

  @override
  String get homeFavoritesAll => 'Toate';

  @override
  String get homeFavoritesLive => 'Live';

  @override
  String get homeFavoritesMovie => 'Filme';

  @override
  String get homeFavoritesSeries => 'Seriale';

  @override
  String get homeEmptyFavorites => 'Încă nu ai favorite';

  @override
  String get homeEmptyFavoritesType => 'Nu există favorite de acest tip';

  @override
  String get homeEmptyCategory => 'Nu există conținut în această categorie';

  @override
  String get homeRowContinueWatching => 'Continuă vizionarea';

  @override
  String get homeRowRecentlyWatched => 'Vizionate recent';

  @override
  String get homeRowNewMovies => 'Filme noi';

  @override
  String get homeRowNewSeries => 'Seriale noi';

  @override
  String get homeRowNewChannels => 'Canale noi';

  @override
  String get homeEmptyContent => 'Încă nu există conținut';

  @override
  String get homeEmptyContentHint => 'Explorează filele Filme / Seriale / Live pentru a începe';

  @override
  String get homeRecentlyWatchedHeader => 'VIZIONATE RECENT';

  @override
  String get homeSearchEmpty => 'Începe să scrii pentru a căuta';

  @override
  String homeSearchNoResults(String query) {
    return 'Niciun rezultat pentru „$query”';
  }

  @override
  String homeContentCount(int count) {
    return '$count element(e)';
  }

  @override
  String get sortDialogTitle => 'Sortare';

  @override
  String get sortLabelDefault => 'Implicit';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Sortare';

  @override
  String get playlistsTitle => 'Playlisturi';

  @override
  String get playlistsEmpty => 'Încă nu există playlisturi';

  @override
  String get playlistsRefreshTooltip => 'Actualizează';

  @override
  String get playlistsDeleteTooltip => 'Șterge';

  @override
  String get playlistsRetryAction => 'REÎNCEARCĂ';

  @override
  String get playlistsUpdated => 'Playlist actualizată.';

  @override
  String get playlistsDeleteTitle => 'Șterge playlistul';

  @override
  String playlistsDeleteConfirm(String name) {
    return 'Ștergi „$name”?';
  }

  @override
  String get playlistsAddTitle => 'Adaugă playlist';

  @override
  String get playlistsTypeM3u => 'URL M3U';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsTypeStalker => 'Stalker / MAG';

  @override
  String get playlistsStalkerCardTitle => 'Portal Stalker / MAG Box';

  @override
  String get playlistsStalkerCardBody => 'Adresa ta MAC trebuie să fie înregistrată la furnizorul tău IPTV. Aplicația încearcă mai întâi calea rapidă M3U, apoi revine la protocolul Stalker complet dacă este necesar.';

  @override
  String get playlistsStalkerPortalLabel => 'URL portal';

  @override
  String get playlistsStalkerPortalHint => 'http://provider.com:8080';

  @override
  String get playlistsStalkerMacLabel => 'Adresă MAC';

  @override
  String get playlistsStalkerMacHint => '00:1A:79:XX:XX:XX';

  @override
  String get playlistsStalkerMacGenerate => 'Generează';

  @override
  String get playlistsStalkerMacHelp => 'Format MAC: XX:XX:XX:XX:XX:XX (majuscule, separate prin două puncte)';

  @override
  String get playlistsValidationStalkerMac => 'Introdu o adresă MAC validă (XX:XX:XX:XX:XX:XX).';

  @override
  String get editPlaylistStalkerBadge => 'Stalker / MAG';

  @override
  String get progressTryingPortalList => 'Se încearcă preluarea listei din portal…';

  @override
  String get progressPortalConnecting => 'Se conectează la portal…';

  @override
  String get loadErrPortalConnect => 'Nu s-a putut realiza conexiunea la portal. Verifică adresa portalului și dacă adresa ta MAC este înregistrată la furnizor.';

  @override
  String get loadErrPortalList => 'Lista de canale nu a putut fi preluată. Verifică la furnizor dacă adresa ta MAC este înregistrată în portal.';

  @override
  String get playlistsNameLabel => 'Numele playlistului';

  @override
  String get playlistsM3uUrlLabel => 'URL M3U';

  @override
  String get playlistsM3uUrlHint => 'http://… sau https://…';

  @override
  String get playlistsPasteFromClipboard => 'Lipește din clipboard';

  @override
  String get playlistsClipboardEmpty => 'Clipboardul este gol';

  @override
  String get playlistsServerUrlLabel => 'URL server';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'Nume de utilizator';

  @override
  String get playlistsPasswordLabel => 'Parolă';

  @override
  String get playlistsContentTypes => 'Tipuri de conținut';

  @override
  String get playlistsContentLive => 'Live';

  @override
  String get playlistsContentMovie => 'Filme';

  @override
  String get playlistsContentSeries => 'Seriale';

  @override
  String get playlistsValidationNameUrl => 'Numele și URL-ul sunt obligatorii';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream necesită nume de utilizator și parolă';

  @override
  String get playlistsErrorTlsHandshake => 'Nu s-a putut stabili o conexiune securizată (eroare TLS). Încearcă http:// sau verifică adresa furnizorului.';

  @override
  String get playlistsErrorTimeout => 'Furnizorul nu a răspuns (timp expirat). Încearcă mai târziu.';

  @override
  String get playlistsErrorConnection => 'Nu există conexiune la internet sau furnizorul este inaccesibil.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'Playlistul nu a putut fi actualizat: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'Furnizorul a returnat o playlist goală. Datele anterioare au fost păstrate.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Se reconectează ($attempt)…';
  }

  @override
  String get playerReconnecting => 'Se reconectează…';

  @override
  String get playerLoading => 'Se încarcă…';

  @override
  String get playerStreamRepeatedError => 'Fluxul se deconectează în mod repetat. Încearcă alt canal.';

  @override
  String get playerReconnectTooltip => 'Reconectează';

  @override
  String get playerSubtitleEnable => 'Activează subtitrările AI';

  @override
  String get playerSubtitleDisable => 'Dezactivează subtitrările AI';

  @override
  String get playerMuteTooltip => 'Dezactivează sunetul';

  @override
  String get playerUnmuteTooltip => 'Activează sunetul';

  @override
  String get playerLiveLabel => 'LIVE';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Pistă audio';

  @override
  String get playerAudioTrackDialog => 'Pistă audio';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Pista $n';
  }

  @override
  String get playerSpeedDialog => 'Viteza de redare';

  @override
  String get playerSubtitleDialogTitle => 'Subtitrare';

  @override
  String get playerSubtitleAi => 'Subtitrare AI';

  @override
  String get playerSubtitleAiActive => '(Activă)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Încorporată $n';
  }

  @override
  String get playerSubtitleOff => 'Oprite';

  @override
  String get playerScreenSizeTooltip => 'Dimensiunea ecranului';

  @override
  String get playerScreenSizeDialog => 'Dimensiunea ecranului';

  @override
  String get playerFitOriginal => 'Original';

  @override
  String get playerFitCover => 'Umple ecranul (decupat)';

  @override
  String get playerFitStretch => 'Întinde';

  @override
  String get playerResolutionTooltip => 'Rezoluție';

  @override
  String get playerResolutionDialog => 'Rezoluție';

  @override
  String get playerResolutionAuto => 'Automată';

  @override
  String get playerSingleQuality => 'Acest flux oferă o singură calitate.';

  @override
  String get playerErrorUnsupportedFormat => 'Formatul video sau audio al acestei transmisiuni nu poate fi redat pe acest dispozitiv. Încercați altă sursă sau un player extern.';

  @override
  String get playerErrorCorruptStream => 'Datele transmisiunii nu au putut fi citite. Canalul poate fi temporar defect; încercați mai târziu.';

  @override
  String get aiSubErrUnavailable => 'Serviciul de subtitrări AI nu este disponibil momentan. Te rugăm să încerci din nou mai târziu.';

  @override
  String get aiSubErrProRequired => 'Perioada de probă pentru subtitrările AI s-a încheiat. Treci la Pro pentru a continua.';

  @override
  String get aiSubErrQuota => 'Cota de utilizare pentru subtitrările AI a fost epuizată.';

  @override
  String get aiSubErrBusy => 'Serviciul de subtitrări AI este foarte aglomerat acum. Așteaptă puțin și încearcă din nou.';

  @override
  String get aiSubErrInvalidKey => 'Cheia API pentru subtitrările AI este invalidă sau a expirat. Verific-o din Setări > Subtitrări AI.';

  @override
  String get aiSubErrRejected => 'Serviciul de subtitrări AI nu a acceptat solicitarea. Te rugăm să încerci din nou mai târziu.';

  @override
  String get aiSubErrEmptyResponse => 'Serviciul de subtitrări AI a trimis un răspuns gol. Te rugăm să încerci din nou.';

  @override
  String get aiSubErrNoSpeech => 'Nu s-a detectat vorbire în această porțiune. Încearcă din nou în alt moment al videoclipului.';

  @override
  String get aiSubErrGeneric => 'Subtitrările nu au putut fi create. Te rugăm să încerci din nou.';

  @override
  String get aiSubErrUnreachable => 'Serviciul de subtitrări AI nu poate fi accesat. Verifică conexiunea la internet.';

  @override
  String get aiSubErrConnectTimeout => 'Conectarea la serviciul de subtitrări AI a expirat. Te rugăm să încerci din nou.';

  @override
  String get aiSubErrExtract => 'Sunetul pentru subtitrările AI nu a putut fi citit. Formatul acestui flux nu este acceptat pe unele dispozitive. Încearcă o sursă de calitate mai mică sau un player extern.';

  @override
  String get aiSubErrNoOpenAiKey => 'Nu a fost introdusă nicio cheie API OpenAI. Adaug-o din Setări > Subtitrări AI.';

  @override
  String aiTrialStarted(int days) {
    return 'Perioada ta de probă gratuită de $days zile pentru subtitrări AI a început';
  }

  @override
  String get paywallAiTrialEnded => 'Perioada de probă pentru subtitrări AI s-a încheiat. Treci la Pro ca să le folosești în continuare.';

  @override
  String get playerAiPreparing => 'Se pregătesc subtitrările AI';

  @override
  String playerSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String playerBannerWhisper(String lang) {
    return 'Subtitrări AI (recunoaștere vocală): $lang';
  }

  @override
  String get playerOrientationLock => 'Blochează orientarea ecranului';

  @override
  String playerResumeQuestion(String position) {
    return 'Reiei de la $position?';
  }

  @override
  String get playerResumeContinue => 'Reia';

  @override
  String get playerResumeFromBeginning => 'De la început';

  @override
  String get playerErrorStreamUnavailable => 'Acest canal nu a putut fi deschis. Sursa nu răspunde sau conexiunea s-a întrerupt.';

  @override
  String get playerErrorBackToList => 'Înapoi la lista de canale';

  @override
  String get playerReportError => 'Raportează eroare';

  @override
  String get errorReportTitle => 'Raportează eroare';

  @override
  String get errorReportThanks => 'Mulțumim!';

  @override
  String get errorReportReceived => 'Raportarea ta de eroare a fost trimisă.';

  @override
  String errorReportChannel(String name) {
    return 'Canal: $name';
  }

  @override
  String errorReportError(String error) {
    return 'Eroare: $error';
  }

  @override
  String errorReportDevice(String device) {
    return 'Dispozitiv: $device';
  }

  @override
  String errorReportVersion(String version) {
    return 'Versiune: $version';
  }

  @override
  String get errorReportNoteLabel => 'Notă suplimentară (opțional):';

  @override
  String get errorReportNotePlaceholder => 'Ce făceai?';

  @override
  String get errorReportSend => 'Trimite';

  @override
  String playerPanelChannels(int count) {
    return 'Canale ($count)';
  }

  @override
  String get playerSeekForward => '▶▶ +10s';

  @override
  String get playerSeekBackward => '◀◀ -10s';

  @override
  String get playerWatchlistAdded => 'Adăugat în listă';

  @override
  String get playerWatchlistRemoved => 'Eliminat din listă';

  @override
  String get playerWatchlistTooltip => 'Vizionează mai târziu';

  @override
  String get settingsAiSection => 'Subtitrări AI';

  @override
  String get settingsAiTargetLangTitle => 'Limba țintă a subtitrărilor AI';

  @override
  String get settingsAiTargetLangSubtitle => 'Limba pentru subtitrările traduse';

  @override
  String get settingsAiTargetLangAuto => 'Automată (limba dispozitivului)';

  @override
  String get settingsAiTargetLangDialogTitle => 'Alege limba țintă';

  @override
  String get settingsAiBannerTitle => 'Banner subtitrări AI';

  @override
  String get settingsAiBannerSubtitle => 'Afișează limba sursă/țintă în partea de sus';

  @override
  String get settingsAiWhisperTitle => 'Subtitrări AI Whisper';

  @override
  String get settingsAiWhisperSubtitle => 'Subtitrări generate automat în player';

  @override
  String get settingsAiProviderGroq => 'Groq';

  @override
  String get settingsAiProviderGroqBadge => 'Pro';

  @override
  String get settingsAiProviderOpenai => 'OpenAI';

  @override
  String get settingsAiProviderOpenaiBadge => 'Cu plată';

  @override
  String settingsAiGroqInfo(int days) {
    return 'Serviciu Groq integrat — funcție Pro, $days zile de probă gratuită';
  }

  @override
  String get settingsAiOpenaiCost => 'Cost estimat: ~\$0.006/cerere · ~\$0.006/min · openai.com/account/billing';

  @override
  String get settingsAiOpenaiKeyLabel => 'Cheie API OpenAI';

  @override
  String get settingsAiOpenaiKeyPlaceholder => 'sk-…';

  @override
  String get settingsAiOpenaiKeySaved => '✓ Cheie OpenAI salvată';

  @override
  String get settingsSubtitleDefaultOn => 'Subtitrări active implicit';

  @override
  String get settingsSubtitleDefaultOnSubtitle => 'Activează subtitrările la deschiderea playerului';

  @override
  String get settingsBufferDuration => 'Durata bufferului';

  @override
  String settingsBufferSeconds(int seconds) {
    return '$seconds secunde';
  }

  @override
  String aiTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Probă subtitrări AI: $days de zile rămase',
      few: 'Probă subtitrări AI: $days zile rămase',
      one: 'Probă subtitrări AI: $days zi rămasă',
    );
    return '$_temp0';
  }

  @override
  String get playerPaused => 'Pauză';

  @override
  String get playerPlaying => 'Redare';

  @override
  String get playerMuted => 'Sunet oprit';

  @override
  String get playerUnmuted => 'Sunet pornit';

  @override
  String playerFeedbackAudio(String label) {
    return 'Audio: $label';
  }

  @override
  String playerFeedbackSpeed(String speed) {
    return 'Viteză $speed';
  }

  @override
  String get playerFeedbackSubtitleOff => 'Subtitrări oprite';

  @override
  String playerFeedbackSubtitle(String lang) {
    return 'Subtitrări: $lang';
  }

  @override
  String get playerFeedbackSubtitleLoading => 'Se încarcă subtitrările…';

  @override
  String playerFeedbackResolution(String value) {
    return 'Rezoluție: $value';
  }

  @override
  String playerFeedbackFit(String mode) {
    return 'Imagine: $mode';
  }

  @override
  String get playerFavoriteAdd => 'Adaugă la favorite';

  @override
  String get playerFavoriteRemove => 'Elimină din favorite';

  @override
  String get playerNextChannel => 'Canalul următor';

  @override
  String get playerPrevChannel => 'Canalul anterior';

  @override
  String get playerOrientationUnlocked => 'Rotație deblocată';

  @override
  String playerNextEpisode(String title) {
    return 'Episodul următor: $title';
  }

  @override
  String get playerOpenExternal => 'Deschide în player extern (VLC)';

  @override
  String get playerExternalNotFound => 'Nu a fost găsit niciun player extern. Instalează VLC din App Store.';

  @override
  String get playerChannelPanelTooltip => 'Lista de canale';

  @override
  String get disclaimerWelcome => 'Bine ai venit';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player este un player multimedia pentru propriile tale playlisturi M3U și surse Xtream Codes.\n\nAceastă aplicație nu furnizează, nu găzduiește și nu distribuie niciun conținut. Trebuie să furnizezi propriul URL de playlist obținut legal.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player este un player multimedia pentru propriile tale playlisturi M3U și surse Xtream Codes. Aplicația nu găzduiește și nu distribuie niciun conținut.';

  @override
  String get disclaimerLegalNoticeButton => 'Aviz legal';

  @override
  String get disclaimerContinue => 'Continuă';

  @override
  String get disclaimerFooter => 'Continuând, accepți avizul legal.';

  @override
  String get legalNoticeTitle => 'Aviz legal';

  @override
  String get legalSection1Title => '1. Natura aplicației';

  @override
  String get legalSection1En => 'IPTV AI Player este un player multimedia de uz general (similar cu VLC sau MX Player). NU furnizează, găzduiește, distribuie și nu redirecționează către transmisiuni TV, filme, seriale, evenimente sportive sau alte conținuturi. Aplicația este un instrument care redă URL-uri de playlist M3U / M3U8 sau credențiale Xtream Codes furnizate de utilizator.';

  @override
  String get legalSection1Tr => 'IPTV AI Player este un player multimedia de uz general. Nu furnizează, nu găzduiește și nu distribuie niciun conținut; redă doar URL-urile de playlist sau credențialele Xtream furnizate de utilizator.';

  @override
  String get legalSection2Title => '2. Responsabilitatea privind conținutul';

  @override
  String get legalSection2En => 'Utilizatorul este singurul responsabil pentru tot conținutul accesat prin aplicație. Dezvoltatorul nu are cunoștință despre acest conținut și nu își asumă nicio responsabilitate pentru el.';

  @override
  String get legalSection2Tr => 'Utilizatorul este singurul responsabil pentru orice conținut accesat prin aplicație. Dezvoltatorul nu are vizibilitate asupra acestui conținut și nu își asumă responsabilitatea pentru el.';

  @override
  String get legalSection3Title => '3. Cadrul legal turc';

  @override
  String get legalSection3Item1 => 'Articolele 71-72 din Legea nr. 5846 (FSEK, Turcia): încălcarea drepturilor de autor atrage sancțiuni civile și penale.';

  @override
  String get legalSection3Item2 => 'Articolul 163/2 din Codul penal turc: utilizarea neautorizată a transmisiunilor criptate/necriptate.';

  @override
  String get legalSection3Item3 => 'Articolul adițional 4 din FSEK: încălcarea drepturilor de autor pe internet.';

  @override
  String get legalSection3Item4 => 'RTÜK și BTK pot impune interdicții de acces conform Legilor nr. 6112 și 5651.';

  @override
  String get legalSection4Title => '4. Obligațiile utilizatorului';

  @override
  String get legalSection4Body => 'Prin utilizarea acestei aplicații recunoști că vei accesa doar conținut la care ești abonat legal, că nu vei accesa conținut protejat prin drepturi de autor fără autorizație și că nu vei folosi aplicația pentru transmisiuni piratate sau servicii IPTV fără licență.';

  @override
  String get legalSection5Title => '5. Protecția datelor';

  @override
  String get legalSection5Body => 'Aplicația stochează URL-urile playlisturilor și credențialele tale doar local, pe dispozitivul tău. Acestea nu sunt partajate cu terți.';

  @override
  String get legalSection6Title => '6. Limitarea răspunderii';

  @override
  String get legalSection6Body => 'Aplicația este furnizată „CA ATARE”. Dezvoltatorul nu este responsabil pentru eventualele daune rezultate din utilizarea aplicației.';

  @override
  String get legalSection7Title => '7. Colaborare juridică';

  @override
  String get legalSection7Body => 'Dezvoltatorul respectă solicitările legitime ale autorităților competente (RTÜK, BTK, procurori).';

  @override
  String get legalReminder => 'Reamintire: utilizarea acestei aplicații pentru a accesa conținut neautorizat sau protejat prin drepturi de autor este ilegală. Utilizatorul poartă întreaga răspundere juridică.';

  @override
  String get searchHint => 'Caută canale, filme, seriale…';

  @override
  String get searchMinChars => 'Introdu cel puțin 2 caractere';

  @override
  String searchNoResults(String query) {
    return 'Niciun rezultat pentru „$query”';
  }

  @override
  String get categoryFilterTitle => 'Filtru de categorii';

  @override
  String get categoryFilterShowAll => 'Afișează toate';

  @override
  String get categoryFilterHideAll => 'Ascunde toate';

  @override
  String get categoryFilterEmpty => 'Încă nu există categorii';

  @override
  String get categoryFilterSectionLive => 'Live';

  @override
  String get categoryFilterSectionMovie => 'Filme';

  @override
  String get categoryFilterSectionSeries => 'Seriale';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total active)';
  }

  @override
  String get seriesEmptyCategory => 'Nu există seriale în această categorie';

  @override
  String seriesSeasonCount(int count) {
    return '$count sezon/sezoane';
  }

  @override
  String get seriesSpecialSeason => 'Speciale';

  @override
  String seriesSeasonNumber(int n) {
    return 'Sezonul $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count episoade';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'Elimină din istoricul vizionărilor';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name va fi eliminat din istoricul vizionărilor. Continui?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Elimină';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name a fost eliminat din istoricul vizionărilor';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name a fost adăugat la favorite';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name a fost eliminat din favorite';
  }

  @override
  String get homeRowPopular => 'Populare';

  @override
  String get homeRowWatchedMovies => 'Filme pe care le-ai vizionat';

  @override
  String get homeRowWatchedSeries => 'Seriale pe care le-ai vizionat';

  @override
  String get badgeMovieUppercase => 'FILM';

  @override
  String get badgeSeriesUppercase => 'SERIAL';

  @override
  String get settingsEpgPresetsTitle => 'Presetări';

  @override
  String get menuMyPlaylists => 'Playlisturile mele';

  @override
  String get menuEpgSettings => 'Setări EPG';

  @override
  String get menuNewlyAdded => 'Adăugate recent';

  @override
  String get menuContinueWatching => 'Continuă vizionarea';

  @override
  String get authSignInTitle => 'Autentificare';

  @override
  String get authSignUpTitle => 'Creează cont';

  @override
  String get authAccountTitle => 'Contul meu';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Parolă';

  @override
  String get authConfirmPasswordLabel => 'Confirmă parola';

  @override
  String get authSignInButton => 'Autentifică-te';

  @override
  String get authSignUpButton => 'Creează cont';

  @override
  String get authSignOutButton => 'Deconectează-te';

  @override
  String get authForgotPassword => 'Am uitat parola';

  @override
  String get authResetPasswordTitle => 'Resetează parola';

  @override
  String get authResetPasswordHint => 'Îți vom trimite un link de resetare pe e-mail.';

  @override
  String get authResetPasswordSent => 'Linkul de resetare a fost trimis. Verifică-ți e-mailul.';

  @override
  String get authNoAccountQuestion => 'Nu ai cont? Înregistrează-te';

  @override
  String get authHaveAccountQuestion => 'Am deja un cont';

  @override
  String get authOrDivider => 'sau';

  @override
  String get authSignInWithGoogle => 'Continuă cu Google';

  @override
  String get authSignInWithApple => 'Continuă cu Apple';

  @override
  String get authAcceptTerms => 'Accept Condițiile de utilizare și Politica de confidențialitate';

  @override
  String get authViewTerms => 'Vezi condițiile';

  @override
  String get authErrorInvalidEmail => 'Adresă de e-mail nevalidă';

  @override
  String get authErrorWeakPassword => 'Parola trebuie să aibă cel puțin 6 caractere';

  @override
  String get authErrorPasswordMismatch => 'Parolele nu coincid';

  @override
  String get authErrorEmailInUse => 'Acest e-mail este deja folosit';

  @override
  String get authErrorWrongPassword => 'E-mail sau parolă greșită';

  @override
  String get authErrorTooManyRequests => 'Prea multe încercări. Încearcă mai târziu.';

  @override
  String get authErrorNetwork => 'Eroare de rețea. Verifică-ți conexiunea.';

  @override
  String authErrorGeneric(String message) {
    return 'A apărut o problemă: $message';
  }

  @override
  String get authVerifyEmailHint => 'Am trimis un link de verificare pe e-mailul tău.';

  @override
  String get authAppleHiddenEmail => 'Utilizator Apple';

  @override
  String get authAppleHiddenEmailHint => 'E-mail păstrat privat prin Apple — nu este partajat';

  @override
  String get authResendVerification => 'Retrimite verificarea';

  @override
  String get authChangePassword => 'Schimbă parola';

  @override
  String get authDeleteAccount => 'Șterge contul';

  @override
  String get authDeleteAccountWarning => 'Ștergerea contului elimină definitiv toate datele tale din cloud. Această acțiune nu poate fi anulată.';

  @override
  String get authDeleteAccountConfirm => 'Da, șterge-mi contul';

  @override
  String get authAccountSection => 'Cont';

  @override
  String get authNotSignedIn => 'Neautentificat';

  @override
  String get authSignInPromptTitle => 'Creează cont → Încearcă Pro';

  @override
  String get authSignInPromptDesc => 'Înregistrează-te pentru a debloca playlisturi nelimitate, subtitrări AI și sincronizare între dispozitive.';

  @override
  String get authProActive => 'Membru Pro';

  @override
  String get authFreeTier => 'Plan gratuit';

  @override
  String get authUpgradeToPro => 'Treci la Pro';

  @override
  String get authRequiresRecentLogin => 'Această acțiune necesită o autentificare recentă. Autentifică-te din nou.';

  @override
  String get paywallTitle => 'Treci la Pro, elimină limitele';

  @override
  String get paywallSubtitle => 'Subtitrări AI, playlisturi nelimitate, sincronizare între dispozitive — toate într-o singură achiziție.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Playlisturi nelimitate';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker — fără limite';

  @override
  String get paywallBenefitAiSubtitles => 'Subtitrări AI';

  @override
  String get paywallBenefitAiSubtitlesDesc => 'Peste 100 de limbi (40 de ore/lună)';

  @override
  String get paywallBenefitCloudSync => 'Sincronizare în cloud';

  @override
  String get paywallBenefitCloudSyncDesc => 'Favorite și istoric pe toate dispozitivele';

  @override
  String get paywallBenefitTvApps => 'TV + telefon';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Lunar';

  @override
  String get paywallPlanYearly => 'Anual';

  @override
  String get paywallPlanLifetime => 'Pe viață';

  @override
  String get paywallBadgeBest => 'CEL MAI BUN';

  @override
  String get paywallBadgePopular => 'POPULAR';

  @override
  String get paywallSubscribeButton => 'Treci la Pro';

  @override
  String get paywallRestoreButton => 'Restaurează achizițiile';

  @override
  String get paywallSignInRequired => 'Autentifică-te pentru a continua.';

  @override
  String get paywallSignInButton => 'Autentifică-te mai întâi';

  @override
  String get paywallTermsFooter => 'Abonamentele se reînnoiesc automat. Le poți gestiona în Setări.';

  @override
  String get paywallPrivacyLink => 'Politica de confidențialitate';

  @override
  String get paywallTermsLink => 'Condiții de utilizare';

  @override
  String get paywallPurchaseSuccess => 'Pro activat. Vizionare plăcută!';

  @override
  String get paywallPurchaseCancelled => 'Achiziție anulată.';

  @override
  String paywallPurchaseError(String message) {
    return 'Achiziția a eșuat: $message';
  }

  @override
  String get paywallNotConfigured => 'Achizițiile nu sunt încă configurate. Încearcă mai târziu.';

  @override
  String get paywallNoOfferings => 'Nu există oferte disponibile.';

  @override
  String get paywallTriggerSecondPlaylist => 'Pro este necesar pentru o a doua playlist';

  @override
  String get paywallTriggerAiSubtitle => 'Pro este necesar pentru subtitrările AI';

  @override
  String get paywallTriggerCloudSync => 'Pro este necesar pentru sincronizarea în cloud';

  @override
  String get welcomeTitle => 'Bine ai venit';

  @override
  String get welcomeSubtitle => 'Filme, seriale și televiziune live nelimitate te așteaptă.';

  @override
  String get welcomeFeatureUnlimited => 'Canale și favorite nelimitate';

  @override
  String get welcomeFeatureSubtitles => 'Subtitrări inteligente (peste 100 de limbi)';

  @override
  String get welcomeFeatureSync => 'Sincronizare între dispozitive';

  @override
  String get welcomeStartFreeButton => 'Creează cont → Încearcă Pro';

  @override
  String get welcomeSkipButton => 'Omite deocamdată';

  @override
  String get welcomeSignInLink => 'Am deja un cont';

  @override
  String get watchlistTitle => 'Listă de urmărire';

  @override
  String get watchlistEmpty => 'Lista ta este goală';

  @override
  String get watchlistEmptyHint => 'Când salvezi un film sau un serial, apare aici.';

  @override
  String get themePickerTitle => 'Temă';

  @override
  String get themeDefaultDark => 'Întunecată implicită';

  @override
  String get themeDefaultLight => 'Luminoasă implicită';

  @override
  String get themeCrimson => 'Zori purpurii';

  @override
  String get themeRoyal => 'Violet regal';

  @override
  String get themeForest => 'Pădure adâncă';

  @override
  String get themeOcean => 'Albastru oceanic';

  @override
  String get parentalLockTitle => 'Control parental';

  @override
  String get parentalLockEnable => 'Activează controlul parental';

  @override
  String get parentalLockEnabledHint => 'Este necesar PIN-ul pentru categoriile blocate.';

  @override
  String get parentalLockSetupFirst => 'Creează mai întâi un PIN din 4 cifre.';

  @override
  String get parentalSetupPin => 'Creează PIN';

  @override
  String get parentalChangePin => 'Schimbă PIN-ul';

  @override
  String get parentalRemovePin => 'Elimină controlul parental';

  @override
  String get parentalLockedCategoriesTitle => 'Categorii de blocat';

  @override
  String get parentalNoCategories => 'Încă nu există categorii. Încarcă mai întâi o playlist.';

  @override
  String get parentalEnterPin => 'Introdu PIN-ul';

  @override
  String get parentalNewPin => 'PIN nou';

  @override
  String get parentalCurrentPin => 'PIN-ul actual';

  @override
  String get parentalConfirmPin => 'Confirmă PIN-ul';

  @override
  String get parentalPinIncorrect => 'PIN incorect';

  @override
  String get parentalPinFourDigits => 'PIN-ul trebuie să aibă 4 cifre';

  @override
  String get parentalPinMismatch => 'PIN-urile nu coincid';

  @override
  String get parentalPinChanged => 'PIN actualizat';

  @override
  String get parentalSubmit => 'OK';

  @override
  String get parentalNext => 'Următorul';

  @override
  String get cloudSyncTitle => 'Sincronizare în cloud';

  @override
  String get cloudSyncProRequired => 'Este necesar un abonament Pro';

  @override
  String get cloudSyncSignInRequired => 'Autentifică-te, apoi sincronizează';

  @override
  String get cloudSyncNever => 'Niciodată sincronizat';

  @override
  String get cloudSyncSyncNow => 'Sincronizează acum';

  @override
  String get cloudSyncJustNow => 'chiar acum';

  @override
  String cloudSyncMinutesAgo(int n) {
    return 'acum $n min';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return 'acum $n h';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return 'acum $n z';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Ultima sincronizare: $when';
  }

  @override
  String get epgGuideTitle => 'Ghid TV';

  @override
  String get epgToday => 'Azi';

  @override
  String get epgYesterday => 'Ieri';

  @override
  String get epgTomorrow => 'Mâine';

  @override
  String get epgRowEmpty => 'Nu există programe pentru acest canal';

  @override
  String get epgNoData => 'Nu există date EPG';

  @override
  String get epgNoDataHint => 'Mergi la Setări → EPG, setează un URL, apoi apasă „Actualizează acum”.';

  @override
  String epgError(String msg) {
    return 'Eroare EPG: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Actualizare automată';

  @override
  String get epgAutoRefreshOff => 'Oprită';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'La fiecare $h h';
  }

  @override
  String get playerPipTooltip => 'Imagine în imagine (Pro)';

  @override
  String get playerPipUnavailable => 'Acest dispozitiv nu acceptă imagine în imagine';

  @override
  String get playerPipEntered => 'Se redă într-o fereastră mică';

  @override
  String get playerAirplayTooltip => 'AirPlay (audio)';

  @override
  String get playerAirplayUnavailable => 'AirPlay nu este disponibil pe acest dispozitiv';

  @override
  String get playerAirplayAudioOnlyHint => 'AirPlay trimite sunetul către televizor. Pentru imagine folosește Centru de control > Oglindire ecran.';

  @override
  String get playerCastTooltip => 'Cast (în curând)';

  @override
  String get settingsPipSection => 'Imagine în imagine';

  @override
  String get settingsPipAuto => 'PiP automat la butonul Acasă';

  @override
  String get settingsPipAutoSubtitle => 'Pro — când playerul este deschis, apăsarea butonului Acasă mută redarea într-o fereastră mică';

  @override
  String get settingsAdsSection => 'Reclame';

  @override
  String get settingsAdsRemoved => 'Pro: fără reclame';

  @override
  String get settingsAdsFreeNotice => 'Versiunea gratuită afișează un banner în partea de jos. Abonează-te la Pro pentru o experiență fără reclame.';

  @override
  String get settingsProSection => 'Funcții Pro';

  @override
  String get settingsContentSection => 'Conținut';

  @override
  String get settingsPlayerSection => 'Player';

  @override
  String get settingsLegalNotice => 'Aviz legal';

  @override
  String get settingsDataDeletion => 'Cerere de ștergere a datelor';

  @override
  String get settingsDataDeletionSubtitle => 'Cerere de eliminare a contului și a datelor';

  @override
  String get settingsTapToSignIn => 'Autentifică-te sau creează un cont';

  @override
  String get commonHide => 'Ascunde';

  @override
  String get commonShow => 'Afișează';

  @override
  String get profileSwitcherTitle => 'Profiluri';

  @override
  String get profileDefaultName => 'Implicit';

  @override
  String get profileAdd => 'Profil nou';

  @override
  String get profileEdit => 'Editează profilul';

  @override
  String get profileDelete => 'Șterge profilul';

  @override
  String get profileDeleteConfirm => 'Acest profil și favoritele/lista de urmărire private ale acestuia vor fi șterse. Continui?';

  @override
  String get profileNameLabel => 'Numele profilului';

  @override
  String get profileEmptyName => 'Numele profilului nu poate fi gol';

  @override
  String get profileSwitched => 'Profil schimbat';

  @override
  String get profileMaxFreeReached => 'Versiunea gratuită acceptă 1 profil. Pro deblochează profiluri nelimitate.';

  @override
  String get profileSection => 'Profil';

  @override
  String get otherAppsTitle => 'Alte aplicații ale noastre';

  @override
  String get otherAppsSubtitle => 'Alte aplicații create de echipa noastră';

  @override
  String get otherAppsEmpty => 'Lista nu a putut fi încărcată. Verifică conexiunea la internet și încearcă din nou.';

  @override
  String get otherAppsRetry => 'Încearcă din nou';

  @override
  String get otherAppsOpenFailed => 'Magazinul nu a putut fi deschis.';

  @override
  String get otherAppsGateTitle => 'Verificare parentală';

  @override
  String get otherAppsGateQuestion => 'Pentru a continua, scrie rezultatul:';

  @override
  String get otherAppsCancel => 'Anulează';

  @override
  String get otherAppsContinue => 'Continuă';

  @override
  String get editPlaylistTitle => 'Editează playlist';

  @override
  String get editPlaylistNotFound => 'Playlist negăsită';

  @override
  String get editPlaylistXtreamBadge => 'Xtream Codes';

  @override
  String get editPlaylistM3uBadge => 'Playlist M3U';

  @override
  String get editPlaylistAddedAt => 'Adăugată la';

  @override
  String get editPlaylistExpiry => 'Expiră la';

  @override
  String get editPlaylistExpiredLabel => '⚠ Expirată';

  @override
  String get editPlaylistValidLabel => '✓ Validă';

  @override
  String get editPlaylistUrlLabel => 'URL server';

  @override
  String get editPlaylistRefreshButton => 'Actualizează canalele';

  @override
  String get editPlaylistDeleteButton => 'Șterge playlist';

  @override
  String get deletePlaylistDialogTitle => 'Șterge playlist';

  @override
  String get deletePlaylistDialogQuestion => 'Cum vrei să o ștergi?';

  @override
  String get deleteDeviceExplain => 'Se elimină doar de pe acest dispozitiv. Copia din cloud rămâne; o poți recupera oricând cu \"Descarcă din cloud\".';

  @override
  String get deleteDeviceExplainLocal => 'Se elimină de pe acest dispozitiv. Această listă nu este salvată în cloud, așa că va trebui să o adaugi din nou.';

  @override
  String get deletePlaylistFromCloud => 'Șterge din cloud';

  @override
  String get deletePlaylistFromDevice => 'Șterge de pe dispozitiv';

  @override
  String get deleteCloudExplain => 'Se șterge definitiv de pe acest dispozitiv și din cloud și nu va mai apărea nici pe celelalte dispozitive.';

  @override
  String get progressDownloadingList => 'Se descarcă lista de canale…';

  @override
  String progressRetrying(int attempt) {
    return 'Se reîncearcă ($attempt/3)…';
  }

  @override
  String get progressParsingList => 'Se procesează lista de canale…';

  @override
  String progressChannelsSaved(int count) {
    return '$count canale salvate…';
  }

  @override
  String get progressServerConnecting => 'Se conectează la server…';

  @override
  String get progressLoadingLive => 'Se încarcă canalele live…';

  @override
  String get progressLoadingMovies => 'Se încarcă filmele…';

  @override
  String get progressLoadingSeries => 'Se încarcă serialele…';

  @override
  String get loadErrM3uNotFound => 'Nu s-a găsit nicio listă de canale la această adresă. Asigură-te că adresa aparține unei liste M3U.';

  @override
  String loadErrIncomplete(int count, int total) {
    return 'Lista a sosit incompletă ($count / $total canale) — este posibil ca conexiunea să se fi întrerupt. Lista ta actuală a fost păstrată; încearcă din nou.';
  }

  @override
  String get loadErrServerEmpty => 'Serverul a trimis o listă goală. Asigură-te că abonamentul tău include canale; dacă problema persistă, contactează furnizorul.';

  @override
  String get loadErrSeriesInfo => 'Detaliile acestui serial nu au putut fi încărcate. Reîmprospătează lista și încearcă din nou.';

  @override
  String get loadErrNoEpisodes => 'Furnizorul nu a trimis episoade pentru acest serial.';

  @override
  String loadErrDrasticShrink(int count, int total) {
    return 'Serverul a trimis doar $count canale (anterior $total). Este posibil ca abonamentul să fi expirat; lista ta actuală a fost păstrată.';
  }

  @override
  String syncShrinkKept(String type) {
    return '$type: serverul a trimis mult mai puțin conținut decât înainte, așa că a fost păstrat conținutul existent.';
  }

  @override
  String get playlistSyncQueued => 'Modificările au fost salvate. Lista va fi descărcată din nou după ce se termină actualizarea în curs.';

  @override
  String get errorReportPreviewLabel => 'Textul care va fi trimis (datele de autentificare sunt ascunse):';

  @override
  String paywallPricePerMonths(String price, int months) {
    return '$price / $months luni';
  }

  @override
  String paywallPlanMonths(int months) {
    return '$months luni';
  }

  @override
  String paywallIntroPriceThen(String intro, String price) {
    return '$intro preț introductiv, apoi $price';
  }

  @override
  String get watchlistClearAll => 'Golește lista';

  @override
  String get watchlistClearConfirm => 'Elimini toate elementele?';

  @override
  String get categoryFilterPlaylist => 'Playlist';

  @override
  String get settingsRefreshOff => 'Oprit';

  @override
  String get settingsRefreshOnOpen => 'La fiecare pornire';

  @override
  String get settingsRefresh1Day => 'Zilnic';

  @override
  String get settingsRefresh1Week => 'Săptămânal';

  @override
  String get settingsRefresh1Month => 'Lunar';

  @override
  String get settingsRefresh1Year => 'Anual';

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
    return 'Următorul: $title';
  }

  @override
  String get xtreamBadLogin => 'Numele de utilizator sau parola sunt greșite. Verifică datele la furnizor și încearcă din nou.';

  @override
  String get xtreamExpired => 'Abonamentul tău a expirat. Contactează furnizorul pentru a-l reînnoi.';

  @override
  String xtreamExpiredOn(String date) {
    return 'Abonamentul tău a expirat pe $date. Contactează furnizorul pentru a-l reînnoi.';
  }

  @override
  String get xtreamDisabled => 'Contul tău a fost dezactivat de furnizor. Contactează furnizorul.';

  @override
  String get epgAutoRefreshAuto => 'Automat — se actualizează când ghidul este pe terminate';

  @override
  String xtreamPartialLoad(String type) {
    return 'Unele conținuturi nu au putut fi încărcate: $type';
  }

  @override
  String get settingsPlaylistAutoRefreshTitle => 'Actualizare automată playlist';

  @override
  String settingsEpgUrlForPlaylist(String name) {
    return 'Pentru playlistul activ: $name';
  }

  @override
  String get settingsClearHistoryDone => 'Istoricul vizionărilor a fost șters';

  @override
  String get settingsSupportSection => 'Asistență';

  @override
  String get settingsFeedbackTitle => 'Trimite feedback';

  @override
  String get settingsFeedbackSubtitle => 'Sugestii, raportări de erori sau opinii generale';

  @override
  String get feedbackDialogTitle => 'Feedback';

  @override
  String get feedbackThanks => 'Mulțumim!';

  @override
  String get feedbackReceived => 'Feedbackul tău a fost primit.';

  @override
  String get feedbackChooseType => 'Selectează tipul:';

  @override
  String get feedbackTypeSuggestion => 'Sugestie';

  @override
  String get feedbackTypeBug => 'Raportare eroare';

  @override
  String get feedbackTypeGeneral => 'General';

  @override
  String get feedbackNameLabel => 'Nume';

  @override
  String get feedbackNamePlaceholder => 'Opțional';

  @override
  String get feedbackEmailLabel => 'Email *';

  @override
  String get feedbackEmailPlaceholder => 'exemplu@mail.com';

  @override
  String get feedbackEmailInvalid => 'Introdu o adresă de email validă';

  @override
  String get feedbackMessageLabel => 'Mesajul tău *';

  @override
  String get feedbackMessagePlaceholder => 'Spune-ne ce crezi…';

  @override
  String get feedbackScreenshotLabel => 'Capturi de ecran (max 3)';

  @override
  String get feedbackAddImage => 'Adaugă imagine';

  @override
  String feedbackError(String details) {
    return 'Nu s-a putut trimite: $details';
  }

  @override
  String get feedbackImageTooLarge => 'Imaginile mai mari de 5 MB nu pot fi atașate';

  @override
  String get commonSend => 'Trimite';

  @override
  String get commonSending => 'Se trimite…';

  @override
  String get settingsRateApp => 'Evaluează aplicația';

  @override
  String get settingsRateAppSubtitle => 'Evaluează și scrie o recenzie în App Store';

  @override
  String paywallBenefitPlaylistsUpTo(int count) {
    return 'Până la $count playlisturi';
  }

  @override
  String get paywallBenefitAiWhisper => 'Subtitrări AI Whisper';

  @override
  String get paywallBenefitCloudSyncDevices => 'Sincronizare cloud (multi-dispozitiv)';

  @override
  String get paywallBenefitThemes => 'Teme premium';

  @override
  String get paywallBenefitWatchlist => 'Listă de vizionat';

  @override
  String get paywallBenefitEpgAuto => 'Actualizare automată EPG';

  @override
  String paywallPricePerYear(String price) {
    return '$price / an';
  }

  @override
  String paywallPricePerMonth(String price) {
    return '$price / lună';
  }

  @override
  String paywallPricePerWeek(String price) {
    return '$price / săptămână';
  }

  @override
  String paywallPriceOneTime(String price) {
    return '$price o singură dată';
  }

  @override
  String paywallMonthlyEquivalent(String price) {
    return 'Doar $price / lună';
  }

  @override
  String paywallTrialThen(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Primele $days de zile gratuit',
      few: 'Primele $days zile gratuit',
      one: 'Prima zi gratuită',
    );
    return '$_temp0, apoi $price. Anulezi oricând.';
  }

  @override
  String get paywallLifetimeHint => '✦ Plată unică · Acces pe viață';

  @override
  String get paywallPurchase => 'Cumpără';

  @override
  String get paywallTermsFooterApple => 'Plata se debitează din ID-ul Apple la confirmarea achiziției. Abonamentele se reînnoiesc automat dacă nu sunt anulate cu cel puțin 24 de ore înainte de sfârșitul perioadei curente. Le poți gestiona sau anula din setările contului App Store.';

  @override
  String get paywallActivationPending => 'Achiziția a reușit, dar Pro nu este încă activ. Încearcă să restabilești achizițiile; dacă problema persistă, contactează asistența.';

  @override
  String get paywallLoadError => 'Planurile nu au putut fi încărcate. Verifică conexiunea și încearcă din nou.';

  @override
  String playlistDeviceLimit(int count) {
    return 'Acest dispozitiv acceptă cel mult $count liste.';
  }

  @override
  String get authReauthTitle => 'Confirmă că ești tu';

  @override
  String get authReauthPasswordMessage => 'Introdu parola pentru a-ți șterge contul.';

  @override
  String get authAccountDeleted => 'Contul tău a fost șters.';

  @override
  String get playerUrlMissing => 'URL-ul fluxului nu a fost găsit';

  @override
  String parentalPinWrongAttempts(int remaining) {
    return 'PIN greșit. Încercări rămase: $remaining.';
  }

  @override
  String parentalPinCooldown(int seconds) {
    return 'Prea multe încercări greșite. Așteaptă $seconds secunde.';
  }

  @override
  String get paywallRestoreNothing => 'Nu au fost găsite achiziții anterioare pentru acest ID Apple.';
}
