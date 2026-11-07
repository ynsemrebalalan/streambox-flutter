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
  String get languageItalian => 'Italian';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageRomanian => 'Romanian';

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
  String get homePlaylistSyncing => 'Syncing playlist…';

  @override
  String get homeSearchTooltip => 'Search';

  @override
  String get watchlistAddTooltip => 'Add to My List';

  @override
  String get watchlistRemoveTooltip => 'Remove from My List';

  @override
  String get playerPlayAction => 'Play';

  @override
  String get playerPauseAction => 'Pause';

  @override
  String get playlistsActiveLabel => 'Active';

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
  String get playlistsTypeStalker => 'Stalker / MAG';

  @override
  String get playlistsStalkerCardTitle => 'Stalker Portal / MAG Box';

  @override
  String get playlistsStalkerCardBody => 'Your MAC address must be registered with your IPTV provider. The app first tries the fast M3U path, then falls back to the full Stalker protocol if needed.';

  @override
  String get playlistsStalkerPortalLabel => 'Portal URL';

  @override
  String get playlistsStalkerPortalHint => 'http://provider.com:8080';

  @override
  String get playlistsStalkerMacLabel => 'MAC Address';

  @override
  String get playlistsStalkerMacHint => '00:1A:79:XX:XX:XX';

  @override
  String get playlistsStalkerMacGenerate => 'Generate';

  @override
  String get playlistsStalkerMacHelp => 'MAC format: XX:XX:XX:XX:XX:XX (uppercase, colon-separated)';

  @override
  String get playlistsValidationStalkerMac => 'Enter a valid MAC address (XX:XX:XX:XX:XX:XX).';

  @override
  String get editPlaylistStalkerBadge => 'Stalker / MAG';

  @override
  String get progressTryingPortalList => 'Trying to fetch the list from the portal…';

  @override
  String get progressPortalConnecting => 'Connecting to the portal…';

  @override
  String get loadErrPortalConnect => 'Couldn\'t connect to the portal. Check the portal address and that your MAC address is registered with your provider.';

  @override
  String get loadErrPortalList => 'Couldn\'t get the channel list. Check with your provider that your MAC address is registered on the portal.';

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
  String get playerErrorUnsupportedFormat => 'This stream\'s video or audio format can\'t be played on this device. Try another source or use an external player.';

  @override
  String get playerErrorCorruptStream => 'The stream data couldn\'t be read. The channel may be temporarily broken; try again later.';

  @override
  String get aiSubErrUnavailable => 'The AI subtitle service is unavailable right now. Please try again later.';

  @override
  String get aiSubErrProRequired => 'Your AI subtitle trial has ended. Upgrade to Pro to continue.';

  @override
  String get aiSubErrQuota => 'The AI subtitle usage quota has been used up.';

  @override
  String get aiSubErrBusy => 'The AI subtitle service is very busy right now. Wait a moment and try again.';

  @override
  String get aiSubErrInvalidKey => 'The AI subtitle API key is invalid or has expired. Check it in Settings > AI Subtitles.';

  @override
  String get aiSubErrRejected => 'The AI subtitle service didn\'t accept the request. Please try again later.';

  @override
  String get aiSubErrEmptyResponse => 'The AI subtitle service sent an empty response. Please try again.';

  @override
  String get aiSubErrNoSpeech => 'No speech was detected in this part. Try again at a different point in the video.';

  @override
  String get aiSubErrGeneric => 'Subtitles couldn\'t be created. Please try again.';

  @override
  String get aiSubErrUnreachable => 'Can\'t reach the AI subtitle service. Check your internet connection.';

  @override
  String get aiSubErrConnectTimeout => 'Connecting to the AI subtitle service timed out. Please try again.';

  @override
  String get aiSubErrExtract => 'Couldn\'t read the audio for AI subtitles. This stream\'s format isn\'t supported on some devices. Try a lower-quality source or watch in an external player.';

  @override
  String get aiSubErrNoOpenAiKey => 'No OpenAI API key has been entered. Add one in Settings > AI Subtitles.';

  @override
  String aiTrialStarted(int days) {
    return 'Your $days-day free AI subtitle trial has started';
  }

  @override
  String get paywallAiTrialEnded => 'Your AI subtitle trial has ended. Upgrade to Pro to keep using it.';

  @override
  String get playerAiPreparing => 'Preparing AI subtitles';

  @override
  String playerSecondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String playerBannerWhisper(String lang) {
    return 'AI subtitles (speech recognition): $lang';
  }

  @override
  String get playerOrientationLock => 'Lock screen orientation';

  @override
  String playerResumeQuestion(String position) {
    return 'Resume from $position?';
  }

  @override
  String get playerResumeContinue => 'Resume';

  @override
  String get playerResumeFromBeginning => 'Start Over';

  @override
  String get playerErrorStreamUnavailable => 'This channel could not be opened. The stream source is not responding or the connection dropped.';

  @override
  String get playerErrorBackToList => 'Back to channel list';

  @override
  String get playerReportError => 'Report Error';

  @override
  String get errorReportTitle => 'Report Error';

  @override
  String get errorReportThanks => 'Thank you!';

  @override
  String get errorReportReceived => 'Your error report has been sent.';

  @override
  String errorReportChannel(String name) {
    return 'Channel: $name';
  }

  @override
  String errorReportError(String error) {
    return 'Error: $error';
  }

  @override
  String errorReportDevice(String device) {
    return 'Device: $device';
  }

  @override
  String errorReportVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get errorReportNoteLabel => 'Additional note (optional):';

  @override
  String get errorReportNotePlaceholder => 'What were you doing?';

  @override
  String get errorReportSend => 'Send';

  @override
  String playerPanelChannels(int count) {
    return 'Channels ($count)';
  }

  @override
  String get playerSeekForward => '▶▶ +10s';

  @override
  String get playerSeekBackward => '◀◀ -10s';

  @override
  String get playerWatchlistAdded => 'Added to list';

  @override
  String get playerWatchlistRemoved => 'Removed from list';

  @override
  String get playerWatchlistTooltip => 'Watch Later';

  @override
  String get settingsAiSection => 'AI Subtitles';

  @override
  String get settingsAiTargetLangTitle => 'AI Subtitle Target Language';

  @override
  String get settingsAiTargetLangSubtitle => 'Language for translated subtitles';

  @override
  String get settingsAiTargetLangAuto => 'Auto (device language)';

  @override
  String get settingsAiTargetLangDialogTitle => 'Choose Target Language';

  @override
  String get settingsAiBannerTitle => 'AI Subtitle Banner';

  @override
  String get settingsAiBannerSubtitle => 'Show source/target language at the top';

  @override
  String get settingsAiWhisperTitle => 'AI Whisper Subtitles';

  @override
  String get settingsAiWhisperSubtitle => 'Auto-generated subtitles in the player';

  @override
  String get settingsAiProviderGroq => 'Groq';

  @override
  String get settingsAiProviderGroqBadge => 'Pro';

  @override
  String get settingsAiProviderOpenai => 'OpenAI';

  @override
  String get settingsAiProviderOpenaiBadge => 'Paid';

  @override
  String settingsAiGroqInfo(int days) {
    return 'Built-in Groq service — Pro feature, $days-day free trial';
  }

  @override
  String get settingsAiOpenaiCost => 'Estimated cost: ~\$0.006/request · ~\$0.006/min · openai.com/account/billing';

  @override
  String get settingsAiOpenaiKeyLabel => 'OpenAI API Key';

  @override
  String get settingsAiOpenaiKeyPlaceholder => 'sk-…';

  @override
  String get settingsAiOpenaiKeySaved => '✓ OpenAI key saved';

  @override
  String get settingsSubtitleDefaultOn => 'Subtitles on by default';

  @override
  String get settingsSubtitleDefaultOnSubtitle => 'Enable subtitles when the player opens';

  @override
  String get settingsBufferDuration => 'Buffer duration';

  @override
  String settingsBufferSeconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String aiTrialDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'AI subtitle trial: $days days left',
      one: 'AI subtitle trial: $days day left',
    );
    return '$_temp0';
  }

  @override
  String get playerPaused => 'Paused';

  @override
  String get playerPlaying => 'Playing';

  @override
  String get playerMuted => 'Muted';

  @override
  String get playerUnmuted => 'Sound on';

  @override
  String playerFeedbackAudio(String label) {
    return 'Audio: $label';
  }

  @override
  String playerFeedbackSpeed(String speed) {
    return 'Speed $speed';
  }

  @override
  String get playerFeedbackSubtitleOff => 'Subtitles off';

  @override
  String playerFeedbackSubtitle(String lang) {
    return 'Subtitles: $lang';
  }

  @override
  String get playerFeedbackSubtitleLoading => 'Loading subtitles…';

  @override
  String playerFeedbackResolution(String value) {
    return 'Resolution: $value';
  }

  @override
  String playerFeedbackFit(String mode) {
    return 'Display: $mode';
  }

  @override
  String get playerFavoriteAdd => 'Add to favorites';

  @override
  String get playerFavoriteRemove => 'Remove from favorites';

  @override
  String get playerNextChannel => 'Next channel';

  @override
  String get playerPrevChannel => 'Previous channel';

  @override
  String get playerOrientationUnlocked => 'Rotation unlocked';

  @override
  String playerNextEpisode(String title) {
    return 'Next episode: $title';
  }

  @override
  String get playerOpenExternal => 'Open in external player (VLC)';

  @override
  String get playerExternalNotFound => 'No external player found. Install VLC from the App Store.';

  @override
  String get playerChannelPanelTooltip => 'Channel list';

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
  String get playerAirplayTooltip => 'AirPlay (audio)';

  @override
  String get playerAirplayUnavailable => 'AirPlay is not available on this device';

  @override
  String get playerAirplayAudioOnlyHint => 'AirPlay sends the audio to your TV. For video, use Control Center > Screen Mirroring.';

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

  @override
  String get otherAppsTitle => 'More Apps From Us';

  @override
  String get otherAppsSubtitle => 'Other apps made by our team';

  @override
  String get otherAppsEmpty => 'The list could not be loaded. Check your internet connection and try again.';

  @override
  String get otherAppsRetry => 'Try Again';

  @override
  String get otherAppsOpenFailed => 'Could not open the store.';

  @override
  String get otherAppsGateTitle => 'Parental check';

  @override
  String get otherAppsGateQuestion => 'To continue, type the answer:';

  @override
  String get otherAppsCancel => 'Cancel';

  @override
  String get otherAppsContinue => 'Continue';

  @override
  String get editPlaylistTitle => 'Edit Playlist';

  @override
  String get editPlaylistNotFound => 'Playlist not found';

  @override
  String get editPlaylistXtreamBadge => 'Xtream Codes';

  @override
  String get editPlaylistM3uBadge => 'M3U Playlist';

  @override
  String get editPlaylistAddedAt => 'Added on';

  @override
  String get editPlaylistExpiry => 'Expires on';

  @override
  String get editPlaylistExpiredLabel => '⚠ Expired';

  @override
  String get editPlaylistValidLabel => '✓ Valid';

  @override
  String get editPlaylistUrlLabel => 'Server URL';

  @override
  String get editPlaylistRefreshButton => 'Refresh Channels';

  @override
  String get editPlaylistDeleteButton => 'Delete Playlist';

  @override
  String get deletePlaylistDialogTitle => 'Delete Playlist';

  @override
  String get deletePlaylistDialogQuestion => 'How would you like to delete it?';

  @override
  String get deleteDeviceExplain => 'Removed from this device only. The cloud copy stays; you can get it back any time with \"Download from Cloud\".';

  @override
  String get deleteDeviceExplainLocal => 'Removed from this device. This playlist isn\'t saved in the cloud, so you\'ll need to add it again to get it back.';

  @override
  String get deletePlaylistFromCloud => 'Delete from Cloud';

  @override
  String get deletePlaylistFromDevice => 'Delete from Device';

  @override
  String get deleteCloudExplain => 'Permanently deleted from this device and the cloud; it won\'t come back to your other devices either.';

  @override
  String get progressDownloadingList => 'Downloading channel list…';

  @override
  String progressRetrying(int attempt) {
    return 'Retrying ($attempt/3)…';
  }

  @override
  String get progressParsingList => 'Processing channel list…';

  @override
  String progressChannelsSaved(int count) {
    return '$count channels saved…';
  }

  @override
  String get progressServerConnecting => 'Connecting to the server…';

  @override
  String get progressLoadingLive => 'Loading live channels…';

  @override
  String get progressLoadingMovies => 'Loading movies…';

  @override
  String get progressLoadingSeries => 'Loading series…';

  @override
  String get loadErrM3uNotFound => 'No channel list was found at this address. Make sure the address points to an M3U list.';

  @override
  String loadErrIncomplete(int count, int total) {
    return 'The list arrived incomplete ($count / $total channels) — the connection may have dropped. Your current list was kept; try again.';
  }

  @override
  String get loadErrServerEmpty => 'The server sent an empty list. Make sure your subscription includes channels; if the problem continues, contact your provider.';

  @override
  String get loadErrSeriesInfo => 'This series\' details couldn\'t be loaded. Refresh the list and try again.';

  @override
  String get loadErrNoEpisodes => 'Your provider didn\'t send any episodes for this series.';

  @override
  String loadErrDrasticShrink(int count, int total) {
    return 'The server sent only $count channels (previously $total). Your subscription may have expired; your current list was kept.';
  }

  @override
  String syncShrinkKept(String type) {
    return '$type: the server sent far fewer items than before, so the existing content was kept.';
  }

  @override
  String get playlistSyncQueued => 'Changes saved. The list will be re-downloaded when the current update finishes.';

  @override
  String get errorReportPreviewLabel => 'Text that will be sent (login details hidden):';

  @override
  String paywallPricePerMonths(String price, int months) {
    return '$price / $months months';
  }

  @override
  String paywallPlanMonths(int months) {
    return '$months-Month';
  }

  @override
  String paywallIntroPriceThen(String intro, String price) {
    return '$intro introductory price, then $price';
  }

  @override
  String get watchlistClearAll => 'Clear list';

  @override
  String get watchlistClearConfirm => 'Remove all items?';

  @override
  String get categoryFilterPlaylist => 'Playlist';

  @override
  String get settingsRefreshOff => 'Off';

  @override
  String get settingsRefreshOnOpen => 'Every Launch';

  @override
  String get settingsRefresh1Day => 'Every Day';

  @override
  String get settingsRefresh1Week => 'Every Week';

  @override
  String get settingsRefresh1Month => 'Every Month';

  @override
  String get settingsRefresh1Year => 'Every Year';

  @override
  String get settingsClearHistoryTitle => 'Clear History';

  @override
  String get settingsClearHistorySubtitle => 'Clears Recently Watched, Continue Watching and Watched lists. Your favorites are kept';

  @override
  String get settingsClearHistoryDialogTitle => 'Clear watch history?';

  @override
  String get settingsClearHistoryDialogMessage => 'All entries in Recently Watched, Continue Watching and Watched lists will be deleted. This cannot be undone.';

  @override
  String get settingsClearHistoryAction => 'Clear';

  @override
  String epgNextProgram(String title) {
    return 'Next: $title';
  }

  @override
  String get xtreamBadLogin => 'The username or password is wrong. Check your details with your provider and try again.';

  @override
  String get xtreamExpired => 'Your subscription has expired. Contact your provider to renew it.';

  @override
  String xtreamExpiredOn(String date) {
    return 'Your subscription expired on $date. Contact your provider to renew it.';
  }

  @override
  String get xtreamDisabled => 'Your account has been disabled by your provider. Contact your provider.';

  @override
  String get epgAutoRefreshAuto => 'Automatic — refreshed when the guide is running out';

  @override
  String xtreamPartialLoad(String type) {
    return 'Some content could not be loaded: $type';
  }

  @override
  String get settingsPlaylistAutoRefreshTitle => 'Playlist auto-refresh';

  @override
  String settingsEpgUrlForPlaylist(String name) {
    return 'For the active playlist: $name';
  }

  @override
  String get settingsClearHistoryDone => 'Watch history cleared';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsFeedbackTitle => 'Send Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Suggestions, bug reports, or general thoughts';

  @override
  String get feedbackDialogTitle => 'Feedback';

  @override
  String get feedbackThanks => 'Thank you!';

  @override
  String get feedbackReceived => 'Your feedback has been received.';

  @override
  String get feedbackChooseType => 'Select type:';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeBug => 'Bug Report';

  @override
  String get feedbackTypeGeneral => 'General';

  @override
  String get feedbackNameLabel => 'Name';

  @override
  String get feedbackNamePlaceholder => 'Optional';

  @override
  String get feedbackEmailLabel => 'Email *';

  @override
  String get feedbackEmailPlaceholder => 'example@mail.com';

  @override
  String get feedbackEmailInvalid => 'Enter a valid email address';

  @override
  String get feedbackMessageLabel => 'Your message *';

  @override
  String get feedbackMessagePlaceholder => 'Tell us what\'s on your mind…';

  @override
  String get feedbackScreenshotLabel => 'Screenshots (max 3)';

  @override
  String get feedbackAddImage => 'Add Image';

  @override
  String feedbackError(String details) {
    return 'Could not send: $details';
  }

  @override
  String get feedbackImageTooLarge => 'Images larger than 5 MB can\'t be attached';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSending => 'Sending…';

  @override
  String get settingsRateApp => 'Rate the app';

  @override
  String get settingsRateAppSubtitle => 'Rate and review on the App Store';

  @override
  String paywallBenefitPlaylistsUpTo(int count) {
    return 'Up to $count playlists';
  }

  @override
  String get paywallBenefitAiWhisper => 'AI Whisper subtitles';

  @override
  String get paywallBenefitCloudSyncDevices => 'Cloud sync (cross-device)';

  @override
  String get paywallBenefitThemes => 'Premium themes';

  @override
  String get paywallBenefitWatchlist => 'Watchlist';

  @override
  String get paywallBenefitEpgAuto => 'EPG auto-refresh';

  @override
  String paywallPricePerYear(String price) {
    return '$price / year';
  }

  @override
  String paywallPricePerMonth(String price) {
    return '$price / month';
  }

  @override
  String paywallPricePerWeek(String price) {
    return '$price / week';
  }

  @override
  String paywallPriceOneTime(String price) {
    return '$price one-time';
  }

  @override
  String paywallMonthlyEquivalent(String price) {
    return 'Just $price / month';
  }

  @override
  String paywallTrialThen(int days, String price) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'First $days days free',
      one: 'First day free',
    );
    return '$_temp0, then $price. Cancel anytime.';
  }

  @override
  String get paywallLifetimeHint => '✦ One-time payment · Lifetime access';

  @override
  String get paywallPurchase => 'Purchase';

  @override
  String get paywallTermsFooterApple => 'Payment is charged to your Apple ID at confirmation of purchase. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your App Store account settings.';

  @override
  String get paywallActivationPending => 'Your purchase went through but Pro isn\'t active yet. Try restoring your purchases; if it persists, contact support.';

  @override
  String get paywallLoadError => 'Plans couldn\'t be loaded. Check your connection and try again.';

  @override
  String playlistDeviceLimit(int count) {
    return 'This device supports up to $count playlists.';
  }

  @override
  String get authReauthTitle => 'Confirm it\'s you';

  @override
  String get authReauthPasswordMessage => 'Enter your password to delete your account.';

  @override
  String get authAccountDeleted => 'Your account has been deleted.';

  @override
  String get playerUrlMissing => 'Stream URL not found';

  @override
  String parentalPinWrongAttempts(int remaining) {
    return 'Wrong PIN. Attempts left: $remaining.';
  }

  @override
  String parentalPinCooldown(int seconds) {
    return 'Too many wrong attempts. Wait $seconds seconds.';
  }

  @override
  String get paywallRestoreNothing => 'No previous purchases were found for this Apple ID.';
}
