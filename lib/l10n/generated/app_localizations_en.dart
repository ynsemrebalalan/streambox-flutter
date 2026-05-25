// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Error';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get languageArabic => 'Arabic';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonDeleteConfirm => 'Delete';

  @override
  String get errorTimeoutProvider => 'Provider didn\'t respond. Please try again later.';

  @override
  String get errorNoConnection => 'No internet connection or provider unreachable.';

  @override
  String get errorDatabaseTemporary => 'The database is temporarily unavailable. Please try again.';

  @override
  String get errorGenericRetry => 'Something went wrong. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeDark => 'Dark Theme';

  @override
  String get settingsThemeLight => 'Light Theme';

  @override
  String get settingsThemeSystem => 'System Theme';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'EPG URL (.xml or .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'Refresh EPG Now';

  @override
  String get settingsSelectPlaylistFirst => 'Select a playlist first';

  @override
  String get settingsEpgUpdated => 'EPG updated successfully';

  @override
  String settingsEpgError(String details) {
    return 'EPG error: $details';
  }

  @override
  String get settingsSubtitleSection => 'Subtitles';

  @override
  String get settingsSubtitleFontSize => 'Font Size';

  @override
  String get subtitleSizeSmall => 'Small';

  @override
  String get subtitleSizeNormal => 'Normal';

  @override
  String get subtitleSizeLarge => 'Large';

  @override
  String get subtitleSizeExtraLarge => 'Extra Large';

  @override
  String get settingsSubtitleTextColor => 'Text Color';

  @override
  String get subtitleColorWhite => 'White';

  @override
  String get subtitleColorYellow => 'Yellow';

  @override
  String get subtitleColorGreen => 'Green';

  @override
  String get subtitleColorCyan => 'Cyan';

  @override
  String get settingsSubtitleBgColor => 'Background';

  @override
  String get subtitleBgSemi => 'Semi-transparent';

  @override
  String get subtitleBgOpaque => 'Black';

  @override
  String get subtitleBgNone => 'None';

  @override
  String get settingsAboutSection => 'About';

  @override
  String settingsAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPlaylistManagement => 'Playlist Management';

  @override
  String get settingsCategoryFilterSubtitle => 'Hide/show categories';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Add a playlist to get started';

  @override
  String get homeAddPlaylist => 'Add Playlist';

  @override
  String get homeSearchHint => 'Search channels, movies, series…';

  @override
  String get homePlaylistsTooltip => 'Playlists';

  @override
  String get homeMore => 'More';

  @override
  String get homeCategoryManagement => 'Category Management';

  @override
  String get homeTabHome => 'Home';

  @override
  String get homeTabLive => 'Live';

  @override
  String get homeTabMovie => 'Movies';

  @override
  String get homeTabSeries => 'Series';

  @override
  String get homeTabFavorites => 'Favorites';

  @override
  String get homeFavoritesAll => 'All';

  @override
  String get homeFavoritesLive => 'Live';

  @override
  String get homeFavoritesMovie => 'Movies';

  @override
  String get homeFavoritesSeries => 'Series';

  @override
  String get homeEmptyFavorites => 'No favorites yet';

  @override
  String get homeEmptyFavoritesType => 'No favorites of this type';

  @override
  String get homeEmptyCategory => 'No content in this category';

  @override
  String get homeRowContinueWatching => 'Continue Watching';

  @override
  String get homeRowRecentlyWatched => 'Recently Watched';

  @override
  String get homeRowNewMovies => 'New Movies';

  @override
  String get homeRowNewSeries => 'New Series';

  @override
  String get homeRowNewChannels => 'New Channels';

  @override
  String get homeEmptyContent => 'No content yet';

  @override
  String get homeEmptyContentHint => 'Browse the Movies / Series / Live tabs to get started';

  @override
  String get homeRecentlyWatchedHeader => 'RECENTLY WATCHED';

  @override
  String get homeSearchEmpty => 'Start typing to search';

  @override
  String homeSearchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String homeContentCount(int count) {
    return '$count item(s)';
  }

  @override
  String get sortDialogTitle => 'Sort';

  @override
  String get sortLabelDefault => 'Default';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Sort';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get playlistsEmpty => 'No playlists yet';

  @override
  String get playlistsRefreshTooltip => 'Refresh';

  @override
  String get playlistsDeleteTooltip => 'Delete';

  @override
  String get playlistsRetryAction => 'RETRY';

  @override
  String get playlistsUpdated => 'Playlist updated.';

  @override
  String get playlistsDeleteTitle => 'Delete Playlist';

  @override
  String playlistsDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get playlistsAddTitle => 'Add Playlist';

  @override
  String get playlistsTypeM3u => 'M3U URL';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsNameLabel => 'Playlist Name';

  @override
  String get playlistsM3uUrlLabel => 'M3U URL';

  @override
  String get playlistsM3uUrlHint => 'http://… or https://…';

  @override
  String get playlistsPasteFromClipboard => 'Paste from Clipboard';

  @override
  String get playlistsClipboardEmpty => 'Clipboard is empty';

  @override
  String get playlistsServerUrlLabel => 'Server URL';

  @override
  String get playlistsServerUrlHint => 'http://server.com:8080';

  @override
  String get playlistsUsernameLabel => 'Username';

  @override
  String get playlistsPasswordLabel => 'Password';

  @override
  String get playlistsContentTypes => 'Content Types';

  @override
  String get playlistsContentLive => 'Live';

  @override
  String get playlistsContentMovie => 'Movies';

  @override
  String get playlistsContentSeries => 'Series';

  @override
  String get playlistsValidationNameUrl => 'Name and URL are required';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream requires username and password';

  @override
  String get playlistsErrorTlsHandshake => 'Could not establish a secure connection (TLS error). Try http:// or verify the provider address.';

  @override
  String get playlistsErrorTimeout => 'Provider didn\'t respond (timeout). Please try again later.';

  @override
  String get playlistsErrorConnection => 'No internet connection or provider unreachable.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'Could not update playlist: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'Provider returned an empty playlist. Previous data kept.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Reconnecting ($attempt)…';
  }

  @override
  String get playerReconnecting => 'Reconnecting…';

  @override
  String get playerLoading => 'Loading…';

  @override
  String get playerStreamRepeatedError => 'The stream keeps disconnecting. Try a different channel.';

  @override
  String get playerReconnectTooltip => 'Reconnect';

  @override
  String get playerSubtitleEnable => 'Enable AI Subtitles';

  @override
  String get playerSubtitleDisable => 'Disable AI Subtitles';

  @override
  String get playerMuteTooltip => 'Mute';

  @override
  String get playerUnmuteTooltip => 'Unmute';

  @override
  String get playerLiveLabel => 'LIVE';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Audio track';

  @override
  String get playerAudioTrackDialog => 'Audio track';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Track $n';
  }

  @override
  String get playerSpeedDialog => 'Playback speed';

  @override
  String get playerSubtitleDialogTitle => 'Subtitle';

  @override
  String get playerSubtitleAi => 'AI Subtitle';

  @override
  String get playerSubtitleAiActive => '(Active)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Embedded $n';
  }

  @override
  String get playerSubtitleOff => 'Off';

  @override
  String get playerScreenSizeTooltip => 'Screen Size';

  @override
  String get playerScreenSizeDialog => 'Screen Size';

  @override
  String get playerFitOriginal => 'Original';

  @override
  String get playerFitCover => 'Fill Screen (Crop)';

  @override
  String get playerFitStretch => 'Stretch';

  @override
  String get playerResolutionTooltip => 'Resolution';

  @override
  String get playerResolutionDialog => 'Resolution';

  @override
  String get playerResolutionAuto => 'Auto';

  @override
  String get playerSingleQuality => 'This stream offers only one quality.';

  @override
  String get disclaimerWelcome => 'Welcome';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources.\n\nThis app does not provide, host, or distribute any content. You must supply your own legally obtained playlist URL.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player is a media player for your own M3U playlists and Xtream Codes sources. The app does not host or distribute any content.';

  @override
  String get disclaimerLegalNoticeButton => 'Legal Notice';

  @override
  String get disclaimerContinue => 'Continue';

  @override
  String get disclaimerFooter => 'By continuing you agree to the Legal Notice.';

  @override
  String get legalNoticeTitle => 'Legal Notice';

  @override
  String get legalSection1Title => '1. Nature of the App';

  @override
  String get legalSection1En => 'IPTV AI Player is a general-purpose media player (similar to VLC or MX Player). It does NOT provide, host, distribute, or redirect to any TV broadcasts, movies, series, sports events, or other content. The app is a tool that plays M3U / M3U8 playlist URLs or Xtream Codes credentials supplied by the user.';

  @override
  String get legalSection1Tr => 'IPTV AI Player is a general-purpose media player. It does not provide, host, or distribute any content; it only plays the playlist URLs or Xtream credentials supplied by the user.';

  @override
  String get legalSection2Title => '2. Content Responsibility';

  @override
  String get legalSection2En => 'The user is solely responsible for all content accessed via the app. The developer has no knowledge of and bears no responsibility for content accessed through the app.';

  @override
  String get legalSection2Tr => 'The user is solely responsible for any content accessed via the app. The developer has no visibility into, and assumes no responsibility for, that content.';

  @override
  String get legalSection3Title => '3. Turkish Legal Framework';

  @override
  String get legalSection3Item1 => 'Articles 71-72 of Law No. 5846 (FSEK, Turkey): copyright infringement carries civil and criminal penalties.';

  @override
  String get legalSection3Item2 => 'Article 163/2 of the Turkish Penal Code: unauthorized use of encrypted/unencrypted broadcasts.';

  @override
  String get legalSection3Item3 => 'Additional Article 4 of the FSEK: copyright infringement on the internet.';

  @override
  String get legalSection3Item4 => 'RTÜK and BTK may impose access bans under Laws No. 6112 and 5651.';

  @override
  String get legalSection4Title => '4. User Obligations';

  @override
  String get legalSection4Body => 'By using this app you acknowledge that you will only access content you are legally subscribed to, you will not access copyrighted content without permission, and you will not use the app for pirated broadcasts or unlicensed IPTV services.';

  @override
  String get legalSection5Title => '5. Data Protection';

  @override
  String get legalSection5Body => 'The app stores your playlist URLs and credentials only locally on your device. They are not shared with any third party.';

  @override
  String get legalSection6Title => '6. Limitation of Liability';

  @override
  String get legalSection6Body => 'The app is provided \"AS IS\". The developer is not liable for any damages arising from the use of the app.';

  @override
  String get legalSection7Title => '7. Legal Cooperation';

  @override
  String get legalSection7Body => 'The developer complies with lawful requests from competent authorities (RTÜK, BTK, prosecutors).';

  @override
  String get legalReminder => 'Reminder: using this app to access unauthorized or copyrighted content is illegal. The user bears full legal responsibility.';

  @override
  String get searchHint => 'Search channels, movies, series…';

  @override
  String get searchMinChars => 'Enter at least 2 characters';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get categoryFilterTitle => 'Category Filter';

  @override
  String get categoryFilterShowAll => 'Show All';

  @override
  String get categoryFilterHideAll => 'Hide All';

  @override
  String get categoryFilterEmpty => 'No categories yet';

  @override
  String get categoryFilterSectionLive => 'Live';

  @override
  String get categoryFilterSectionMovie => 'Movies';

  @override
  String get categoryFilterSectionSeries => 'Series';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total active)';
  }

  @override
  String get seriesEmptyCategory => 'No series in this category';

  @override
  String seriesSeasonCount(int count) {
    return '$count season(s)';
  }

  @override
  String get seriesSpecialSeason => 'Specials';

  @override
  String seriesSeasonNumber(int n) {
    return 'Season $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count episodes';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'Remove from watch history';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name will be removed from your watch history. Continue?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Remove';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name removed from watch history';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name added to favorites';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name removed from favorites';
  }

  @override
  String get homeRowPopular => 'Popular';

  @override
  String get homeRowWatchedMovies => 'Movies You\'ve Watched';

  @override
  String get homeRowWatchedSeries => 'Series You\'ve Watched';

  @override
  String get badgeMovieUppercase => 'MOVIE';

  @override
  String get badgeSeriesUppercase => 'SERIES';

  @override
  String get settingsEpgPresetsTitle => 'Presets';

  @override
  String get menuMyPlaylists => 'My Playlists';

  @override
  String get menuEpgSettings => 'EPG Settings';

  @override
  String get menuNewlyAdded => 'Newly Added';

  @override
  String get menuContinueWatching => 'Continue Watching';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authAccountTitle => 'My account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authSignUpButton => 'Create account';

  @override
  String get authSignOutButton => 'Sign out';

  @override
  String get authForgotPassword => 'Forgot password';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordHint => 'We\'ll send a reset link to your email.';

  @override
  String get authResetPasswordSent => 'Reset link sent. Check your inbox.';

  @override
  String get authNoAccountQuestion => 'No account? Sign up';

  @override
  String get authHaveAccountQuestion => 'I already have an account';

  @override
  String get authOrDivider => 'or';

  @override
  String get authSignInWithGoogle => 'Continue with Google';

  @override
  String get authSignInWithApple => 'Continue with Apple';

  @override
  String get authAcceptTerms => 'I accept the Terms of Use and Privacy Policy';

  @override
  String get authViewTerms => 'View terms';

  @override
  String get authErrorInvalidEmail => 'Invalid email address';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters';

  @override
  String get authErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get authErrorEmailInUse => 'This email is already in use';

  @override
  String get authErrorWrongPassword => 'Wrong email or password';

  @override
  String get authErrorTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authErrorNetwork => 'Network error. Check your connection.';

  @override
  String authErrorGeneric(String message) {
    return 'Something went wrong: $message';
  }

  @override
  String get authVerifyEmailHint => 'We\'ve sent a verification link to your email.';

  @override
  String get authAppleHiddenEmail => 'Apple User';

  @override
  String get authAppleHiddenEmailHint => 'Email kept private via Apple — not shared';

  @override
  String get authResendVerification => 'Resend verification';

  @override
  String get authChangePassword => 'Change password';

  @override
  String get authDeleteAccount => 'Delete account';

  @override
  String get authDeleteAccountWarning => 'Deleting your account permanently removes all your cloud data. This cannot be undone.';

  @override
  String get authDeleteAccountConfirm => 'Yes, delete my account';

  @override
  String get authAccountSection => 'Account';

  @override
  String get authNotSignedIn => 'Not signed in';

  @override
  String get authSignInPromptTitle => 'Create account → Try Pro';

  @override
  String get authSignInPromptDesc => 'Sign up to unlock unlimited playlists, AI subtitles, and cross-device sync.';

  @override
  String get authProActive => 'Pro member';

  @override
  String get authFreeTier => 'Free plan';

  @override
  String get authUpgradeToPro => 'Upgrade to Pro';

  @override
  String get authRequiresRecentLogin => 'This action requires recent sign-in. Please sign in again.';

  @override
  String get paywallTitle => 'Go Pro, Remove the Limits';

  @override
  String get paywallSubtitle => 'AI subtitles, unlimited playlists, cross-device sync — all in one purchase.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Unlimited Playlists';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker — no limits';

  @override
  String get paywallBenefitAiSubtitles => 'AI Subtitles';

  @override
  String get paywallBenefitAiSubtitlesDesc => '100+ languages (40 hours/month)';

  @override
  String get paywallBenefitCloudSync => 'Cloud Sync';

  @override
  String get paywallBenefitCloudSyncDesc => 'Favorites and history across devices';

  @override
  String get paywallBenefitTvApps => 'TV + Phone';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Monthly';

  @override
  String get paywallPlanYearly => 'Yearly';

  @override
  String get paywallPlanLifetime => 'Lifetime';

  @override
  String get paywallBadgeBest => 'BEST';

  @override
  String get paywallBadgePopular => 'POPULAR';

  @override
  String get paywallSubscribeButton => 'Go Pro';

  @override
  String get paywallRestoreButton => 'Restore Purchases';

  @override
  String get paywallSignInRequired => 'Sign in to continue.';

  @override
  String get paywallSignInButton => 'Sign in first';

  @override
  String get paywallTermsFooter => 'Subscriptions auto-renew. Manage in Settings.';

  @override
  String get paywallPrivacyLink => 'Privacy Policy';

  @override
  String get paywallTermsLink => 'Terms of Use';

  @override
  String get paywallPurchaseSuccess => 'Pro activated. Enjoy!';

  @override
  String get paywallPurchaseCancelled => 'Purchase cancelled.';

  @override
  String paywallPurchaseError(String message) {
    return 'Purchase failed: $message';
  }

  @override
  String get paywallNotConfigured => 'Purchases are not configured yet. Try again later.';

  @override
  String get paywallNoOfferings => 'No offerings available.';

  @override
  String get paywallTriggerSecondPlaylist => 'Pro required for a second playlist';

  @override
  String get paywallTriggerAiSubtitle => 'Pro required for AI subtitles';

  @override
  String get paywallTriggerCloudSync => 'Pro required for cloud sync';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Unlimited movies, series and live TV are waiting for you.';

  @override
  String get welcomeFeatureUnlimited => 'Unlimited channels & favorites';

  @override
  String get welcomeFeatureSubtitles => 'Smart subtitles (100+ languages)';

  @override
  String get welcomeFeatureSync => 'Cross-device sync';

  @override
  String get welcomeStartFreeButton => 'Create account → Try Pro';

  @override
  String get welcomeSkipButton => 'Skip for now';

  @override
  String get welcomeSignInLink => 'I already have an account';

  @override
  String get watchlistTitle => 'Watchlist';

  @override
  String get watchlistEmpty => 'Your list is empty';

  @override
  String get watchlistEmptyHint => 'When you bookmark a movie or show, it appears here.';

  @override
  String get themePickerTitle => 'Theme';

  @override
  String get themeDefaultDark => 'Default Dark';

  @override
  String get themeDefaultLight => 'Default Light';

  @override
  String get themeCrimson => 'Crimson Dawn';

  @override
  String get themeRoyal => 'Royal Purple';

  @override
  String get themeForest => 'Deep Forest';

  @override
  String get themeOcean => 'Ocean Blue';

  @override
  String get parentalLockTitle => 'Parental Lock';

  @override
  String get parentalLockEnable => 'Enable Parental Lock';

  @override
  String get parentalLockEnabledHint => 'PIN required for locked categories.';

  @override
  String get parentalLockSetupFirst => 'Create a 4-digit PIN first.';

  @override
  String get parentalSetupPin => 'Create PIN';

  @override
  String get parentalChangePin => 'Change PIN';

  @override
  String get parentalRemovePin => 'Remove Parental Lock';

  @override
  String get parentalLockedCategoriesTitle => 'Categories to Lock';

  @override
  String get parentalNoCategories => 'No categories yet. Load a playlist first.';

  @override
  String get parentalEnterPin => 'Enter PIN';

  @override
  String get parentalNewPin => 'New PIN';

  @override
  String get parentalCurrentPin => 'Current PIN';

  @override
  String get parentalConfirmPin => 'Confirm PIN';

  @override
  String get parentalPinIncorrect => 'Incorrect PIN';

  @override
  String get parentalPinFourDigits => 'PIN must be 4 digits';

  @override
  String get parentalPinMismatch => 'PINs don\'t match';

  @override
  String get parentalPinChanged => 'PIN updated';

  @override
  String get parentalSubmit => 'OK';

  @override
  String get parentalNext => 'Next';

  @override
  String get cloudSyncTitle => 'Cloud Sync';

  @override
  String get cloudSyncProRequired => 'Pro subscription required';

  @override
  String get cloudSyncSignInRequired => 'Sign in, then sync';

  @override
  String get cloudSyncNever => 'Never synced';

  @override
  String get cloudSyncSyncNow => 'Sync Now';

  @override
  String get cloudSyncJustNow => 'just now';

  @override
  String cloudSyncMinutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Last sync: $when';
  }

  @override
  String get epgGuideTitle => 'TV Guide';

  @override
  String get epgToday => 'Today';

  @override
  String get epgYesterday => 'Yesterday';

  @override
  String get epgTomorrow => 'Tomorrow';

  @override
  String get epgRowEmpty => 'No programmes for this channel';

  @override
  String get epgNoData => 'No EPG data';

  @override
  String get epgNoDataHint => 'Go to Settings → EPG, set a URL, then tap \'Refresh Now\'.';

  @override
  String epgError(String msg) {
    return 'EPG error: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Auto Refresh';

  @override
  String get epgAutoRefreshOff => 'Off';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'Every ${h}h';
  }

  @override
  String get playerPipTooltip => 'Picture-in-Picture (Pro)';

  @override
  String get playerPipUnavailable => 'PiP not supported on this device';

  @override
  String get playerPipEntered => 'Playing in mini window';

  @override
  String get playerAirplayTooltip => 'AirPlay (Pro)';

  @override
  String get playerAirplayUnavailable => 'AirPlay is iOS only';

  @override
  String get playerCastTooltip => 'Cast (coming soon)';

  @override
  String get settingsPipSection => 'Picture-in-Picture';

  @override
  String get settingsPipAuto => 'Auto-PiP on Home button';

  @override
  String get settingsPipAutoSubtitle => 'Pro — When the player is open, pressing Home moves playback to a mini window';

  @override
  String get settingsAdsSection => 'Ads';

  @override
  String get settingsAdsRemoved => 'Pro: no ads';

  @override
  String get settingsAdsFreeNotice => 'Free version shows a banner at the bottom. Subscribe to Pro for an ad-free experience.';

  @override
  String get settingsProSection => 'Pro Features';

  @override
  String get settingsContentSection => 'Content';

  @override
  String get settingsPlayerSection => 'Player';

  @override
  String get settingsLegalNotice => 'Legal Notice';

  @override
  String get settingsDataDeletion => 'Data Deletion Request';

  @override
  String get settingsDataDeletionSubtitle => 'Account and data removal request';

  @override
  String get settingsTapToSignIn => 'Sign in or create an account';

  @override
  String get commonHide => 'Hide';

  @override
  String get commonShow => 'Show';

  @override
  String get profileSwitcherTitle => 'Profiles';

  @override
  String get profileDefaultName => 'Default';

  @override
  String get profileAdd => 'New Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileDelete => 'Delete Profile';

  @override
  String get profileDeleteConfirm => 'This profile and its private favorites/watchlist will be deleted. Continue?';

  @override
  String get profileNameLabel => 'Profile Name';

  @override
  String get profileEmptyName => 'Profile name cannot be empty';

  @override
  String get profileSwitched => 'Profile switched';

  @override
  String get profileMaxFreeReached => 'Free version supports 1 profile. Pro unlocks unlimited profiles.';

  @override
  String get profileSection => 'Profile';
}
