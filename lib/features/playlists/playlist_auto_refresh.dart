import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/utils/device_tier.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/settings_repository.dart';
import 'playlists_provider.dart';

/// Playlist otomatik yenileme aralığı — Android SettingsScreen seçenekleri.
enum RefreshInterval {
  off(0),
  onLaunch(-1),
  day(24),
  week(168),
  month(720),
  year(8760);

  final int hours;
  const RefreshInterval(this.hours);

  static RefreshInterval fromHours(int h) =>
      values.firstWhere((v) => v.hours == h, orElse: () => day);
}

/// Yarım kalan denemeden sonra otomatik yenilemenin bekleyeceği süre
/// (Android AppPreferences.FAILED_REFRESH_COOLDOWN_MS).
const failedRefreshCooldownMs = 30 * 60 * 1000;

/// Android HomeViewModel.shouldAutoRefresh paritesi (saf, testli).
bool shouldAutoRefresh({
  required int intervalHours,
  required int lastRefreshAt,
  required int lastAttemptAt,
  required int nowMs,
  required bool refreshedThisSession,
  bool force = false,
}) {
  // Son deneme başarılı damgadan yeniyse yarım kalmıştır → cooldown (force dahil).
  if (lastAttemptAt > lastRefreshAt &&
      nowMs - lastAttemptAt < failedRefreshCooldownMs) {
    return false;
  }
  if (force) return true;
  if (intervalHours == 0) return false;
  if (intervalHours == -1) return !refreshedThisSession;
  if (lastRefreshAt == 0) return true;
  return nowMs - lastRefreshAt >= intervalHours * 3600 * 1000;
}

/// Kayıtlı değer yoksa varsayılan 1 gün; zayıf cihazda haftalık ve
/// "Her Açılışta" haftalığa taşınır (Android constrained-device kuralı).
int defaultRefreshHours({required bool lowDevice, required int? stored}) {
  if (stored == null) return lowDevice ? 168 : 24;
  if (lowDevice && stored == -1) return 168;
  return stored;
}

/// State = aralık (saat; 0 kapalı, -1 her açılışta).
///
/// Settings dalgası için API:
///   `ref.watch(playlistAutoRefreshProvider)` → mevcut saat
///   `ref.read(playlistAutoRefreshProvider.notifier).setInterval(RefreshInterval.week.hours)`
class PlaylistAutoRefreshController extends Notifier<int> {
  final _refreshedThisSession = <String>{};
  bool _loaded = false;

  @override
  int build() => 24;

  Future<void> loadFromDb() async {
    final raw =
        await ref.read(settingsRepoProvider).get(SettingsKeys.refreshIntervalH);
    final low = DeviceProfile.tier == DeviceTier.low;
    final value = defaultRefreshHours(lowDevice: low, stored: int.tryParse(raw ?? ''));
    state = value;
    _loaded = true;
    if (raw == null || '$value' != raw) {
      await ref
          .read(settingsRepoProvider)
          .set(SettingsKeys.refreshIntervalH, '$value');
    }
  }

  Future<void> setInterval(int hours) async {
    state = hours;
    await ref
        .read(settingsRepoProvider)
        .set(SettingsKeys.refreshIntervalH, '$hours');
  }

  /// Uygulama açılışı: aktif playlist'i (yalnız onu — Android) kontrol eder.
  Future<void> onLaunch() async {
    if (!_loaded) await loadFromDb();
    await _checkActive(force: state == -1);
  }

  /// Uygulama ön plana döndü: periyodik aralık dolduysa aktif playlist.
  Future<void> onResume() async {
    if (!_loaded) return;
    if (state == -1) return; // "her açılışta" yalnız soğuk açılışta
    await _checkActive();
  }

  /// Playlist seçimi değişince (Android selectPlaylist → autoRefreshPlaylist).
  Future<void> onPlaylistSelected(String id) async {
    if (!_loaded) return;
    final p = await ref.read(playlistRepoProvider).getById(id);
    if (p != null) await maybeRefresh(p);
  }

  Future<void> _checkActive({bool force = false}) async {
    try {
      final all = await ref.read(playlistRepoProvider).getAll();
      if (all.isEmpty) return;
      final activeId = ref.read(activePlaylistProvider);
      final p = all.firstWhere((x) => x.id == activeId,
          orElse: () => all.first);
      await maybeRefresh(p, force: force);
    } catch (e) {
      debugPrint('[AutoRefresh] check failed: $e');
    }
  }

  Future<void> maybeRefresh(PlaylistModel p, {bool force = false}) async {
    if (!const {'m3u', 'xtream', 'stalker'}.contains(p.type)) return;
    final due = shouldAutoRefresh(
      intervalHours: state,
      lastRefreshAt: p.lastRefreshAt,
      lastAttemptAt: p.lastRefreshAttemptAt,
      nowMs: DateTime.now().millisecondsSinceEpoch,
      refreshedThisSession: _refreshedThisSession.contains(p.id),
      force: force,
    );
    if (!due) return;
    _refreshedThisSession.add(p.id);
    await ref.read(playlistsProvider.notifier).syncSilently(p);
  }
}

final playlistAutoRefreshProvider =
    NotifierProvider<PlaylistAutoRefreshController, int>(
  PlaylistAutoRefreshController.new,
);
