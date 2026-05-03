import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/epg_repository.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import '../theme/app_theme.dart';

// ── Repositories ─────────────────────────────────────────────────────────────

final playlistRepoProvider = Provider<PlaylistRepository>(
  (_) => PlaylistRepository(),
);

final channelRepoProvider = Provider<ChannelRepository>(
  (_) => ChannelRepository(),
);

final settingsRepoProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
);

final epgRepoProvider = Provider<EpgRepository>(
  (_) => EpgRepository(),
);

final watchlistRepoProvider = Provider<WatchlistRepository>(
  (_) => WatchlistRepository(),
);

final profileRepoProvider = Provider<ProfileRepository>(
  (_) => ProfileRepository(),
);

// ── Active profile (Phase 6) ─────────────────────────────────────────────────
//
// Default 'default' — uygulama ilk acilista bu profil aktif. Pro user yeni
// profil olusturup gecis yapabilir; gectikten sonra favorites/watchlist o
// profil bazinda filtrelenir.

class ActiveProfileNotifier extends Notifier<String> {
  @override
  String build() => ProfileRepository.defaultProfileId;

  void setActive(String profileId) {
    state = profileId;
    ref.read(settingsRepoProvider).set(SettingsKeys.activeProfileId, profileId);
  }

  Future<void> loadFromDb() async {
    final raw = await ref.read(settingsRepoProvider).get(SettingsKeys.activeProfileId);
    if (raw != null && raw.isNotEmpty) {
      // Profilin hala var oldugunu dogrula — silinmis olabilir.
      final p = await ref.read(profileRepoProvider).getById(raw);
      state = p?.id ?? ProfileRepository.defaultProfileId;
    }
  }
}

final activeProfileProvider = NotifierProvider<ActiveProfileNotifier, String>(
  ActiveProfileNotifier.new,
);

// ── Theme ─────────────────────────────────────────────────────────────────────

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(settingsRepoProvider).set(SettingsKeys.themeMode, _key(mode));
  }

  Future<void> loadFromDb() async {
    final raw = await ref.read(settingsRepoProvider).get(SettingsKeys.themeMode);
    state = switch (raw) {
      'light'  => ThemeMode.light,
      'system' => ThemeMode.system,
      _        => ThemeMode.dark,
    };
  }

  static String _key(ThemeMode m) => switch (m) {
    ThemeMode.light  => 'light',
    ThemeMode.system => 'system',
    _                => 'dark',
  };
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// ── Premium theme variant ────────────────────────────────────────────────────
//
// Kullanıcının seçtiği özel tema (default + 4 Pro). Pro değilse seçim
// reddedilir, default'a düşer.

class ThemeVariantNotifier extends Notifier<PremiumTheme> {
  @override
  PremiumTheme build() => PremiumTheme.defaultDark;

  void setVariant(PremiumTheme variant) {
    state = variant;
    ref.read(settingsRepoProvider).set(SettingsKeys.themeVariant, variant.key);
  }

  Future<void> loadFromDb() async {
    final raw = await ref.read(settingsRepoProvider).get(SettingsKeys.themeVariant);
    state = PremiumTheme.fromKey(raw);
  }
}

final themeVariantProvider =
    NotifierProvider<ThemeVariantNotifier, PremiumTheme>(
  ThemeVariantNotifier.new,
);

// ── Active playlist ───────────────────────────────────────────────────────────

class ActivePlaylistNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String id) {
    state = id;
    ref.read(settingsRepoProvider).set(SettingsKeys.activePlaylistId, id);
  }

  Future<void> loadFromDb() async {
    final id = await ref.read(settingsRepoProvider).get(SettingsKeys.activePlaylistId);
    if (id != null && id.isNotEmpty) state = id;
  }
}

final activePlaylistProvider = NotifierProvider<ActivePlaylistNotifier, String>(
  ActivePlaylistNotifier.new,
);

// ── Locale ────────────────────────────────────────────────────────────────────
//
// `null` state means "follow system locale". Setting a non-null value persists
// the user's manual override. `loadFromDb()` is called once at startup.

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLocale(Locale? locale) {
    state = locale;
    ref.read(settingsRepoProvider).set(
      SettingsKeys.language,
      locale?.languageCode ?? 'system',
    );
  }

  Future<void> loadFromDb() async {
    final raw = await ref.read(settingsRepoProvider).get(SettingsKeys.language);
    state = switch (raw) {
      'tr' => const Locale('tr'),
      'en' => const Locale('en'),
      'de' => const Locale('de'),
      'ar' => const Locale('ar'),
      _    => null, // 'system' or unset → follow device
    };
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
