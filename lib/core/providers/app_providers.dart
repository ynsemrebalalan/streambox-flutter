import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/channel_repository.dart';
import '../../data/repositories/epg_repository.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../data/repositories/settings_repository.dart';

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
