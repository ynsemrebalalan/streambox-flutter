// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get error => 'Fehler';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen. Bitte erneut versuchen.';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get languageTurkish => 'Türkisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageArabic => 'Arabisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String errorWithDetails(String details) {
    return 'Fehler: $details';
  }

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonRefresh => 'Aktualisieren';

  @override
  String get commonDeleteConfirm => 'Löschen';

  @override
  String get errorTimeoutProvider => 'Anbieter hat nicht geantwortet. Bitte später erneut versuchen.';

  @override
  String get errorNoConnection => 'Keine Internetverbindung oder Anbieter nicht erreichbar.';

  @override
  String get errorDatabaseTemporary => 'Datenbank ist vorübergehend nicht verfügbar. Bitte erneut versuchen.';

  @override
  String get errorGenericRetry => 'Ein Problem ist aufgetreten. Bitte erneut versuchen.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSaved => 'Einstellungen gespeichert';

  @override
  String get settingsAppearanceSection => 'Darstellung';

  @override
  String get settingsThemeDark => 'Dunkles Design';

  @override
  String get settingsThemeLight => 'Helles Design';

  @override
  String get settingsThemeSystem => 'System-Design';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'EPG-URL (.xml oder .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'EPG jetzt aktualisieren';

  @override
  String get settingsSelectPlaylistFirst => 'Zuerst eine Playlist auswählen';

  @override
  String get settingsEpgUpdated => 'EPG erfolgreich aktualisiert';

  @override
  String settingsEpgError(String details) {
    return 'EPG-Fehler: $details';
  }

  @override
  String get settingsSubtitleSection => 'Untertitel';

  @override
  String get settingsSubtitleFontSize => 'Schriftgröße';

  @override
  String get subtitleSizeSmall => 'Klein';

  @override
  String get subtitleSizeNormal => 'Normal';

  @override
  String get subtitleSizeLarge => 'Groß';

  @override
  String get subtitleSizeExtraLarge => 'Sehr groß';

  @override
  String get settingsSubtitleTextColor => 'Schriftfarbe';

  @override
  String get subtitleColorWhite => 'Weiß';

  @override
  String get subtitleColorYellow => 'Gelb';

  @override
  String get subtitleColorGreen => 'Grün';

  @override
  String get subtitleColorCyan => 'Cyan';

  @override
  String get settingsSubtitleBgColor => 'Hintergrund';

  @override
  String get subtitleBgSemi => 'Halbtransparent';

  @override
  String get subtitleBgOpaque => 'Schwarz';

  @override
  String get subtitleBgNone => 'Keiner';

  @override
  String get settingsAboutSection => 'Über';

  @override
  String settingsAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPlaylistManagement => 'Playlist-Verwaltung';

  @override
  String get settingsCategoryFilterSubtitle => 'Kategorien aus-/einblenden';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Füge eine Playlist hinzu, um zu starten';

  @override
  String get homeAddPlaylist => 'Playlist hinzufügen';

  @override
  String get homeSearchHint => 'Sender, Filme, Serien suchen…';

  @override
  String get homePlaylistsTooltip => 'Playlists';

  @override
  String get homeMore => 'Mehr';

  @override
  String get homeCategoryManagement => 'Kategorienverwaltung';

  @override
  String get homeTabHome => 'Start';

  @override
  String get homeTabLive => 'Live';

  @override
  String get homeTabMovie => 'Filme';

  @override
  String get homeTabSeries => 'Serien';

  @override
  String get homeTabFavorites => 'Favoriten';

  @override
  String get homeFavoritesAll => 'Alle';

  @override
  String get homeFavoritesLive => 'Live';

  @override
  String get homeFavoritesMovie => 'Filme';

  @override
  String get homeFavoritesSeries => 'Serien';

  @override
  String get homeEmptyFavorites => 'Noch keine Favoriten';

  @override
  String get homeEmptyFavoritesType => 'Keine Favoriten dieses Typs';

  @override
  String get homeEmptyCategory => 'Kein Inhalt in dieser Kategorie';

  @override
  String get homeRowContinueWatching => 'Weiterschauen';

  @override
  String get homeRowRecentlyWatched => 'Zuletzt gesehen';

  @override
  String get homeRowNewMovies => 'Neue Filme';

  @override
  String get homeRowNewSeries => 'Neue Serien';

  @override
  String get homeRowNewChannels => 'Neue Sender';

  @override
  String get homeEmptyContent => 'Noch kein Inhalt';

  @override
  String get homeEmptyContentHint => 'Schaue in die Tabs Filme / Serien / Live, um loszulegen';

  @override
  String get homeRecentlyWatchedHeader => 'ZULETZT GESEHEN';

  @override
  String get homeSearchEmpty => 'Tippe, um zu suchen';

  @override
  String homeSearchNoResults(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String homeContentCount(int count) {
    return '$count Inhalt(e)';
  }

  @override
  String get sortDialogTitle => 'Sortierung';

  @override
  String get sortLabelDefault => 'Standard';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Sortierung';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get playlistsEmpty => 'Noch keine Playlists';

  @override
  String get playlistsRefreshTooltip => 'Aktualisieren';

  @override
  String get playlistsDeleteTooltip => 'Löschen';

  @override
  String get playlistsRetryAction => 'ERNEUT';

  @override
  String get playlistsUpdated => 'Playlist aktualisiert.';

  @override
  String get playlistsDeleteTitle => 'Playlist löschen';

  @override
  String playlistsDeleteConfirm(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get playlistsAddTitle => 'Playlist hinzufügen';

  @override
  String get playlistsTypeM3u => 'M3U-URL';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsNameLabel => 'Playlist-Name';

  @override
  String get playlistsM3uUrlLabel => 'M3U-URL';

  @override
  String get playlistsM3uUrlHint => 'http://… oder https://…';

  @override
  String get playlistsPasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String get playlistsClipboardEmpty => 'Zwischenablage ist leer';

  @override
  String get playlistsServerUrlLabel => 'Server-URL';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'Benutzername';

  @override
  String get playlistsPasswordLabel => 'Passwort';

  @override
  String get playlistsContentTypes => 'Inhaltstypen';

  @override
  String get playlistsContentLive => 'Live';

  @override
  String get playlistsContentMovie => 'Filme';

  @override
  String get playlistsContentSeries => 'Serien';

  @override
  String get playlistsValidationNameUrl => 'Name und URL sind erforderlich';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream benötigt Benutzername und Passwort';

  @override
  String get playlistsErrorTlsHandshake => 'Sichere Verbindung fehlgeschlagen (TLS-Fehler). Versuche http:// oder prüfe die Anbieter-Adresse.';

  @override
  String get playlistsErrorTimeout => 'Anbieter hat nicht geantwortet (Timeout). Bitte später erneut versuchen.';

  @override
  String get playlistsErrorConnection => 'Keine Internetverbindung oder Anbieter nicht erreichbar.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'Playlist konnte nicht aktualisiert werden: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'Anbieter hat eine leere Playlist zurückgegeben. Vorherige Daten beibehalten.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Verbindung wird wiederhergestellt ($attempt)…';
  }

  @override
  String get playerReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get playerLoading => 'Wird geladen…';

  @override
  String get playerStreamRepeatedError => 'Der Stream wird ständig unterbrochen. Versuche einen anderen Sender.';

  @override
  String get playerReconnectTooltip => 'Erneut verbinden';

  @override
  String get playerSubtitleEnable => 'KI-Untertitel aktivieren';

  @override
  String get playerSubtitleDisable => 'KI-Untertitel deaktivieren';

  @override
  String get playerMuteTooltip => 'Stumm schalten';

  @override
  String get playerUnmuteTooltip => 'Stummschaltung aufheben';

  @override
  String get playerLiveLabel => 'LIVE';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Tonspur';

  @override
  String get playerAudioTrackDialog => 'Tonspur';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Spur $n';
  }

  @override
  String get playerSpeedDialog => 'Wiedergabegeschwindigkeit';

  @override
  String get playerSubtitleDialogTitle => 'Untertitel';

  @override
  String get playerSubtitleAi => 'KI-Untertitel';

  @override
  String get playerSubtitleAiActive => '(Aktiv)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Eingebettet $n';
  }

  @override
  String get playerSubtitleOff => 'Aus';

  @override
  String get playerScreenSizeTooltip => 'Bildschirmgröße';

  @override
  String get playerScreenSizeDialog => 'Bildschirmgröße';

  @override
  String get playerFitOriginal => 'Original';

  @override
  String get playerFitCover => 'Bildschirm füllen (Beschneiden)';

  @override
  String get playerFitStretch => 'Strecken';

  @override
  String get playerResolutionTooltip => 'Auflösung';

  @override
  String get playerResolutionDialog => 'Auflösung';

  @override
  String get playerResolutionAuto => 'Auto';

  @override
  String get playerSingleQuality => 'Dieser Stream bietet nur eine Qualität.';

  @override
  String get disclaimerWelcome => 'Willkommen';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources.\n\nThis app does not provide, host, or distribute any content. You must supply your own legally obtained playlist URL.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player ist ein Medienplayer für deine eigenen M3U-Playlists und Xtream-Codes-Quellen. Die App stellt keine Inhalte bereit, hostet oder verteilt sie.';

  @override
  String get disclaimerLegalNoticeButton => 'Rechtlicher Hinweis';

  @override
  String get disclaimerContinue => 'Weiter';

  @override
  String get disclaimerFooter => 'Mit dem Fortfahren akzeptierst du den rechtlichen Hinweis.';

  @override
  String get legalNoticeTitle => 'Rechtlicher Hinweis';

  @override
  String get legalSection1Title => '1. Art der App';

  @override
  String get legalSection1En => 'IPTV AI Player is a general-purpose media player (similar to VLC or MX Player). It does NOT provide, host, distribute, or redirect to any TV broadcasts, movies, series, sports events, or other content. The app is a tool that plays M3U / M3U8 playlist URLs or Xtream Codes credentials supplied by the user.';

  @override
  String get legalSection1Tr => 'IPTV AI Player ist ein universeller Medienplayer (vergleichbar mit VLC oder MX Player). Die App stellt keine Inhalte bereit, hostet oder verteilt sie; sie spielt lediglich vom Nutzer bereitgestellte M3U-/M3U8-URLs oder Xtream-Zugangsdaten ab.';

  @override
  String get legalSection2Title => '2. Verantwortung für Inhalte';

  @override
  String get legalSection2En => 'The user is solely responsible for all content accessed via the app. The developer has no knowledge of and bears no responsibility for content accessed through the app.';

  @override
  String get legalSection2Tr => 'Der Nutzer trägt die alleinige Verantwortung für alle über die App abgerufenen Inhalte. Der Entwickler hat keine Kenntnis davon und übernimmt keine Verantwortung.';

  @override
  String get legalSection3Title => '3. Türkischer Rechtsrahmen';

  @override
  String get legalSection3Item1 => 'Artikel 71-72 des Gesetzes Nr. 5846 (FSEK, Türkei): Urheberrechtsverletzungen ziehen zivil- und strafrechtliche Sanktionen nach sich.';

  @override
  String get legalSection3Item2 => 'Artikel 163/2 des türkischen Strafgesetzbuchs: unbefugte Nutzung von verschlüsselten/unverschlüsselten Übertragungen.';

  @override
  String get legalSection3Item3 => 'Zusatzartikel 4 des FSEK: Urheberrechtsverletzungen im Internet.';

  @override
  String get legalSection3Item4 => 'RTÜK und BTK können nach den Gesetzen Nr. 6112 und 5651 Zugangssperren verhängen.';

  @override
  String get legalSection4Title => '4. Pflichten des Nutzers';

  @override
  String get legalSection4Body => 'Mit der Nutzung dieser App bestätigst du, dass du nur Inhalte abrufst, für die du legal abonniert bist, dass du keine urheberrechtlich geschützten Inhalte ohne Erlaubnis nutzt und dass du die App nicht für illegale Übertragungen oder unlizenzierte IPTV-Dienste verwendest.';

  @override
  String get legalSection5Title => '5. Datenschutz';

  @override
  String get legalSection5Body => 'Die App speichert Playlist-URLs und Zugangsdaten ausschließlich lokal auf deinem Gerät. Sie werden nicht an Dritte weitergegeben.';

  @override
  String get legalSection6Title => '6. Haftungsbeschränkung';

  @override
  String get legalSection6Body => 'Die App wird \"WIE BESEHEN\" bereitgestellt. Der Entwickler haftet nicht für Schäden, die aus der Nutzung der App entstehen.';

  @override
  String get legalSection7Title => '7. Rechtliche Zusammenarbeit';

  @override
  String get legalSection7Body => 'Der Entwickler kommt rechtmäßigen Anfragen zuständiger Behörden (RTÜK, BTK, Staatsanwaltschaften) nach.';

  @override
  String get legalReminder => 'Hinweis: Die Nutzung dieser App zum Zugriff auf nicht autorisierte oder urheberrechtlich geschützte Inhalte ist illegal. Der Nutzer trägt die volle rechtliche Verantwortung.';

  @override
  String get searchHint => 'Sender, Filme, Serien suchen…';

  @override
  String get searchMinChars => 'Bitte mindestens 2 Zeichen eingeben';

  @override
  String searchNoResults(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String get categoryFilterTitle => 'Kategoriefilter';

  @override
  String get categoryFilterShowAll => 'Alle anzeigen';

  @override
  String get categoryFilterHideAll => 'Alle ausblenden';

  @override
  String get categoryFilterEmpty => 'Noch keine Kategorien';

  @override
  String get categoryFilterSectionLive => 'Live';

  @override
  String get categoryFilterSectionMovie => 'Filme';

  @override
  String get categoryFilterSectionSeries => 'Serien';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total aktiv)';
  }

  @override
  String get seriesEmptyCategory => 'Keine Serien in dieser Kategorie';

  @override
  String seriesSeasonCount(int count) {
    return '$count Staffel(n)';
  }

  @override
  String get seriesSpecialSeason => 'Specials';

  @override
  String seriesSeasonNumber(int n) {
    return 'Staffel $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count Folgen';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'Aus Verlauf entfernen';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name wird aus dem Wiedergabeverlauf entfernt. Fortfahren?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Entfernen';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name aus Verlauf entfernt';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name zu Favoriten hinzugefügt';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name aus Favoriten entfernt';
  }

  @override
  String get homeRowPopular => 'Beliebt';

  @override
  String get homeRowWatchedMovies => 'Deine angesehenen Filme';

  @override
  String get homeRowWatchedSeries => 'Deine angesehenen Serien';

  @override
  String get badgeMovieUppercase => 'FILM';

  @override
  String get badgeSeriesUppercase => 'SERIE';

  @override
  String get settingsEpgPresetsTitle => 'Vorlagen';

  @override
  String get menuMyPlaylists => 'Meine Playlists';

  @override
  String get menuEpgSettings => 'EPG-Einstellungen';

  @override
  String get menuNewlyAdded => 'Neu hinzugefügt';

  @override
  String get menuContinueWatching => 'Weiterschauen';

  @override
  String get authSignInTitle => 'Anmelden';

  @override
  String get authSignUpTitle => 'Konto erstellen';

  @override
  String get authAccountTitle => 'Mein Konto';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authSignInButton => 'Anmelden';

  @override
  String get authSignUpButton => 'Konto erstellen';

  @override
  String get authSignOutButton => 'Abmelden';

  @override
  String get authForgotPassword => 'Passwort vergessen';

  @override
  String get authResetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get authResetPasswordHint => 'Wir senden einen Zurücksetzungs-Link an deine E-Mail.';

  @override
  String get authResetPasswordSent => 'Link gesendet. Prüfe deinen Posteingang.';

  @override
  String get authNoAccountQuestion => 'Kein Konto? Registrieren';

  @override
  String get authHaveAccountQuestion => 'Ich habe bereits ein Konto';

  @override
  String get authOrDivider => 'oder';

  @override
  String get authSignInWithGoogle => 'Mit Google fortfahren';

  @override
  String get authSignInWithApple => 'Mit Apple fortfahren';

  @override
  String get authAcceptTerms => 'Ich akzeptiere die Nutzungsbedingungen und Datenschutzerklärung';

  @override
  String get authViewTerms => 'Bedingungen anzeigen';

  @override
  String get authErrorInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get authErrorWeakPassword => 'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get authErrorPasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get authErrorEmailInUse => 'Diese E-Mail wird bereits verwendet';

  @override
  String get authErrorWrongPassword => 'Falsche E-Mail oder Passwort';

  @override
  String get authErrorTooManyRequests => 'Zu viele Versuche. Versuche es später erneut.';

  @override
  String get authErrorNetwork => 'Netzwerkfehler. Prüfe deine Verbindung.';

  @override
  String authErrorGeneric(String message) {
    return 'Etwas ist schiefgelaufen: $message';
  }

  @override
  String get authVerifyEmailHint => 'Wir haben dir einen Bestätigungs-Link gesendet.';

  @override
  String get authAppleHiddenEmail => 'Apple-Benutzer';

  @override
  String get authAppleHiddenEmailHint => 'E-Mail über Apple verborgen — nicht geteilt';

  @override
  String get authResendVerification => 'Bestätigung erneut senden';

  @override
  String get authChangePassword => 'Passwort ändern';

  @override
  String get authDeleteAccount => 'Konto löschen';

  @override
  String get authDeleteAccountWarning => 'Beim Löschen deines Kontos werden alle Cloud-Daten dauerhaft entfernt. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get authDeleteAccountConfirm => 'Ja, mein Konto löschen';

  @override
  String get authAccountSection => 'Konto';

  @override
  String get authNotSignedIn => 'Nicht angemeldet';

  @override
  String get authSignInPromptTitle => 'Konto erstellen → Pro testen';

  @override
  String get authSignInPromptDesc => 'Registriere dich für unbegrenzte Playlists, KI-Untertitel und geräteübergreifende Synchronisierung.';

  @override
  String get authProActive => 'Pro-Mitglied';

  @override
  String get authFreeTier => 'Kostenloser Plan';

  @override
  String get authUpgradeToPro => 'Auf Pro upgraden';

  @override
  String get authRequiresRecentLogin => 'Diese Aktion erfordert eine kürzliche Anmeldung. Bitte melde dich erneut an.';

  @override
  String get paywallTitle => 'Pro werden, Grenzen entfernen';

  @override
  String get paywallSubtitle => 'KI-Untertitel, unbegrenzte Playlists, geräteübergreifende Synchronisierung — alles in einem Kauf.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Unbegrenzte Playlists';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker — keine Grenzen';

  @override
  String get paywallBenefitAiSubtitles => 'KI-Untertitel';

  @override
  String get paywallBenefitAiSubtitlesDesc => '100+ Sprachen (40 Stunden/Monat)';

  @override
  String get paywallBenefitCloudSync => 'Cloud-Synchronisierung';

  @override
  String get paywallBenefitCloudSyncDesc => 'Favoriten und Verlauf geräteübergreifend';

  @override
  String get paywallBenefitTvApps => 'TV + Telefon';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Monatlich';

  @override
  String get paywallPlanYearly => 'Jährlich';

  @override
  String get paywallPlanLifetime => 'Lebenslang';

  @override
  String get paywallBadgeBest => 'BESTE';

  @override
  String get paywallBadgePopular => 'BELIEBT';

  @override
  String get paywallSubscribeButton => 'Pro werden';

  @override
  String get paywallRestoreButton => 'Käufe wiederherstellen';

  @override
  String get paywallSignInRequired => 'Bitte melde dich zuerst an.';

  @override
  String get paywallSignInButton => 'Zuerst anmelden';

  @override
  String get paywallTermsFooter => 'Abonnements verlängern sich automatisch. Verwalten in den Einstellungen.';

  @override
  String get paywallPrivacyLink => 'Datenschutz';

  @override
  String get paywallTermsLink => 'Nutzungsbedingungen';

  @override
  String get paywallPurchaseSuccess => 'Pro aktiviert. Viel Spaß!';

  @override
  String get paywallPurchaseCancelled => 'Kauf abgebrochen.';

  @override
  String paywallPurchaseError(String message) {
    return 'Kauf fehlgeschlagen: $message';
  }

  @override
  String get paywallNotConfigured => 'Käufe sind noch nicht konfiguriert. Versuche es später erneut.';

  @override
  String get paywallNoOfferings => 'Keine Angebote verfügbar.';

  @override
  String get paywallTriggerSecondPlaylist => 'Pro erforderlich für eine zweite Playlist';

  @override
  String get paywallTriggerAiSubtitle => 'Pro erforderlich für KI-Untertitel';

  @override
  String get paywallTriggerCloudSync => 'Pro erforderlich für Cloud-Synchronisierung';

  @override
  String get welcomeTitle => 'Willkommen';

  @override
  String get welcomeSubtitle => 'Unbegrenzte Filme, Serien und Live-TV warten auf dich.';

  @override
  String get welcomeFeatureUnlimited => 'Unbegrenzte Kanäle & Favoriten';

  @override
  String get welcomeFeatureSubtitles => 'Intelligente Untertitel (100+ Sprachen)';

  @override
  String get welcomeFeatureSync => 'Geräteübergreifende Synchronisierung';

  @override
  String get welcomeStartFreeButton => 'Konto erstellen → Pro testen';

  @override
  String get welcomeSkipButton => 'Jetzt überspringen';

  @override
  String get welcomeSignInLink => 'Ich habe bereits ein Konto';

  @override
  String get watchlistTitle => 'Merkliste';

  @override
  String get watchlistEmpty => 'Deine Liste ist leer';

  @override
  String get watchlistEmptyHint => 'Wenn du einen Film oder eine Serie speicherst, erscheint sie hier.';

  @override
  String get themePickerTitle => 'Design';

  @override
  String get themeDefaultDark => 'Standard Dunkel';

  @override
  String get themeDefaultLight => 'Standard Hell';

  @override
  String get themeCrimson => 'Karmesinrot';

  @override
  String get themeRoyal => 'Königliches Lila';

  @override
  String get themeForest => 'Tiefer Wald';

  @override
  String get themeOcean => 'Ozeanblau';

  @override
  String get parentalLockTitle => 'Kindersicherung';

  @override
  String get parentalLockEnable => 'Kindersicherung aktivieren';

  @override
  String get parentalLockEnabledHint => 'PIN für gesperrte Kategorien erforderlich.';

  @override
  String get parentalLockSetupFirst => 'Erstelle zunächst eine 4-stellige PIN.';

  @override
  String get parentalSetupPin => 'PIN erstellen';

  @override
  String get parentalChangePin => 'PIN ändern';

  @override
  String get parentalRemovePin => 'Kindersicherung entfernen';

  @override
  String get parentalLockedCategoriesTitle => 'Zu sperrende Kategorien';

  @override
  String get parentalNoCategories => 'Noch keine Kategorien. Lade zuerst eine Wiedergabeliste.';

  @override
  String get parentalEnterPin => 'PIN eingeben';

  @override
  String get parentalNewPin => 'Neue PIN';

  @override
  String get parentalCurrentPin => 'Aktuelle PIN';

  @override
  String get parentalConfirmPin => 'PIN bestätigen';

  @override
  String get parentalPinIncorrect => 'Falsche PIN';

  @override
  String get parentalPinFourDigits => 'PIN muss 4 Ziffern haben';

  @override
  String get parentalPinMismatch => 'PINs stimmen nicht überein';

  @override
  String get parentalPinChanged => 'PIN aktualisiert';

  @override
  String get parentalSubmit => 'OK';

  @override
  String get parentalNext => 'Weiter';

  @override
  String get cloudSyncTitle => 'Cloud-Sync';

  @override
  String get cloudSyncProRequired => 'Pro-Abo erforderlich';

  @override
  String get cloudSyncSignInRequired => 'Anmelden, dann synchronisieren';

  @override
  String get cloudSyncNever => 'Noch nie synchronisiert';

  @override
  String get cloudSyncSyncNow => 'Jetzt synchronisieren';

  @override
  String get cloudSyncJustNow => 'gerade eben';

  @override
  String cloudSyncMinutesAgo(int n) {
    return 'vor $n Min.';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return 'vor $n Std.';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return 'vor $n Tagen';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Letzte Sync: $when';
  }

  @override
  String get epgGuideTitle => 'TV-Programm';

  @override
  String get epgToday => 'Heute';

  @override
  String get epgYesterday => 'Gestern';

  @override
  String get epgTomorrow => 'Morgen';

  @override
  String get epgRowEmpty => 'Keine Sendungen für diesen Kanal';

  @override
  String get epgNoData => 'Keine EPG-Daten';

  @override
  String get epgNoDataHint => 'Gehe zu Einstellungen → EPG, URL eintragen, dann \'Jetzt aktualisieren\'.';

  @override
  String epgError(String msg) {
    return 'EPG-Fehler: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Auto-Update';

  @override
  String get epgAutoRefreshOff => 'Aus';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'Alle ${h}h';
  }

  @override
  String get playerPipTooltip => 'Bild-in-Bild (Pro)';

  @override
  String get playerPipUnavailable => 'PiP wird auf diesem Gerät nicht unterstützt';

  @override
  String get playerPipEntered => 'Wiedergabe im Mini-Fenster';

  @override
  String get playerAirplayTooltip => 'AirPlay (Pro)';

  @override
  String get playerAirplayUnavailable => 'AirPlay nur unter iOS';

  @override
  String get playerCastTooltip => 'Cast (bald verfügbar)';

  @override
  String get settingsPipSection => 'Bild-in-Bild';

  @override
  String get settingsPipAuto => 'Auto-PiP bei Home-Taste';

  @override
  String get settingsPipAutoSubtitle => 'Pro — Wenn der Player geöffnet ist, wechselt die Wiedergabe beim Drücken der Home-Taste in ein Mini-Fenster';

  @override
  String get settingsAdsSection => 'Werbung';

  @override
  String get settingsAdsRemoved => 'Pro: keine Werbung';

  @override
  String get settingsAdsFreeNotice => 'Die Free-Version zeigt unten ein Banner. Mit Pro werbefrei genießen.';

  @override
  String get settingsProSection => 'Pro-Funktionen';

  @override
  String get settingsContentSection => 'Inhalt';

  @override
  String get settingsPlayerSection => 'Player';

  @override
  String get settingsLegalNotice => 'Rechtlicher Hinweis';

  @override
  String get settingsDataDeletion => 'Datenlöschung beantragen';

  @override
  String get settingsDataDeletionSubtitle => 'Konto- und Datenentfernungsanfrage';

  @override
  String get settingsTapToSignIn => 'Anmelden oder Konto erstellen';

  @override
  String get commonHide => 'Ausblenden';

  @override
  String get commonShow => 'Einblenden';

  @override
  String get profileSwitcherTitle => 'Profile';

  @override
  String get profileDefaultName => 'Standard';

  @override
  String get profileAdd => 'Neues Profil';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileDelete => 'Profil löschen';

  @override
  String get profileDeleteConfirm => 'Dieses Profil und seine privaten Favoriten/Merkliste werden gelöscht. Fortfahren?';

  @override
  String get profileNameLabel => 'Profilname';

  @override
  String get profileEmptyName => 'Profilname darf nicht leer sein';

  @override
  String get profileSwitched => 'Profil gewechselt';

  @override
  String get profileMaxFreeReached => 'Free-Version unterstützt 1 Profil. Pro schaltet unbegrenzte Profile frei.';

  @override
  String get profileSection => 'Profil';
}
