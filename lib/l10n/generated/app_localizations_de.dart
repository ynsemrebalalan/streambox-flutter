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
}
