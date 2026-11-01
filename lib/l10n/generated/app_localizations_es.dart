// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'IPTV AI Player';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando…';

  @override
  String get error => 'Error';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageArabic => 'Árabe';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageRomanian => 'Rumano';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonRefresh => 'Actualizar';

  @override
  String get commonDeleteConfirm => 'Eliminar';

  @override
  String get errorTimeoutProvider => 'El proveedor no respondió. Inténtalo más tarde.';

  @override
  String get errorNoConnection => 'Sin conexión a internet o el proveedor no está disponible.';

  @override
  String get errorDatabaseTemporary => 'La base de datos no está disponible temporalmente. Inténtalo de nuevo.';

  @override
  String get errorGenericRetry => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSaved => 'Ajustes guardados';

  @override
  String get settingsAppearanceSection => 'Apariencia';

  @override
  String get settingsThemeDark => 'Tema oscuro';

  @override
  String get settingsThemeLight => 'Tema claro';

  @override
  String get settingsThemeSystem => 'Tema del sistema';

  @override
  String get settingsEpgSection => 'EPG';

  @override
  String get settingsEpgUrlLabel => 'URL del EPG (.xml o .xml.gz)';

  @override
  String get settingsEpgRefreshNow => 'Actualizar EPG ahora';

  @override
  String get settingsSelectPlaylistFirst => 'Selecciona primero una lista';

  @override
  String get settingsEpgUpdated => 'EPG actualizado correctamente';

  @override
  String settingsEpgError(String details) {
    return 'Error del EPG: $details';
  }

  @override
  String get settingsSubtitleSection => 'Subtítulos';

  @override
  String get settingsSubtitleFontSize => 'Tamaño de fuente';

  @override
  String get subtitleSizeSmall => 'Pequeño';

  @override
  String get subtitleSizeNormal => 'Normal';

  @override
  String get subtitleSizeLarge => 'Grande';

  @override
  String get subtitleSizeExtraLarge => 'Muy grande';

  @override
  String get settingsSubtitleTextColor => 'Color del texto';

  @override
  String get subtitleColorWhite => 'Blanco';

  @override
  String get subtitleColorYellow => 'Amarillo';

  @override
  String get subtitleColorGreen => 'Verde';

  @override
  String get subtitleColorCyan => 'Cian';

  @override
  String get settingsSubtitleBgColor => 'Fondo';

  @override
  String get subtitleBgSemi => 'Semitransparente';

  @override
  String get subtitleBgOpaque => 'Negro';

  @override
  String get subtitleBgNone => 'Ninguno';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String settingsAppVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsPlaylistManagement => 'Gestión de listas';

  @override
  String get settingsCategoryFilterSubtitle => 'Ocultar/mostrar categorías';

  @override
  String get homeAppTitle => 'IPTV AI Player';

  @override
  String get homeNoPlaylistMessage => 'Añade una lista para empezar';

  @override
  String get homeAddPlaylist => 'Añadir lista';

  @override
  String get homeSearchHint => 'Buscar canales, películas, series…';

  @override
  String get homePlaylistsTooltip => 'Listas';

  @override
  String get homeMore => 'Más';

  @override
  String get homeCategoryManagement => 'Gestión de categorías';

  @override
  String get homeTabHome => 'Inicio';

  @override
  String get homeTabLive => 'En directo';

  @override
  String get homeTabMovie => 'Películas';

  @override
  String get homeTabSeries => 'Series';

  @override
  String get homeTabFavorites => 'Favoritos';

  @override
  String get homeFavoritesAll => 'Todos';

  @override
  String get homeFavoritesLive => 'En directo';

  @override
  String get homeFavoritesMovie => 'Películas';

  @override
  String get homeFavoritesSeries => 'Series';

  @override
  String get homeEmptyFavorites => 'Aún no hay favoritos';

  @override
  String get homeEmptyFavoritesType => 'No hay favoritos de este tipo';

  @override
  String get homeEmptyCategory => 'No hay contenido en esta categoría';

  @override
  String get homeRowContinueWatching => 'Seguir viendo';

  @override
  String get homeRowRecentlyWatched => 'Vistos recientemente';

  @override
  String get homeRowNewMovies => 'Películas nuevas';

  @override
  String get homeRowNewSeries => 'Series nuevas';

  @override
  String get homeRowNewChannels => 'Canales nuevos';

  @override
  String get homeEmptyContent => 'Aún no hay contenido';

  @override
  String get homeEmptyContentHint => 'Explora las pestañas Películas / Series / En directo para empezar';

  @override
  String get homeRecentlyWatchedHeader => 'VISTOS RECIENTEMENTE';

  @override
  String get homeSearchEmpty => 'Empieza a escribir para buscar';

  @override
  String homeSearchNoResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String homeContentCount(int count) {
    return '$count elemento(s)';
  }

  @override
  String get sortDialogTitle => 'Ordenar';

  @override
  String get sortLabelDefault => 'Predeterminado';

  @override
  String get sortLabelAZ => 'A → Z';

  @override
  String get sortLabelZA => 'Z → A';

  @override
  String get sortLabelShortAZ => 'A→Z';

  @override
  String get sortLabelShortZA => 'Z→A';

  @override
  String get sortLabelShort => 'Ordenar';

  @override
  String get playlistsTitle => 'Listas';

  @override
  String get playlistsEmpty => 'Aún no hay listas';

  @override
  String get playlistsRefreshTooltip => 'Actualizar';

  @override
  String get playlistsDeleteTooltip => 'Eliminar';

  @override
  String get playlistsRetryAction => 'REINTENTAR';

  @override
  String get playlistsUpdated => 'Lista actualizada.';

  @override
  String get playlistsDeleteTitle => 'Eliminar lista';

  @override
  String playlistsDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get playlistsAddTitle => 'Añadir lista';

  @override
  String get playlistsTypeM3u => 'URL M3U';

  @override
  String get playlistsTypeXtream => 'Xtream';

  @override
  String get playlistsNameLabel => 'Nombre de la lista';

  @override
  String get playlistsM3uUrlLabel => 'URL M3U';

  @override
  String get playlistsM3uUrlHint => 'http://… o https://…';

  @override
  String get playlistsPasteFromClipboard => 'Pegar del portapapeles';

  @override
  String get playlistsClipboardEmpty => 'El portapapeles está vacío';

  @override
  String get playlistsServerUrlLabel => 'URL del servidor';

  @override
  String get playlistsServerUrlHint => 'http://servidor.com:8080';

  @override
  String get playlistsUsernameLabel => 'Nombre de usuario';

  @override
  String get playlistsPasswordLabel => 'Contraseña';

  @override
  String get playlistsContentTypes => 'Tipos de contenido';

  @override
  String get playlistsContentLive => 'En directo';

  @override
  String get playlistsContentMovie => 'Películas';

  @override
  String get playlistsContentSeries => 'Series';

  @override
  String get playlistsValidationNameUrl => 'El nombre y la URL son obligatorios';

  @override
  String get playlistsValidationXtreamCreds => 'Xtream requiere nombre de usuario y contraseña';

  @override
  String get playlistsErrorTlsHandshake => 'No se pudo establecer una conexión segura (error TLS). Prueba con http:// o verifica la dirección del proveedor.';

  @override
  String get playlistsErrorTimeout => 'El proveedor no respondió (tiempo agotado). Inténtalo más tarde.';

  @override
  String get playlistsErrorConnection => 'Sin conexión a internet o el proveedor no está disponible.';

  @override
  String playlistsErrorUpdateGeneric(String details) {
    return 'No se pudo actualizar la lista: $details';
  }

  @override
  String get playlistsErrorEmptyResponse => 'El proveedor devolvió una lista vacía. Se conservan los datos anteriores.';

  @override
  String playerReconnectingMulti(int attempt) {
    return 'Reconectando ($attempt)…';
  }

  @override
  String get playerReconnecting => 'Reconectando…';

  @override
  String get playerLoading => 'Cargando…';

  @override
  String get playerStreamRepeatedError => 'La emisión se desconecta continuamente. Prueba con otro canal.';

  @override
  String get playerReconnectTooltip => 'Reconectar';

  @override
  String get playerSubtitleEnable => 'Activar subtítulos con IA';

  @override
  String get playerSubtitleDisable => 'Desactivar subtítulos con IA';

  @override
  String get playerMuteTooltip => 'Silenciar';

  @override
  String get playerUnmuteTooltip => 'Activar sonido';

  @override
  String get playerLiveLabel => 'EN DIRECTO';

  @override
  String get playerSeekHint => '◄ 10s ►';

  @override
  String get playerAudioTrackTooltip => 'Pista de audio';

  @override
  String get playerAudioTrackDialog => 'Pista de audio';

  @override
  String playerAudioTrackFallback(int n) {
    return 'Pista $n';
  }

  @override
  String get playerSpeedDialog => 'Velocidad de reproducción';

  @override
  String get playerSubtitleDialogTitle => 'Subtítulos';

  @override
  String get playerSubtitleAi => 'Subtítulos con IA';

  @override
  String get playerSubtitleAiActive => '(Activos)';

  @override
  String playerSubtitleEmbedded(int n) {
    return 'Incrustados $n';
  }

  @override
  String get playerSubtitleOff => 'Desactivados';

  @override
  String get playerScreenSizeTooltip => 'Tamaño de pantalla';

  @override
  String get playerScreenSizeDialog => 'Tamaño de pantalla';

  @override
  String get playerFitOriginal => 'Original';

  @override
  String get playerFitCover => 'Rellenar pantalla (recortar)';

  @override
  String get playerFitStretch => 'Estirar';

  @override
  String get playerResolutionTooltip => 'Resolución';

  @override
  String get playerResolutionDialog => 'Resolución';

  @override
  String get playerResolutionAuto => 'Automática';

  @override
  String get playerSingleQuality => 'Esta emisión ofrece una sola calidad.';

  @override
  String get disclaimerWelcome => 'Bienvenido';

  @override
  String get disclaimerBodyEn => 'IPTV AI Player es un reproductor multimedia para tus propias listas M3U y fuentes de Xtream Codes.\n\nEsta aplicación no proporciona, aloja ni distribuye ningún contenido. Debes aportar tu propia URL de lista obtenida legalmente.';

  @override
  String get disclaimerBodyTr => 'IPTV AI Player es un reproductor multimedia para tus propias listas M3U y fuentes de Xtream Codes. La aplicación no aloja ni distribuye ningún contenido.';

  @override
  String get disclaimerLegalNoticeButton => 'Aviso legal';

  @override
  String get disclaimerContinue => 'Continuar';

  @override
  String get disclaimerFooter => 'Al continuar aceptas el aviso legal.';

  @override
  String get legalNoticeTitle => 'Aviso legal';

  @override
  String get legalSection1Title => '1. Naturaleza de la aplicación';

  @override
  String get legalSection1En => 'IPTV AI Player es un reproductor multimedia de uso general (similar a VLC o MX Player). NO proporciona, aloja, distribuye ni redirige a ninguna emisión de televisión, película, serie, evento deportivo u otro contenido. La aplicación es una herramienta que reproduce URL de listas M3U / M3U8 o credenciales de Xtream Codes facilitadas por el usuario.';

  @override
  String get legalSection1Tr => 'IPTV AI Player es un reproductor multimedia de uso general. No proporciona, aloja ni distribuye ningún contenido; solo reproduce las URL de listas o las credenciales de Xtream que facilita el usuario.';

  @override
  String get legalSection2Title => '2. Responsabilidad sobre el contenido';

  @override
  String get legalSection2En => 'El usuario es el único responsable de todo el contenido al que accede mediante la aplicación. El desarrollador no tiene conocimiento de ese contenido ni asume responsabilidad alguna por él.';

  @override
  String get legalSection2Tr => 'El usuario es el único responsable de cualquier contenido al que acceda mediante la aplicación. El desarrollador no tiene visibilidad sobre ese contenido ni asume responsabilidad por él.';

  @override
  String get legalSection3Title => '3. Marco legal turco';

  @override
  String get legalSection3Item1 => 'Artículos 71-72 de la Ley n.º 5846 (FSEK, Turquía): la infracción de derechos de autor conlleva sanciones civiles y penales.';

  @override
  String get legalSection3Item2 => 'Artículo 163/2 del Código Penal turco: uso no autorizado de emisiones cifradas o sin cifrar.';

  @override
  String get legalSection3Item3 => 'Artículo adicional 4 de la FSEK: infracción de derechos de autor en internet.';

  @override
  String get legalSection3Item4 => 'El RTÜK y la BTK pueden imponer bloqueos de acceso conforme a las Leyes n.º 6112 y 5651.';

  @override
  String get legalSection4Title => '4. Obligaciones del usuario';

  @override
  String get legalSection4Body => 'Al usar esta aplicación reconoces que solo accederás a contenido al que estés legalmente suscrito, que no accederás sin permiso a contenido protegido por derechos de autor y que no usarás la aplicación para emisiones pirata o servicios IPTV sin licencia.';

  @override
  String get legalSection5Title => '5. Protección de datos';

  @override
  String get legalSection5Body => 'La aplicación almacena las URL de tus listas y tus credenciales únicamente en local, en tu dispositivo. No se comparten con terceros.';

  @override
  String get legalSection6Title => '6. Limitación de responsabilidad';

  @override
  String get legalSection6Body => 'La aplicación se ofrece \"TAL CUAL\". El desarrollador no se hace responsable de ningún daño derivado del uso de la aplicación.';

  @override
  String get legalSection7Title => '7. Colaboración legal';

  @override
  String get legalSection7Body => 'El desarrollador cumple con los requerimientos legales de las autoridades competentes (RTÜK, BTK, fiscalías).';

  @override
  String get legalReminder => 'Recordatorio: usar esta aplicación para acceder a contenido no autorizado o protegido por derechos de autor es ilegal. El usuario asume toda la responsabilidad legal.';

  @override
  String get searchHint => 'Buscar canales, películas, series…';

  @override
  String get searchMinChars => 'Introduce al menos 2 caracteres';

  @override
  String searchNoResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get categoryFilterTitle => 'Filtro de categorías';

  @override
  String get categoryFilterShowAll => 'Mostrar todas';

  @override
  String get categoryFilterHideAll => 'Ocultar todas';

  @override
  String get categoryFilterEmpty => 'Aún no hay categorías';

  @override
  String get categoryFilterSectionLive => 'En directo';

  @override
  String get categoryFilterSectionMovie => 'Películas';

  @override
  String get categoryFilterSectionSeries => 'Series';

  @override
  String categoryFilterCount(String label, int active, int total) {
    return '$label ($active / $total activas)';
  }

  @override
  String get seriesEmptyCategory => 'No hay series en esta categoría';

  @override
  String seriesSeasonCount(int count) {
    return '$count temporada(s)';
  }

  @override
  String get seriesSpecialSeason => 'Especiales';

  @override
  String seriesSeasonNumber(int n) {
    return 'Temporada $n';
  }

  @override
  String seriesEpisodeCount(int count) {
    return '$count episodios';
  }

  @override
  String get homeRemoveFromHistoryTitle => 'Quitar del historial de reproducción';

  @override
  String homeRemoveFromHistoryMessage(String name) {
    return '$name se quitará de tu historial de reproducción. ¿Continuar?';
  }

  @override
  String get homeRemoveFromHistoryAction => 'Quitar';

  @override
  String homeRemoveFromHistorySnack(String name) {
    return '$name se ha quitado del historial de reproducción';
  }

  @override
  String homeFavoriteAdded(String name) {
    return '$name añadido a favoritos';
  }

  @override
  String homeFavoriteRemoved(String name) {
    return '$name quitado de favoritos';
  }

  @override
  String get homeRowPopular => 'Popular';

  @override
  String get homeRowWatchedMovies => 'Películas que has visto';

  @override
  String get homeRowWatchedSeries => 'Series que has visto';

  @override
  String get badgeMovieUppercase => 'PELÍCULA';

  @override
  String get badgeSeriesUppercase => 'SERIE';

  @override
  String get settingsEpgPresetsTitle => 'Predefinidos';

  @override
  String get menuMyPlaylists => 'Mis listas';

  @override
  String get menuEpgSettings => 'Ajustes del EPG';

  @override
  String get menuNewlyAdded => 'Añadidos recientemente';

  @override
  String get menuContinueWatching => 'Seguir viendo';

  @override
  String get authSignInTitle => 'Iniciar sesión';

  @override
  String get authSignUpTitle => 'Crear cuenta';

  @override
  String get authAccountTitle => 'Mi cuenta';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authSignInButton => 'Iniciar sesión';

  @override
  String get authSignUpButton => 'Crear cuenta';

  @override
  String get authSignOutButton => 'Cerrar sesión';

  @override
  String get authForgotPassword => 'He olvidado mi contraseña';

  @override
  String get authResetPasswordTitle => 'Restablecer contraseña';

  @override
  String get authResetPasswordHint => 'Te enviaremos un enlace de restablecimiento a tu correo.';

  @override
  String get authResetPasswordSent => 'Enlace de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String get authNoAccountQuestion => '¿No tienes cuenta? Regístrate';

  @override
  String get authHaveAccountQuestion => 'Ya tengo una cuenta';

  @override
  String get authOrDivider => 'o';

  @override
  String get authSignInWithGoogle => 'Continuar con Google';

  @override
  String get authSignInWithApple => 'Continuar con Apple';

  @override
  String get authAcceptTerms => 'Acepto las condiciones de uso y la política de privacidad';

  @override
  String get authViewTerms => 'Ver condiciones';

  @override
  String get authErrorInvalidEmail => 'Dirección de correo no válida';

  @override
  String get authErrorWeakPassword => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authErrorPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get authErrorEmailInUse => 'Este correo ya está en uso';

  @override
  String get authErrorWrongPassword => 'Correo o contraseña incorrectos';

  @override
  String get authErrorTooManyRequests => 'Demasiados intentos. Inténtalo más tarde.';

  @override
  String get authErrorNetwork => 'Error de red. Comprueba tu conexión.';

  @override
  String authErrorGeneric(String message) {
    return 'Algo salió mal: $message';
  }

  @override
  String get authVerifyEmailHint => 'Hemos enviado un enlace de verificación a tu correo.';

  @override
  String get authAppleHiddenEmail => 'Usuario de Apple';

  @override
  String get authAppleHiddenEmailHint => 'Correo mantenido en privado por Apple: no se comparte';

  @override
  String get authResendVerification => 'Reenviar verificación';

  @override
  String get authChangePassword => 'Cambiar contraseña';

  @override
  String get authDeleteAccount => 'Eliminar cuenta';

  @override
  String get authDeleteAccountWarning => 'Eliminar tu cuenta borra de forma permanente todos tus datos en la nube. Esta acción no se puede deshacer.';

  @override
  String get authDeleteAccountConfirm => 'Sí, eliminar mi cuenta';

  @override
  String get authAccountSection => 'Cuenta';

  @override
  String get authNotSignedIn => 'Sesión no iniciada';

  @override
  String get authSignInPromptTitle => 'Crear cuenta → Probar Pro';

  @override
  String get authSignInPromptDesc => 'Regístrate para desbloquear listas ilimitadas, subtítulos con IA y sincronización entre dispositivos.';

  @override
  String get authProActive => 'Miembro Pro';

  @override
  String get authFreeTier => 'Plan gratuito';

  @override
  String get authUpgradeToPro => 'Pasar a Pro';

  @override
  String get authRequiresRecentLogin => 'Esta acción requiere un inicio de sesión reciente. Vuelve a iniciar sesión.';

  @override
  String get paywallTitle => 'Hazte Pro y quita los límites';

  @override
  String get paywallSubtitle => 'Subtítulos con IA, listas ilimitadas y sincronización entre dispositivos: todo en una sola compra.';

  @override
  String get paywallBenefitUnlimitedPlaylists => 'Listas ilimitadas';

  @override
  String get paywallBenefitUnlimitedPlaylistsDesc => 'Xtream, M3U, Stalker: sin límites';

  @override
  String get paywallBenefitAiSubtitles => 'Subtítulos con IA';

  @override
  String get paywallBenefitAiSubtitlesDesc => 'Más de 100 idiomas (40 horas al mes)';

  @override
  String get paywallBenefitCloudSync => 'Sincronización en la nube';

  @override
  String get paywallBenefitCloudSyncDesc => 'Favoritos e historial en todos tus dispositivos';

  @override
  String get paywallBenefitTvApps => 'TV + móvil';

  @override
  String get paywallBenefitTvAppsDesc => 'Android TV, Google TV, iPhone, iPad';

  @override
  String get paywallPlanMonthly => 'Mensual';

  @override
  String get paywallPlanYearly => 'Anual';

  @override
  String get paywallPlanLifetime => 'De por vida';

  @override
  String get paywallBadgeBest => 'MEJOR';

  @override
  String get paywallBadgePopular => 'POPULAR';

  @override
  String get paywallSubscribeButton => 'Hazte Pro';

  @override
  String get paywallRestoreButton => 'Restaurar compras';

  @override
  String get paywallSignInRequired => 'Inicia sesión para continuar.';

  @override
  String get paywallSignInButton => 'Inicia sesión primero';

  @override
  String get paywallTermsFooter => 'Las suscripciones se renuevan automáticamente. Gestiónalas en Ajustes.';

  @override
  String get paywallPrivacyLink => 'Política de privacidad';

  @override
  String get paywallTermsLink => 'Condiciones de uso';

  @override
  String get paywallPurchaseSuccess => 'Pro activado. ¡Que lo disfrutes!';

  @override
  String get paywallPurchaseCancelled => 'Compra cancelada.';

  @override
  String paywallPurchaseError(String message) {
    return 'La compra ha fallado: $message';
  }

  @override
  String get paywallNotConfigured => 'Las compras aún no están configuradas. Inténtalo más tarde.';

  @override
  String get paywallNoOfferings => 'No hay ofertas disponibles.';

  @override
  String get paywallTriggerSecondPlaylist => 'Se requiere Pro para una segunda lista';

  @override
  String get paywallTriggerAiSubtitle => 'Se requiere Pro para los subtítulos con IA';

  @override
  String get paywallTriggerCloudSync => 'Se requiere Pro para la sincronización en la nube';

  @override
  String get welcomeTitle => 'Bienvenido';

  @override
  String get welcomeSubtitle => 'Películas, series y televisión en directo ilimitadas te están esperando.';

  @override
  String get welcomeFeatureUnlimited => 'Canales y favoritos ilimitados';

  @override
  String get welcomeFeatureSubtitles => 'Subtítulos inteligentes (más de 100 idiomas)';

  @override
  String get welcomeFeatureSync => 'Sincronización entre dispositivos';

  @override
  String get welcomeStartFreeButton => 'Crear cuenta → Probar Pro';

  @override
  String get welcomeSkipButton => 'Omitir por ahora';

  @override
  String get welcomeSignInLink => 'Ya tengo una cuenta';

  @override
  String get watchlistTitle => 'Lista de seguimiento';

  @override
  String get watchlistEmpty => 'Tu lista está vacía';

  @override
  String get watchlistEmptyHint => 'Cuando guardes una película o serie, aparecerá aquí.';

  @override
  String get themePickerTitle => 'Tema';

  @override
  String get themeDefaultDark => 'Oscuro predeterminado';

  @override
  String get themeDefaultLight => 'Claro predeterminado';

  @override
  String get themeCrimson => 'Amanecer carmesí';

  @override
  String get themeRoyal => 'Púrpura real';

  @override
  String get themeForest => 'Bosque profundo';

  @override
  String get themeOcean => 'Azul océano';

  @override
  String get parentalLockTitle => 'Control parental';

  @override
  String get parentalLockEnable => 'Activar control parental';

  @override
  String get parentalLockEnabledHint => 'Se necesita el PIN para las categorías bloqueadas.';

  @override
  String get parentalLockSetupFirst => 'Crea primero un PIN de 4 dígitos.';

  @override
  String get parentalSetupPin => 'Crear PIN';

  @override
  String get parentalChangePin => 'Cambiar PIN';

  @override
  String get parentalRemovePin => 'Quitar el control parental';

  @override
  String get parentalLockedCategoriesTitle => 'Categorías que bloquear';

  @override
  String get parentalNoCategories => 'Aún no hay categorías. Carga primero una lista.';

  @override
  String get parentalEnterPin => 'Introduce el PIN';

  @override
  String get parentalNewPin => 'PIN nuevo';

  @override
  String get parentalCurrentPin => 'PIN actual';

  @override
  String get parentalConfirmPin => 'Confirmar PIN';

  @override
  String get parentalPinIncorrect => 'PIN incorrecto';

  @override
  String get parentalPinFourDigits => 'El PIN debe tener 4 dígitos';

  @override
  String get parentalPinMismatch => 'Los PIN no coinciden';

  @override
  String get parentalPinChanged => 'PIN actualizado';

  @override
  String get parentalSubmit => 'Aceptar';

  @override
  String get parentalNext => 'Siguiente';

  @override
  String get cloudSyncTitle => 'Sincronización en la nube';

  @override
  String get cloudSyncProRequired => 'Se requiere una suscripción Pro';

  @override
  String get cloudSyncSignInRequired => 'Inicia sesión y luego sincroniza';

  @override
  String get cloudSyncNever => 'Nunca sincronizado';

  @override
  String get cloudSyncSyncNow => 'Sincronizar ahora';

  @override
  String get cloudSyncJustNow => 'ahora mismo';

  @override
  String cloudSyncMinutesAgo(int n) {
    return 'hace $n min';
  }

  @override
  String cloudSyncHoursAgo(int n) {
    return 'hace $n h';
  }

  @override
  String cloudSyncDaysAgo(int n) {
    return 'hace $n d';
  }

  @override
  String cloudSyncLastAt(String when) {
    return 'Última sincronización: $when';
  }

  @override
  String get epgGuideTitle => 'Guía de TV';

  @override
  String get epgToday => 'Hoy';

  @override
  String get epgYesterday => 'Ayer';

  @override
  String get epgTomorrow => 'Mañana';

  @override
  String get epgRowEmpty => 'No hay programas para este canal';

  @override
  String get epgNoData => 'No hay datos de EPG';

  @override
  String get epgNoDataHint => 'Ve a Ajustes → EPG, indica una URL y toca \'Actualizar ahora\'.';

  @override
  String epgError(String msg) {
    return 'Error del EPG: $msg';
  }

  @override
  String get epgAutoRefreshTitle => 'Actualización automática';

  @override
  String get epgAutoRefreshOff => 'Desactivada';

  @override
  String epgAutoRefreshEvery(int h) {
    return 'Cada $h h';
  }

  @override
  String get playerPipTooltip => 'Imagen en imagen (Pro)';

  @override
  String get playerPipUnavailable => 'Este dispositivo no admite imagen en imagen';

  @override
  String get playerPipEntered => 'Reproduciendo en ventana pequeña';

  @override
  String get playerAirplayTooltip => 'AirPlay (audio)';

  @override
  String get playerAirplayUnavailable => 'AirPlay no está disponible en este dispositivo';

  @override
  String get playerAirplayAudioOnlyHint => 'AirPlay envía el audio al televisor. Para el vídeo, usa Centro de control > Duplicar pantalla.';

  @override
  String get playerCastTooltip => 'Enviar (próximamente)';

  @override
  String get settingsPipSection => 'Imagen en imagen';

  @override
  String get settingsPipAuto => 'PiP automático con el botón Inicio';

  @override
  String get settingsPipAutoSubtitle => 'Pro: con el reproductor abierto, al pulsar Inicio la reproducción pasa a una ventana pequeña';

  @override
  String get settingsAdsSection => 'Anuncios';

  @override
  String get settingsAdsRemoved => 'Pro: sin anuncios';

  @override
  String get settingsAdsFreeNotice => 'La versión gratuita muestra un banner en la parte inferior. Suscríbete a Pro para una experiencia sin anuncios.';

  @override
  String get settingsProSection => 'Funciones Pro';

  @override
  String get settingsContentSection => 'Contenido';

  @override
  String get settingsPlayerSection => 'Reproductor';

  @override
  String get settingsLegalNotice => 'Aviso legal';

  @override
  String get settingsDataDeletion => 'Solicitud de eliminación de datos';

  @override
  String get settingsDataDeletionSubtitle => 'Solicitud de eliminación de cuenta y datos';

  @override
  String get settingsTapToSignIn => 'Inicia sesión o crea una cuenta';

  @override
  String get commonHide => 'Ocultar';

  @override
  String get commonShow => 'Mostrar';

  @override
  String get profileSwitcherTitle => 'Perfiles';

  @override
  String get profileDefaultName => 'Predeterminado';

  @override
  String get profileAdd => 'Perfil nuevo';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileDelete => 'Eliminar perfil';

  @override
  String get profileDeleteConfirm => 'Se eliminarán este perfil y sus favoritos y lista de seguimiento privados. ¿Continuar?';

  @override
  String get profileNameLabel => 'Nombre del perfil';

  @override
  String get profileEmptyName => 'El nombre del perfil no puede estar vacío';

  @override
  String get profileSwitched => 'Perfil cambiado';

  @override
  String get profileMaxFreeReached => 'La versión gratuita admite 1 perfil. Pro desbloquea perfiles ilimitados.';

  @override
  String get profileSection => 'Perfil';

  @override
  String get otherAppsTitle => 'Más apps nuestras';

  @override
  String get otherAppsSubtitle => 'Otras apps creadas por nuestro equipo';

  @override
  String get otherAppsEmpty => 'No se pudo cargar la lista. Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get otherAppsRetry => 'Reintentar';

  @override
  String get otherAppsOpenFailed => 'No se pudo abrir la tienda.';

  @override
  String get otherAppsGateTitle => 'Control parental';

  @override
  String get otherAppsGateQuestion => 'Para continuar, escribe el resultado:';

  @override
  String get otherAppsCancel => 'Cancelar';

  @override
  String get otherAppsContinue => 'Continuar';
}
