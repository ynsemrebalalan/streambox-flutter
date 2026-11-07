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
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageRomanian => 'Rumeno';

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
  String get homePlaylistSyncing => 'Sincronizzazione playlist…';

  @override
  String get homeSearchTooltip => 'Cerca';

  @override
  String get watchlistAddTooltip => 'Aggiungi a La mia lista';

  @override
  String get watchlistRemoveTooltip => 'Rimuovi da La mia lista';

  @override
  String get playerPlayAction => 'Riproduci';

  @override
  String get playerPauseAction => 'Pausa';

  @override
  String get playlistsActiveLabel => 'Attiva';

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
  String get playlistsTypeStalker => 'Stalker / MAG';

  @override
  String get playlistsStalkerCardTitle => 'Portale Stalker / MAG Box';

  @override
  String get playlistsStalkerCardBody => 'Il tuo indirizzo MAC deve essere registrato presso il tuo fornitore IPTV. L\'app prova prima il percorso M3U veloce, poi ripiega sul protocollo Stalker completo se necessario.';

  @override
  String get playlistsStalkerPortalLabel => 'URL portale';

  @override
  String get playlistsStalkerPortalHint => 'http://provider.com:8080';

  @override
  String get playlistsStalkerMacLabel => 'Indirizzo MAC';

  @override
  String get playlistsStalkerMacHint => '00:1A:79:XX:XX:XX';

  @override
  String get playlistsStalkerMacGenerate => 'Genera';

  @override
  String get playlistsStalkerMacHelp => 'Formato MAC: XX:XX:XX:XX:XX:XX (maiuscolo, separato da due punti)';

  @override
  String get playlistsValidationStalkerMac => 'Inserisci un indirizzo MAC valido (XX:XX:XX:XX:XX:XX).';

  @override
  String get editPlaylistStalkerBadge => 'Stalker / MAG';

  @override
  String get progressTryingPortalList => 'Recupero della lista dal portale…';

  @override
  String get progressPortalConnecting => 'Connessione al portale…';

  @override
  String get loadErrPortalConnect => 'Impossibile connettersi al portale. Controlla l\'indirizzo del portale e che il tuo indirizzo MAC sia registrato presso il fornitore.';

  @override
  String get loadErrPortalList => 'Impossibile ottenere la lista canali. Verifica con il fornitore che il tuo indirizzo MAC sia registrato sul portale.';

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
  String get playerErrorUnsupportedFormat => 'Il formato video o audio di questo flusso non è riproducibile su questo dispositivo. Prova un\'altra fonte o un lettore esterno.';

  @override
  String get playerErrorCorruptStream => 'Impossibile leggere i dati del flusso. Il canale potrebbe essere temporaneamente guasto; riprova più tardi.';

  @override
  String get aiSubErrUnavailable => 'Il servizio di sottotitoli IA non è al momento disponibile. Riprova più tardi.';

  @override
  String get aiSubErrProRequired => 'La tua prova dei sottotitoli IA è terminata. Passa a Pro per continuare.';

  @override
  String get aiSubErrQuota => 'La quota di utilizzo dei sottotitoli IA è esaurita.';

  @override
  String get aiSubErrBusy => 'Il servizio di sottotitoli IA è molto occupato. Attendi un momento e riprova.';

  @override
  String get aiSubErrInvalidKey => 'La chiave API dei sottotitoli IA non è valida o è scaduta. Controllala in Impostazioni > Sottotitoli IA.';

  @override
  String get aiSubErrRejected => 'Il servizio di sottotitoli IA non ha accettato la richiesta. Riprova più tardi.';

  @override
  String get aiSubErrEmptyResponse => 'Il servizio di sottotitoli IA ha inviato una risposta vuota. Riprova.';

  @override
  String get aiSubErrNoSpeech => 'Nessun parlato rilevato in questa parte. Riprova in un altro punto del video.';

  @override
  String get aiSubErrGeneric => 'Impossibile creare i sottotitoli. Riprova.';

  @override
  String get aiSubErrUnreachable => 'Impossibile raggiungere il servizio di sottotitoli IA. Controlla la connessione a Internet.';

  @override
  String get aiSubErrConnectTimeout => 'Tempo scaduto durante la connessione al servizio di sottotitoli IA. Riprova.';

  @override
  String get aiSubErrExtract => 'Impossibile leggere l\'audio per i sottotitoli IA. Il formato di questo stream non è supportato su alcuni dispositivi. Prova una fonte di qualità inferiore o un lettore esterno.';

  @override
  String get aiSubErrNoOpenAiKey => 'Nessuna chiave API OpenAI inserita. Aggiungila in Impostazioni > Sottotitoli IA.';

  @override
  String aiTrialStarted(int days) {
    return 'La tua prova gratuita di $days giorni dei sottotitoli IA è iniziata';
  }

  @override
  String get paywallAiTrialEnded => 'La prova dei sottotitoli IA è terminata. Passa a Pro per continuare a usarli.';

  @override
  String get playerAiPreparing => 'Preparazione dei sottotitoli IA';

  @override
  String playerSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String playerBannerWhisper(String lang) {
    return 'Sottotitoli IA (riconoscimento vocale): $lang';
  }

  @override
  String get playerOrientationLock => 'Blocca orientamento schermo';

  @override
  String playerResumeQuestion(String position) {
    return 'Riprendere da $position?';
  }

  @override
  String get playerResumeContinue => 'Riprendi';

  @override
  String get playerResumeFromBeginning => 'Ricomincia';

  @override
  String get playerErrorStreamUnavailable => 'Impossibile aprire questo canale. La sorgente non risponde o la connessione si è interrotta.';

  @override
  String get playerErrorBackToList => 'Torna all\'elenco canali';

  @override
  String get playerReportError => 'Segnala errore';

  @override
  String get errorReportTitle => 'Segnala errore';

  @override
  String get errorReportThanks => 'Grazie!';

  @override
  String get errorReportReceived => 'La tua segnalazione di errore è stata inviata.';

  @override
  String errorReportChannel(String name) {
    return 'Canale: $name';
  }

  @override
  String errorReportError(String error) {
    return 'Errore: $error';
  }

  @override
  String errorReportDevice(String device) {
    return 'Dispositivo: $device';
  }

  @override
  String errorReportVersion(String version) {
    return 'Versione: $version';
  }

  @override
  String get errorReportNoteLabel => 'Nota aggiuntiva (facoltativa):';

  @override
  String get errorReportNotePlaceholder => 'Cosa stavi facendo?';

  @override
  String get errorReportSend => 'Invia';

  @override
  String playerPanelChannels(int count) {
    return 'Canali ($count)';
  }

  @override
  String get playerSeekForward => '▶▶ +10s';

  @override
  String get playerSeekBackward => '◀◀ -10s';

  @override
  String get playerWatchlistAdded => 'Aggiunto all\'elenco';

  @override
  String get playerWatchlistRemoved => 'Rimosso dall\'elenco';

  @override
  String get playerWatchlistTooltip => 'Guarda più tardi';

  @override
  String get settingsAiSection => 'Sottotitoli AI';

  @override
  String get settingsAiTargetLangTitle => 'Lingua di destinazione sottotitoli AI';

  @override
  String get settingsAiTargetLangSubtitle => 'Lingua per i sottotitoli tradotti';

  @override
  String get settingsAiTargetLangAuto => 'Automatica (lingua del dispositivo)';

  @override
  String get settingsAiTargetLangDialogTitle => 'Scegli la lingua di destinazione';

  @override
  String get settingsAiBannerTitle => 'Banner sottotitoli AI';

  @override
  String get settingsAiBannerSubtitle => 'Mostra la lingua di origine/destinazione in alto';

  @override
  String get settingsAiWhisperTitle => 'Sottotitoli AI Whisper';

  @override
  String get settingsAiWhisperSubtitle => 'Sottotitoli generati automaticamente nel lettore';

  @override
  String get settingsAiProviderGroq => 'Groq';

  @override
  String get settingsAiProviderGroqBadge => 'Pro';

  @override
  String get settingsAiProviderOpenai => 'OpenAI';

  @override
  String get settingsAiProviderOpenaiBadge => 'A pagamento';

  @override
  String settingsAiGroqInfo(int days) {
    return 'Servizio Groq integrato — funzione Pro, prova gratuita di $days giorni';
  }

  @override
  String get settingsAiOpenaiCost => 'Costo stimato: ~\$0.006/richiesta · ~\$0.006/min · openai.com/account/billing';

  @override
  String get settingsAiOpenaiKeyLabel => 'Chiave API OpenAI';

  @override
  String get settingsAiOpenaiKeyPlaceholder => 'sk-…';

  @override
  String get settingsAiOpenaiKeySaved => '✓ Chiave OpenAI salvata';

  @override
  String get settingsSubtitleDefaultOn => 'Sottotitoli attivi per impostazione predefinita';

  @override
  String get settingsSubtitleDefaultOnSubtitle => 'Attiva i sottotitoli all\'apertura del lettore';

  @override
  String get settingsBufferDuration => 'Durata del buffer';

  @override
  String settingsBufferSeconds(int seconds) {
    return '$seconds secondi';
  }

  @override
  String aiTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Prova sottotitoli IA: $days giorni rimasti',
      one: 'Prova sottotitoli IA: $days giorno rimasto',
    );
    return '$_temp0';
  }

  @override
  String get playerPaused => 'In pausa';

  @override
  String get playerPlaying => 'In riproduzione';

  @override
  String get playerMuted => 'Muto';

  @override
  String get playerUnmuted => 'Audio attivo';

  @override
  String playerFeedbackAudio(String label) {
    return 'Audio: $label';
  }

  @override
  String playerFeedbackSpeed(String speed) {
    return 'Velocità $speed';
  }

  @override
  String get playerFeedbackSubtitleOff => 'Sottotitoli disattivati';

  @override
  String playerFeedbackSubtitle(String lang) {
    return 'Sottotitoli: $lang';
  }

  @override
  String get playerFeedbackSubtitleLoading => 'Caricamento sottotitoli…';

  @override
  String playerFeedbackResolution(String value) {
    return 'Risoluzione: $value';
  }

  @override
  String playerFeedbackFit(String mode) {
    return 'Immagine: $mode';
  }

  @override
  String get playerFavoriteAdd => 'Aggiungi ai preferiti';

  @override
  String get playerFavoriteRemove => 'Rimuovi dai preferiti';

  @override
  String get playerNextChannel => 'Canale successivo';

  @override
  String get playerPrevChannel => 'Canale precedente';

  @override
  String get playerOrientationUnlocked => 'Rotazione sbloccata';

  @override
  String playerNextEpisode(String title) {
    return 'Prossimo episodio: $title';
  }

  @override
  String get playerOpenExternal => 'Apri nel lettore esterno (VLC)';

  @override
  String get playerExternalNotFound => 'Nessun lettore esterno trovato. Installa VLC dall\'App Store.';

  @override
  String get playerChannelPanelTooltip => 'Elenco canali';

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
  String get playerAirplayTooltip => 'AirPlay (audio)';

  @override
  String get playerAirplayUnavailable => 'AirPlay non è disponibile su questo dispositivo';

  @override
  String get playerAirplayAudioOnlyHint => 'AirPlay invia l\'audio alla TV. Per il video usa Centro di Controllo > Duplica schermo.';

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

  @override
  String get otherAppsTitle => 'Altre nostre app';

  @override
  String get otherAppsSubtitle => 'Altre app sviluppate dal nostro team';

  @override
  String get otherAppsEmpty => 'Impossibile caricare l\'elenco. Controlla la connessione a internet e riprova.';

  @override
  String get otherAppsRetry => 'Riprova';

  @override
  String get otherAppsOpenFailed => 'Impossibile aprire lo store.';

  @override
  String get otherAppsGateTitle => 'Controllo genitori';

  @override
  String get otherAppsGateQuestion => 'Per continuare, scrivi il risultato:';

  @override
  String get otherAppsCancel => 'Annulla';

  @override
  String get otherAppsContinue => 'Continua';

  @override
  String get editPlaylistTitle => 'Modifica playlist';

  @override
  String get editPlaylistNotFound => 'Playlist non trovata';

  @override
  String get editPlaylistXtreamBadge => 'Xtream Codes';

  @override
  String get editPlaylistM3uBadge => 'Playlist M3U';

  @override
  String get editPlaylistAddedAt => 'Aggiunta il';

  @override
  String get editPlaylistExpiry => 'Scade il';

  @override
  String get editPlaylistExpiredLabel => '⚠ Scaduta';

  @override
  String get editPlaylistValidLabel => '✓ Valida';

  @override
  String get editPlaylistUrlLabel => 'URL server';

  @override
  String get editPlaylistRefreshButton => 'Aggiorna canali';

  @override
  String get editPlaylistDeleteButton => 'Elimina playlist';

  @override
  String get deletePlaylistDialogTitle => 'Elimina playlist';

  @override
  String get deletePlaylistDialogQuestion => 'Come vuoi eliminarla?';

  @override
  String get deleteDeviceExplain => 'Viene rimossa solo da questo dispositivo. La copia nel cloud resta; puoi recuperarla quando vuoi con \"Scarica dal cloud\".';

  @override
  String get deleteDeviceExplainLocal => 'Viene rimossa da questo dispositivo. Questa playlist non è salvata nel cloud: per riaverla dovrai aggiungerla di nuovo.';

  @override
  String get deletePlaylistFromCloud => 'Elimina dal cloud';

  @override
  String get deletePlaylistFromDevice => 'Elimina dal dispositivo';

  @override
  String get deleteCloudExplain => 'Viene eliminata definitivamente da questo dispositivo e dal cloud e non tornerà nemmeno sugli altri tuoi dispositivi.';

  @override
  String get progressDownloadingList => 'Download della lista canali…';

  @override
  String progressRetrying(int attempt) {
    return 'Nuovo tentativo ($attempt/3)…';
  }

  @override
  String get progressParsingList => 'Elaborazione della lista canali…';

  @override
  String progressChannelsSaved(int count) {
    return '$count canali salvati…';
  }

  @override
  String get progressServerConnecting => 'Connessione al server…';

  @override
  String get progressLoadingLive => 'Caricamento dei canali live…';

  @override
  String get progressLoadingMovies => 'Caricamento dei film…';

  @override
  String get progressLoadingSeries => 'Caricamento delle serie…';

  @override
  String get loadErrM3uNotFound => 'Nessuna lista canali trovata a questo indirizzo. Assicurati che l\'indirizzo sia di una lista M3U.';

  @override
  String loadErrIncomplete(int count, int total) {
    return 'La lista è arrivata incompleta ($count / $total canali): la connessione potrebbe essersi interrotta. La lista attuale è stata mantenuta, riprova.';
  }

  @override
  String get loadErrServerEmpty => 'Il server ha inviato una lista vuota. Assicurati che il tuo abbonamento includa dei canali; se il problema persiste, contatta il fornitore.';

  @override
  String get loadErrSeriesInfo => 'Impossibile caricare i dettagli di questa serie. Aggiorna la lista e riprova.';

  @override
  String get loadErrNoEpisodes => 'Il fornitore non ha inviato episodi per questa serie.';

  @override
  String loadErrDrasticShrink(int count, int total) {
    return 'Il server ha inviato solo $count canali (prima $total). L\'abbonamento potrebbe essere scaduto; la lista attuale è stata mantenuta.';
  }

  @override
  String syncShrinkKept(String type) {
    return '$type: il server ha inviato molti meno contenuti di prima, quindi quelli esistenti sono stati mantenuti.';
  }

  @override
  String get playlistSyncQueued => 'Modifiche salvate. La lista verrà riscaricata al termine dell\'aggiornamento in corso.';

  @override
  String get errorReportPreviewLabel => 'Testo che verrà inviato (credenziali nascoste):';

  @override
  String paywallPricePerMonths(String price, int months) {
    return '$price / $months mesi';
  }

  @override
  String paywallPlanMonths(int months) {
    return '$months mesi';
  }

  @override
  String paywallIntroPriceThen(String intro, String price) {
    return '$intro prezzo introduttivo, poi $price';
  }

  @override
  String get watchlistClearAll => 'Svuota elenco';

  @override
  String get watchlistClearConfirm => 'Rimuovere tutti gli elementi?';

  @override
  String get categoryFilterPlaylist => 'Playlist';

  @override
  String get settingsRefreshOff => 'Off';

  @override
  String get settingsRefreshOnOpen => 'Ad ogni avvio';

  @override
  String get settingsRefresh1Day => 'Ogni giorno';

  @override
  String get settingsRefresh1Week => 'Ogni settimana';

  @override
  String get settingsRefresh1Month => 'Ogni mese';

  @override
  String get settingsRefresh1Year => 'Ogni anno';

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
    return 'Prossimo: $title';
  }

  @override
  String get xtreamBadLogin => 'Nome utente o password errati. Verifica i dati con il tuo fornitore e riprova.';

  @override
  String get xtreamExpired => 'Il tuo abbonamento è scaduto. Contatta il fornitore per rinnovarlo.';

  @override
  String xtreamExpiredOn(String date) {
    return 'Il tuo abbonamento è scaduto il $date. Contatta il fornitore per rinnovarlo.';
  }

  @override
  String get xtreamDisabled => 'Il tuo account è stato disattivato dal fornitore. Contatta il fornitore.';

  @override
  String get epgAutoRefreshAuto => 'Automatico — aggiornata quando la guida sta per finire';

  @override
  String xtreamPartialLoad(String type) {
    return 'Alcuni contenuti non sono stati caricati: $type';
  }

  @override
  String get settingsPlaylistAutoRefreshTitle => 'Aggiornamento automatico playlist';

  @override
  String settingsEpgUrlForPlaylist(String name) {
    return 'Per la playlist attiva: $name';
  }

  @override
  String get settingsClearHistoryDone => 'Cronologia di visione cancellata';

  @override
  String get settingsSupportSection => 'Supporto';

  @override
  String get settingsFeedbackTitle => 'Invia feedback';

  @override
  String get settingsFeedbackSubtitle => 'Suggerimenti, segnalazioni di bug o opinioni generali';

  @override
  String get feedbackDialogTitle => 'Feedback';

  @override
  String get feedbackThanks => 'Grazie!';

  @override
  String get feedbackReceived => 'Il tuo feedback è stato ricevuto.';

  @override
  String get feedbackChooseType => 'Seleziona il tipo:';

  @override
  String get feedbackTypeSuggestion => 'Suggerimento';

  @override
  String get feedbackTypeBug => 'Segnalazione bug';

  @override
  String get feedbackTypeGeneral => 'Generale';

  @override
  String get feedbackNameLabel => 'Nome';

  @override
  String get feedbackNamePlaceholder => 'Facoltativo';

  @override
  String get feedbackEmailLabel => 'Email *';

  @override
  String get feedbackEmailPlaceholder => 'esempio@mail.com';

  @override
  String get feedbackEmailInvalid => 'Inserisci un indirizzo email valido';

  @override
  String get feedbackMessageLabel => 'Il tuo messaggio *';

  @override
  String get feedbackMessagePlaceholder => 'Dicci cosa ne pensi…';

  @override
  String get feedbackScreenshotLabel => 'Screenshot (max 3)';

  @override
  String get feedbackAddImage => 'Aggiungi immagine';

  @override
  String feedbackError(String details) {
    return 'Invio non riuscito: $details';
  }

  @override
  String get feedbackImageTooLarge => 'Non è possibile allegare immagini oltre 5 MB';

  @override
  String get commonSend => 'Invia';

  @override
  String get commonSending => 'Invio in corso…';

  @override
  String get settingsRateApp => 'Valuta l\'app';

  @override
  String get settingsRateAppSubtitle => 'Valuta e recensisci sull\'App Store';

  @override
  String paywallBenefitPlaylistsUpTo(int count) {
    return 'Fino a $count playlist';
  }

  @override
  String get paywallBenefitAiWhisper => 'Sottotitoli AI Whisper';

  @override
  String get paywallBenefitCloudSyncDevices => 'Sincronizzazione cloud (multi-dispositivo)';

  @override
  String get paywallBenefitThemes => 'Temi premium';

  @override
  String get paywallBenefitWatchlist => 'Lista da guardare';

  @override
  String get paywallBenefitEpgAuto => 'Aggiornamento automatico EPG';

  @override
  String paywallPricePerYear(String price) {
    return '$price / anno';
  }

  @override
  String paywallPricePerMonth(String price) {
    return '$price / mese';
  }

  @override
  String paywallPricePerWeek(String price) {
    return '$price / settimana';
  }

  @override
  String paywallPriceOneTime(String price) {
    return '$price una tantum';
  }

  @override
  String paywallMonthlyEquivalent(String price) {
    return 'Solo $price / mese';
  }

  @override
  String paywallTrialThen(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Primi $days giorni gratis',
      one: 'Primo giorno gratis',
    );
    return '$_temp0, poi $price. Disdici quando vuoi.';
  }

  @override
  String get paywallLifetimeHint => '✦ Pagamento una tantum · Accesso a vita';

  @override
  String get paywallPurchase => 'Acquista';

  @override
  String get paywallTermsFooterApple => 'Il pagamento viene addebitato sul tuo ID Apple alla conferma dell\'acquisto. Gli abbonamenti si rinnovano automaticamente se non vengono disdetti almeno 24 ore prima della fine del periodo in corso. Gestisci o disdici nelle impostazioni dell\'account App Store.';

  @override
  String get paywallActivationPending => 'L\'acquisto è andato a buon fine ma Pro non è ancora attivo. Prova a ripristinare gli acquisti; se persiste, contatta l\'assistenza.';

  @override
  String get paywallLoadError => 'Impossibile caricare i piani. Controlla la connessione e riprova.';

  @override
  String playlistDeviceLimit(int count) {
    return 'Questo dispositivo supporta al massimo $count playlist.';
  }

  @override
  String get authReauthTitle => 'Conferma la tua identità';

  @override
  String get authReauthPasswordMessage => 'Inserisci la password per eliminare l\'account.';

  @override
  String get authAccountDeleted => 'Il tuo account è stato eliminato.';

  @override
  String get playerUrlMissing => 'URL dello stream non trovato';

  @override
  String parentalPinWrongAttempts(int remaining) {
    return 'PIN errato. Tentativi rimasti: $remaining.';
  }

  @override
  String parentalPinCooldown(int seconds) {
    return 'Troppi tentativi errati. Attendi $seconds secondi.';
  }

  @override
  String get paywallRestoreNothing => 'Nessun acquisto precedente trovato per questo ID Apple.';
}
