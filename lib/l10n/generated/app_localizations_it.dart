// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get close => 'Chiudi';

  @override
  String get back => 'Indietro';

  @override
  String get retry => 'Riprova';

  @override
  String get loading => 'Caricamento…';

  @override
  String get error => 'Errore';

  @override
  String get errorGeneric => 'Si è verificato un problema. Riprova.';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get languageItalian => 'Italiano';

  @override
  String errorWithDetails(String details) {
    return 'Errore: $details';
  }

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String get commonRefresh => 'Aggiorna';

  @override
  String get commonDeleteConfirm => 'Elimina';

  @override
  String get errorTimeoutProvider => 'Il provider non ha risposto. Riprova più tardi.';

  @override
  String get errorNoConnection => 'Nessuna connessione a Internet o provider irraggiungibile.';

  @override
  String get errorDatabaseTemporary => 'Il database è temporaneamente non disponibile. Riprova.';

  @override
  String get errorGenericRetry => 'Si è verificato un problema. Riprova.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSaved => 'Impostazioni salvate';

  @override
  String get settingsAppearanceSection => 'Aspetto';

  @override
  String get settingsThemeDark => 'Tema scuro';

  @override
  String get settingsThemeLight => 'Tema chiaro';

  @override
  String get settingsThemeSystem => 'Tema di sistema';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'URL EPG (.xml o .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'Aggiorna EPG ora';

  @override
  String get settingsSelectPlaylistFirst => 'Seleziona prima una playlist';

  @override
  String get settingsEpgUpdated => 'EPG aggiornato correttamente';

  @override
  String settingsEpgError(String details) {
    return 'Errore EPG: $details';
  }

  @override
  String get settingsSubtitleSection => 'Sottotitoli';

  @override
  String get settingsSubtitleFontSize => 'Dimensione carattere';

  @override
  String get subtitleSizeSmall => 'Piccolo';

  @override
  String get subtitleSizeNormal => 'Normale';

  @override
  String get subtitleSizeLarge => 'Grande';

  @override
  String get subtitleSizeExtraLarge => 'Molto grande';

  @override
  String get settingsSubtitleTextColor => 'Colore testo';

  @override
  String get subtitleColorWhite => 'Bianco';

  @override
  String get subtitleColorYellow => 'Giallo';

  @override
  String get subtitleColorGreen => 'Verde';

  @override
  String get subtitleColorCyan => 'Ciano';

  @override
  String get settingsSubtitleBgColor => 'Sfondo';

  @override
  String get subtitleBgSemi => 'Semitrasparente';

  @override
  String get subtitleBgOpaque => 'Nero';

  @override
  String get subtitleBgNone => 'Nessuno';

  @override
  String get settingsAboutSection => 'Informazioni';

  @override
  String settingsAppVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsPlaylistManagement => 'Gestione playlist';

  @override
  String get settingsCategoryFilterSubtitle => 'Nascondi/mostra categorie';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Aggiungi una playlist per iniziare';

  @override
  String get homeAddPlaylist => 'Aggiungi playlist';

  @override
  String get homeSearchHint => 'Cerca canali, film, serie…';

  @override
  String get homePlaylistsTooltip => 'Playlist';

  @override
  String get homeMore => 'Altro';

  @override
  String get homeCategoryManagement => 'Gestione categorie';

  @override
  String get homeTabHome => 'Home';

  @override
  String get homeTabLive => 'Live';

  @override
  String get homeTabMovie => 'Film';

  @override
  String get homeTabSeries => 'Serie';

  @override
  String get homeTabFavorites => 'Preferiti';

  @override
  String get homeFavoritesAll => 'Tutti';

  @override
  String get homeFavoritesLive => 'Live';

  @override
  String get homeFavoritesMovie => 'Film';

  @override
  String get homeFavoritesSeries => 'Serie';

  @override
  String get homeEmptyFavorites => 'Ancora nessun preferito';

  @override
  String get homeEmptyFavoritesType => 'Nessun preferito di questo tipo';

  @override
  String get homeEmptyCategory => 'Nessun contenuto in questa categoria';

  @override
  String get homeRowContinueWatching => 'Continua a guardare';

  @override
  String get homeRowRecentlyWatched => 'Guardati di recente';

  @override
  String get homeRowNewMovies => 'Nuovi film';

  @override
  String get homeRowNewSeries => 'Nuove serie';

  @override
  String get homeRowNewChannels => 'Nuovi canali';

  @override
  String get homeEmptyContent => 'Ancora nessun contenuto';

  @override
  String get homeEmptyContentHint => 'Sfoglia le schede Film / Serie / Live per iniziare';

  @override
  String get homeRecentlyWatchedHeader => 'GUARDATI DI RECENTE';

  @override
  String get homeSearchEmpty => 'Inizia a digitare per cercare';

  @override
  String homeSearchNoResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String homeContentCount(int count) {
    return '$count elemento/i';
  }

  @override
  String get sortDialogTitle => 'Ordina';

  @override
  String get sortLabelDefault => 'Predefinito';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Ordina';

  @override
  String get playlistsTitle => 'Playlist';

  @override
  String get playlistsEmpty => 'Ancora nessuna playlist';

  @override
  String get playlistsRefreshTooltip => 'Aggiorna';

  @override
  String get playlistsDeleteTooltip => 'Elimina';

  @override
  String get playlistsRetryAction => 'RIPROVA';

  @override
  String get playlistsUpdated => 'Playlist aggiornata.';

  @override
  String get playlistsDeleteTitle => 'Elimina playlist';

  @override
  String playlistsDeleteConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get playlistsAddTitle => 'Aggiungi playlist';

  @override
  String get playlistsTypeM3u => 'URL M3U';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsNameLabel => 'Nome playlist';

  @override
  String get playlistsM3uUrlLabel => 'URL M3U';

  @override
  String get playlistsM3uUrlHint => 'http://… o https://…';

  @override
  String get playlistsPasteFromClipboard => 'Incolla dagli appunti';

  @override
  String get playlistsClipboardEmpty => 'Gli appunti sono vuoti';

  @override
  String get playlistsServerUrlLabel => 'URL server';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'Nome utente';

  @override
  String get playlistsPasswordLabel => 'Password';

  @override
  String get playlistsContentTypes => 'Tipi di contenuto';

  @override
  String get playlistsContentLive => 'Live';

  @override
  String get playlistsContentMovie => 'Film';

  @override
  String get playlistsContentSeries => 'Serie';

  @override
  String get playlistsValidationNameUrl => 'Nome e URL sono obbligatori';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream richiede nome utente e password';

  @override
  String get playlistsErrorTlsHandshake => 'Impossibile stabilire una connessione sicura (errore TLS). Prova con http:// o verifica l\'indirizzo del provider.';

  @override
  String get playlistsErrorTimeout => 'Il provider non ha risposto (timeout). Riprova più tardi.';

  @override
  String get playlistsErrorConnection => 'Nessuna connessione a Internet o provider irraggiungibile.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'Impossibile aggiornare la playlist: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'Il provider ha restituito una playlist vuota. Dati precedenti mantenuti.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Riconnessione ($attempt)…';
  }

  @override
  String get playerReconnecting => 'Riconnessione…';

  @override
  String get playerLoading => 'Caricamento…';

  @override
  String get playerStreamRepeatedError => 'Lo stream continua a disconnettersi. Prova un altro canale.';

  @override
  String get playerReconnectTooltip => 'Riconnetti';

  @override
  String get playerSubtitleEnable => 'Attiva sottotitoli AI';

  @override
  String get playerSubtitleDisable => 'Disattiva sottotitoli AI';

  @override
  String get playerMuteTooltip => 'Disattiva audio';

  @override
  String get playerUnmuteTooltip => 'Riattiva audio';

  @override
  String get playerLiveLabel => 'LIVE';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Traccia audio';

  @override
  String get playerAudioTrackDialog => 'Traccia audio';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Traccia $n';
  }

  @override
  String get playerSpeedDialog => 'Velocità di riproduzione';

  @override
  String get playerSubtitleDialogTitle => 'Sottotitoli';

  @override
  String get playerSubtitleAi => 'Sottotitoli AI';

  @override
  String get playerSubtitleAiActive => '(Attivo)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Incorporati $n';
  }

  @override
  String get playerSubtitleOff => 'Disattivati';

  @override
  String get playerScreenSizeTooltip => 'Dimensione schermo';

  @override
  String get playerScreenSizeDialog => 'Dimensione schermo';

  @override
  String get playerFitOriginal => 'Originale';

  @override
  String get playerFitCover => 'Riempi schermo (ritaglia)';

  @override
  String get playerFitStretch => 'Allunga';

  @override
  String get playerResolutionTooltip => 'Risoluzione';

  @override
  String get playerResolutionDialog => 'Risoluzione';

  @override
  String get playerResolutionAuto => 'Automatica';

  @override
  String get playerSingleQuality => 'Questo stream offre una sola qualità.';

  @override
  String get disclaimerWelcome => 'Benvenuto';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player è un lettore multimediale per le tue playlist M3U e le sorgenti Xtream Codes.\n\nQuesta app non fornisce, ospita o distribuisce alcun contenuto. Devi fornire personalmente l\'URL di una playlist ottenuta legalmente.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player è un lettore multimediale per le tue playlist M3U e le sorgenti Xtream Codes. L\'app non ospita né distribuisce alcun contenuto.';

  @override
  String get disclaimerLegalNoticeButton => 'Avviso legale';

  @override
  String get disclaimerContinue => 'Continua';

  @override
  String get disclaimerFooter => 'Continuando accetti l\'Avviso legale.';

  @override
  String get legalNoticeTitle => 'Avviso legale';

  @override
  String get legalSection1Title => '1. Natura dell\'app';

  @override
  String get legalSection1En => 'IPTV AI Player è un lettore multimediale di uso generale (simile a VLC o MX Player). NON fornisce, ospita, distribuisce o reindirizza a trasmissioni TV, film, serie, eventi sportivi o altri contenuti. L\'app è uno strumento che riproduce URL di playlist M3U / M3U8 o credenziali Xtream Codes fornite dall\'utente.';

  @override
  String get legalSection1Tr => 'IPTV AI Player è un lettore multimediale di uso generale. Non fornisce, ospita o distribuisce alcun contenuto; riproduce soltanto gli URL delle playlist o le credenziali Xtream fornite dall\'utente.';

  @override
  String get legalSection2Title => '2. Responsabilità sui contenuti';

  @override
  String get legalSection2En => 'L\'utente è l\'unico responsabile di tutti i contenuti consultati tramite l\'app. Lo sviluppatore non è a conoscenza dei contenuti consultati tramite l\'app e non ne assume alcuna responsabilità.';

  @override
  String get legalSection2Tr => 'L\'utente è l\'unico responsabile di qualsiasi contenuto consultato tramite l\'app. Lo sviluppatore non ha visibilità su tali contenuti e non se ne assume alcuna responsabilità.';

  @override
  String get legalSection3Title => '3. Quadro giuridico turco';

  @override
  String get legalSection3Item1 => 'Articoli 71-72 della Legge n. 5846 (FSEK, Turchia): la violazione del diritto d\'autore comporta sanzioni civili e penali.';

  @override
  String get legalSection3Item2 => 'Articolo 163/2 del Codice penale turco: uso non autorizzato di trasmissioni criptate/non criptate.';

  @override
  String get legalSection3Item3 => 'Articolo aggiuntivo 4 della FSEK: violazione del diritto d\'autore su Internet.';

  @override
  String get legalSection3Item4 => 'RTÜK e BTK possono imporre divieti di accesso ai sensi delle Leggi n. 6112 e 5651.';

  @override
  String get legalSection4Title => '4. Obblighi dell\'utente';

  @override
  String get legalSection4Body => 'Utilizzando questa app riconosci che accederai solo ai contenuti a cui sei legalmente abbonato, che non accederai a contenuti protetti da diritto d\'autore senza autorizzazione e che non utilizzerai l\'app per trasmissioni pirata o servizi IPTV non autorizzati.';

  @override
  String get legalSection5Title => '5. Protezione dei dati';

  @override
  String get legalSection5Body => 'L\'app memorizza gli URL delle tue playlist e le credenziali solo localmente sul tuo dispositivo. Non vengono condivisi con terze parti.';

  @override
  String get legalSection6Title => '6. Limitazione di responsabilità';

  @override
  String get legalSection6Body => 'L\'app è fornita \"COSÌ COM\'È\". Lo sviluppatore non è responsabile per eventuali danni derivanti dall\'uso dell\'app.';

  @override
  String get legalSection7Title => '7. Cooperazione legale';

  @override
  String get legalSection7Body => 'Lo sviluppatore ottempera alle richieste legittime delle autorità competenti (RTÜK, BTK, procure).';

  @override
  String get legalReminder => 'Promemoria: utilizzare questa app per accedere a contenuti non autorizzati o protetti da diritto d\'autore è illegale. L\'utente è pienamente responsabile sotto il profilo legale.';

  @override
  String get searchHint => 'Cerca canali, film, serie…';

  @override
  String get searchMinChars => 'Inserisci almeno 2 caratteri';

  @override
  String searchNoResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get categoryFilterTitle => 'Filtro categorie';

  @override
  String get categoryFilterShowAll => 'Mostra tutto';

  @override
  String get categoryFilterHideAll => 'Nascondi tutto';

  @override
  String get categoryFilterEmpty => 'Ancora nessuna categoria';

  @override
  String get categoryFilterSectionLive => 'Live';

  @override
  String get categoryFilterSectionMovie => 'Film';

  @override
  String get categoryFilterSectionSeries => 'Serie';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total attive)';
  }

  @override
  String get seriesEmptyCategory => 'Nessuna serie in questa categoria';

  @override
  String seriesSeasonCount(int count) {
    return '$count stagione/i';
  }

  @override
  String get seriesSpecialSeason => 'Speciali';

  @override
  String seriesSeasonNumber(int n) {
    return 'Stagione $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count episodi';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'Rimuovi dalla cronologia';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name verrà rimosso dalla cronologia di visione. Continuare?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Rimuovi';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name rimosso dalla cronologia di visione';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name aggiunto ai preferiti';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name rimosso dai preferiti';
  }

  @override
  String get homeRowPopular => 'Popolari';

  @override
  String get homeRowWatchedMovies => 'Film che hai guardato';

  @override
  String get homeRowWatchedSeries => 'Serie che hai guardato';

  @override
  String get badgeMovieUppercase => 'FILM';

  @override
  String get badgeSeriesUppercase => 'SERIE';

  @override
  String get settingsEpgPresetsTitle => 'Preimpostazioni';

  @override
  String get menuMyPlaylists => 'Le mie playlist';

  @override
  String get menuEpgSettings => 'Impostazioni EPG';

  @override
  String get menuNewlyAdded => 'Aggiunti di recente';

  @override
  String get menuContinueWatching => 'Continua a guardare';

  @override
  String get authSignInTitle => 'Accedi';

  @override
  String get authSignUpTitle => 'Crea account';

  @override
  String get authAccountTitle => 'Il mio account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Conferma password';

  @override
  String get authSignInButton => 'Accedi';

  @override
  String get authSignUpButton => 'Crea account';

  @override
  String get authSignOutButton => 'Esci';

  @override
  String get authForgotPassword => 'Password dimenticata';

  @override
  String get authResetPasswordTitle => 'Reimposta password';

  @override
  String get authResetPasswordHint => 'Ti invieremo un link per il reset alla tua email.';

  @override
  String get authResetPasswordSent => 'Link per il reset inviato. Controlla la tua casella di posta.';

  @override
  String get authNoAccountQuestion => 'Nessun account? Registrati';

  @override
  String get authHaveAccountQuestion => 'Ho già un account';

  @override
  String get authOrDivider => 'oppure';

  @override
  String get authSignInWithGoogle => 'Continua con Google';

  @override
  String get authSignInWithApple => 'Continua con Apple';

  @override
  String get authAcceptTerms => 'Accetto i Termini di utilizzo e l\'Informativa sulla privacy';

  @override
  String get authViewTerms => 'Visualizza i termini';

  @override
  String get authErrorInvalidEmail => 'Indirizzo email non valido';

  @override
  String get authErrorWeakPassword => 'La password deve contenere almeno 6 caratteri';

  @override
  String get authErrorPasswordMismatch => 'Le password non coincidono';

  @override
  String get authErrorEmailInUse => 'Questa email è già in uso';

  @override
  String get authErrorWrongPassword => 'Email o password errati';

  @override
  String get authErrorTooManyRequests => 'Troppi tentativi. Riprova più tardi.';

  @override
  String get authErrorNetwork => 'Errore di rete. Controlla la connessione.';

  @override
  String authErrorGeneric(String message) {
    return 'Si è verificato un problema: $message';
  }

  @override
  String get authVerifyEmailHint => 'Abbiamo inviato un link di verifica alla tua email.';

  @override
  String get authAppleHiddenEmail => 'Utente Apple';

  @override
  String get authAppleHiddenEmailHint => 'Email mantenuta privata tramite Apple — non condivisa';

  @override
  String get authResendVerification => 'Reinvia verifica';

  @override
  String get authChangePassword => 'Cambia password';

  @override
  String get authDeleteAccount => 'Elimina account';

  @override
  String get authDeleteAccountWarning => 'L\'eliminazione dell\'account rimuove definitivamente tutti i tuoi dati nel cloud. L\'operazione non può essere annullata.';

  @override
  String get authDeleteAccountConfirm => 'Sì, elimina il mio account';

  @override
  String get authAccountSection => 'Account';

  @override
  String get authNotSignedIn => 'Non hai effettuato l\'accesso';

  @override
  String get authSignInPromptTitle => 'Crea account → Prova Pro';

  @override
  String get authSignInPromptDesc => 'Registrati per sbloccare playlist illimitate, sottotitoli AI e sincronizzazione tra dispositivi.';

  @override
  String get authProActive => 'Membro Pro';

  @override
  String get authFreeTier => 'Piano gratuito';

  @override
  String get authUpgradeToPro => 'Passa a Pro';

  @override
  String get authRequiresRecentLogin => 'Questa azione richiede un accesso recente. Effettua di nuovo l\'accesso.';

  @override
  String get paywallTitle => 'Passa a Pro, elimina i limiti';

  @override
  String get paywallSubtitle => 'Sottotitoli AI, playlist illimitate, sincronizzazione tra dispositivi — tutto in un unico acquisto.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Playlist illimitate';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker — nessun limite';

  @override
  String get paywallBenefitAiSubtitles => 'Sottotitoli AI';

  @override
  String get paywallBenefitAiSubtitlesDesc => 'Oltre 100 lingue (40 ore/mese)';

  @override
  String get paywallBenefitCloudSync => 'Sincronizzazione cloud';

  @override
  String get paywallBenefitCloudSyncDesc => 'Preferiti e cronologia su tutti i dispositivi';

  @override
  String get paywallBenefitTvApps => 'TV + Telefono';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Mensile';

  @override
  String get paywallPlanYearly => 'Annuale';

  @override
  String get paywallPlanLifetime => 'A vita';

  @override
  String get paywallBadgeBest => 'MIGLIORE';

  @override
  String get paywallBadgePopular => 'POPOLARE';

  @override
  String get paywallSubscribeButton => 'Passa a Pro';

  @override
  String get paywallRestoreButton => 'Ripristina acquisti';

  @override
  String get paywallSignInRequired => 'Accedi per continuare.';

  @override
  String get paywallSignInButton => 'Accedi prima';

  @override
  String get paywallTermsFooter => 'Gli abbonamenti si rinnovano automaticamente. Gestiscili in Impostazioni.';

  @override
  String get paywallPrivacyLink => 'Informativa sulla privacy';

  @override
  String get paywallTermsLink => 'Termini di utilizzo';

  @override
  String get paywallPurchaseSuccess => 'Pro attivato. Buon divertimento!';

  @override
  String get paywallPurchaseCancelled => 'Acquisto annullato.';

  @override
  String paywallPurchaseError(String message) {
    return 'Acquisto non riuscito: $message';
  }

  @override
  String get paywallNotConfigured => 'Gli acquisti non sono ancora configurati. Riprova più tardi.';

  @override
  String get paywallNoOfferings => 'Nessuna offerta disponibile.';

  @override
  String get paywallTriggerSecondPlaylist => 'Pro necessario per una seconda playlist';

  @override
  String get paywallTriggerAiSubtitle => 'Pro necessario per i sottotitoli AI';

  @override
  String get paywallTriggerCloudSync => 'Pro necessario per la sincronizzazione cloud';

  @override
  String get welcomeTitle => 'Benvenuto';

  @override
  String get welcomeSubtitle => 'Film, serie e TV in diretta illimitati ti aspettano.';

  @override
  String get welcomeFeatureUnlimited => 'Canali e preferiti illimitati';

  @override
  String get welcomeFeatureSubtitles => 'Sottotitoli intelligenti (oltre 100 lingue)';

  @override
  String get welcomeFeatureSync => 'Sincronizzazione tra dispositivi';

  @override
  String get welcomeStartFreeButton => 'Crea account → Prova Pro';

  @override
  String get welcomeSkipButton => 'Salta per ora';

  @override
  String get welcomeSignInLink => 'Ho già un account';

  @override
  String get watchlistTitle => 'Da guardare';

  @override
  String get watchlistEmpty => 'La tua lista è vuota';

  @override
  String get watchlistEmptyHint => 'Quando aggiungi un film o una serie ai segnalibri, appare qui.';

  @override
  String get themePickerTitle => 'Tema';

  @override
  String get themeDefaultDark => 'Scuro predefinito';

  @override
  String get themeDefaultLight => 'Chiaro predefinito';

  @override
  String get themeCrimson => 'Alba cremisi';

  @override
  String get themeRoyal => 'Viola reale';

  @override
  String get themeForest => 'Foresta profonda';

  @override
  String get themeOcean => 'Blu oceano';

  @override
  String get parentalLockTitle => 'Blocco minori';

  @override
  String get parentalLockEnable => 'Attiva blocco minori';

  @override
  String get parentalLockEnabledHint => 'PIN richiesto per le categorie bloccate.';

  @override
  String get parentalLockSetupFirst => 'Crea prima un PIN di 4 cifre.';

  @override
  String get parentalSetupPin => 'Crea PIN';

  @override
  String get parentalChangePin => 'Cambia PIN';

  @override
  String get parentalRemovePin => 'Rimuovi blocco minori';

  @override
  String get parentalLockedCategoriesTitle => 'Categorie da bloccare';

  @override
  String get parentalNoCategories => 'Ancora nessuna categoria. Carica prima una playlist.';

  @override
  String get parentalEnterPin => 'Inserisci PIN';

  @override
  String get parentalNewPin => 'Nuovo PIN';

  @override
  String get parentalCurrentPin => 'PIN attuale';

  @override
  String get parentalConfirmPin => 'Conferma PIN';

  @override
  String get parentalPinIncorrect => 'PIN errato';

  @override
  String get parentalPinFourDigits => 'Il PIN deve essere di 4 cifre';

  @override
  String get parentalPinMismatch => 'I PIN non coincidono';

  @override
  String get parentalPinChanged => 'PIN aggiornato';

  @override
  String get parentalSubmit => 'OK';

  @override
  String get parentalNext => 'Avanti';

  @override
  String get cloudSyncTitle => 'Sincronizzazione cloud';

  @override
  String get cloudSyncProRequired => 'Abbonamento Pro richiesto';

  @override
  String get cloudSyncSignInRequired => 'Accedi, poi sincronizza';

  @override
  String get cloudSyncNever => 'Mai sincronizzato';

  @override
  String get cloudSyncSyncNow => 'Sincronizza ora';

  @override
  String get cloudSyncJustNow => 'proprio ora';

  @override
  String cloudSyncMinutesAgo(int n) {
    return '$n min fa';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return '$n h fa';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return '$n g fa';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Ultima sincronizzazione: $when';
  }

  @override
  String get epgGuideTitle => 'Guida TV';

  @override
  String get epgToday => 'Oggi';

  @override
  String get epgYesterday => 'Ieri';

  @override
  String get epgTomorrow => 'Domani';

  @override
  String get epgRowEmpty => 'Nessun programma per questo canale';

  @override
  String get epgNoData => 'Nessun dato EPG';

  @override
  String get epgNoDataHint => 'Vai in Impostazioni → EPG, imposta un URL, poi tocca \'Aggiorna ora\'.';

  @override
  String epgError(String msg) {
    return 'Errore EPG: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Aggiornamento automatico';

  @override
  String get epgAutoRefreshOff => 'Disattivato';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'Ogni $h h';
  }

  @override
  String get playerPipTooltip => 'Picture-in-Picture (Pro)';

  @override
  String get playerPipUnavailable => 'PiP non supportato su questo dispositivo';

  @override
  String get playerPipEntered => 'Riproduzione in finestra mini';

  @override
  String get playerAirplayTooltip => 'AirPlay (Pro)';

  @override
  String get playerAirplayUnavailable => 'AirPlay è disponibile solo su iOS';

  @override
  String get playerCastTooltip => 'Cast (in arrivo)';

  @override
  String get settingsPipSection => 'Picture-in-Picture';

  @override
  String get settingsPipAuto => 'PiP automatico col tasto Home';

  @override
  String get settingsPipAutoSubtitle => 'Pro — Quando il player è aperto, premendo Home la riproduzione passa a una finestra mini';

  @override
  String get settingsAdsSection => 'Annunci';

  @override
  String get settingsAdsRemoved => 'Pro: nessun annuncio';

  @override
  String get settingsAdsFreeNotice => 'La versione gratuita mostra un banner in basso. Abbonati a Pro per un\'esperienza senza pubblicità.';

  @override
  String get settingsProSection => 'Funzioni Pro';

  @override
  String get settingsContentSection => 'Contenuti';

  @override
  String get settingsPlayerSection => 'Player';

  @override
  String get settingsLegalNotice => 'Avviso legale';

  @override
  String get settingsDataDeletion => 'Richiesta di eliminazione dati';

  @override
  String get settingsDataDeletionSubtitle => 'Richiesta di rimozione account e dati';

  @override
  String get settingsTapToSignIn => 'Accedi o crea un account';

  @override
  String get commonHide => 'Nascondi';

  @override
  String get commonShow => 'Mostra';

  @override
  String get profileSwitcherTitle => 'Profili';

  @override
  String get profileDefaultName => 'Predefinito';

  @override
  String get profileAdd => 'Nuovo profilo';

  @override
  String get profileEdit => 'Modifica profilo';

  @override
  String get profileDelete => 'Elimina profilo';

  @override
  String get profileDeleteConfirm => 'Questo profilo e i relativi preferiti/lista da guardare privati verranno eliminati. Continuare?';

  @override
  String get profileNameLabel => 'Nome profilo';

  @override
  String get profileEmptyName => 'Il nome del profilo non può essere vuoto';

  @override
  String get profileSwitched => 'Profilo cambiato';

  @override
  String get profileMaxFreeReached => 'La versione gratuita supporta 1 profilo. Pro sblocca profili illimitati.';

  @override
  String get profileSection => 'Profilo';
}
