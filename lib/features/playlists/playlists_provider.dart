import 'dart:async';
import 'dart:ui' show PlatformDispatcher, Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/device_tier.dart';
import '../../data/models/playlist_model.dart';
import '../../data/repositories/hidden_categories_repository.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/services/playlist_sync.dart';
import '../../data/services/sync_cancel.dart';
import '../../l10n/generated/app_localizations.dart';
import '../billing/logic/playlist_limit.dart';
import '../billing/providers/purchases_providers.dart';
import '../home/home_provider.dart';
import 'sync_coordinator.dart';

final playlistsProvider =
    AsyncNotifierProvider<PlaylistsNotifier, List<PlaylistModel>>(
  PlaylistsNotifier.new,
);

/// Playlist listesi + sync orkestrasyonu. UI'dan bağımsız (otomatik yenileme
/// ve cloud sync de kullanır).
class PlaylistsNotifier extends AsyncNotifier<List<PlaylistModel>> {
  /// Çalışan sync'ler + sync sırasında düzenleme (takip sync'i) / silme
  /// (iptal + temizlik) durumu.
  final _coord = SyncCoordinator();
  final _lastError = <String, String>{};
  int _lastSyncCount = 0;
  final _cloudInitialSynced = <String>{};
  int get lastSyncCount => _lastSyncCount;

  /// Yeni eklenen, ilk sync'i bekleyen playlist'ler — `playlist_added`
  /// analytics'i gercek kanal sayisiyla ilk basarili sync'te atilir.
  final _pendingAddAnalytics = <String>{};

  final ValueNotifier<String> _progressMessage = ValueNotifier('');
  ValueListenable<String> get progressMessage => _progressMessage;

  bool isSyncing(String id) => _coord.isRunning(id);
  String? lastError(String id) => _lastError[id];

  @override
  Future<List<PlaylistModel>> build() =>
      ref.read(playlistRepoProvider).getAll();

  /// Aktif dil (ayar veya cihaz) için yerelleştirme — notifier'da context yok.
  AppLocalizations _l10n() {
    final loc = ref.read(localeProvider) ?? PlatformDispatcher.instance.locale;
    try {
      return lookupAppLocalizations(Locale(loc.languageCode));
    } catch (_) {
      return lookupAppLocalizations(const Locale('tr'));
    }
  }

  Future<void> reload() async {
    final current = state.value;
    state = current != null ? AsyncData(current) : const AsyncLoading();
    final fresh = await ref.read(playlistRepoProvider).getAll();
    state = AsyncData(fresh);
  }

  void _touch() {
    if (state.value != null) state = AsyncData(List.of(state.value!));
  }

  Future<void> add(PlaylistModel p) async {
    // Emniyet agi: UI gate'i (ensurePlaylistAddAllowed) atlanirsa da cihaz /
    // Pro limiti asilmasin (Android HomeViewModel.maxPlaylistCount).
    final limit = playlistLimitFor(
        isPro: ref.read(isProProvider), tier: DeviceProfile.tier);
    final count = (state.value ?? await ref.read(playlistRepoProvider).getAll())
        .length;
    if (count >= limit) throw PlaylistLimitReachedException(limit);
    final saved = await ref.read(playlistRepoProvider).insert(p);
    _pendingAddAnalytics.add(saved.id);
    state = AsyncData([...?state.value, saved]);
    if (ref.read(activePlaylistProvider).isEmpty) {
      ref.read(activePlaylistProvider.notifier).set(saved.id);
    }
    // Arka plan sync — dialog anında kapanır, kanallar akışlı dolar.
    unawaited(syncSilently(saved));
  }

  /// UI'sız sync (ekleme, otomatik yenileme, cloud). Hata [lastError]'a düşer.
  Future<String?> syncSilently(PlaylistModel p) => sync(p, _l10n());

  /// Returns: null on success, user-facing error message on failure.
  /// Aynı playlist için sync zaten sürüyorsa yeni istek yutulmaz: bitince
  /// güncel DB kaydıyla BİR takip sync'i çalışır (null döner; UI
  /// [isSyncing] ile "sırada" gösterebilir).
  Future<String?> sync(PlaylistModel p, AppLocalizations l) async {
    if (!_coord.begin(p.id)) {
      _coord.requestResync(p.id);
      return null;
    }
    _lastError.remove(p.id);
    _touch();
    String? errorMessage;
    try {
      // Her zaman DB'deki güncel kayıt (etag / epgUrl / damgalar).
      final fresh = await ref.read(playlistRepoProvider).getById(p.id) ?? p;
      final result = await PlaylistSync(
        ref.read(channelRepoProvider),
        ref.read(playlistRepoProvider),
        isCancelled: () => _coord.isCancelled(p.id),
      ).run(
        fresh,
        l,
        onProgress: (m) => _progressMessage.value = m,
        // İlk batch yazıldı → Home hemen dolsun (seçim korunur).
        onFirstBatch: () => unawaited(_reloadHome()),
      );
      _lastSyncCount = result.count;
      if (_pendingAddAnalytics.remove(p.id)) {
        Analytics.playlistAdded(type: fresh.type, channelCount: result.count);
      }
      if (result.partialError != null) {
        _lastError[p.id] = result.partialError!;
      }
      await _reloadHome();
    } on SyncCancelledException {
      // Sync sırasında playlist silindi — hata değil; temizlik finally'de.
    } on PlaylistSyncException catch (e) {
      errorMessage = e.userMessage;
      _lastError[p.id] = errorMessage;
      await _reloadHome();
    } catch (e) {
      errorMessage = PlaylistSync.errorMessage(e, l);
      _lastError[p.id] = errorMessage;
    } finally {
      final end = _coord.end(p.id);
      _progressMessage.value = '';
      if (end.cancelled) await _purgeDeleted(p.id);
      await reload();
      // Sync sürerken düzenlendi → güncel kayıtla yeniden indir.
      if (end.resync) unawaited(syncSilently(p));
    }
    return errorMessage;
  }

  /// Sync sırasında silinen playlist: iptalden önce yazılmış (yetim)
  /// satırları tekrar sil.
  Future<void> _purgeDeleted(String id) async {
    _lastError.remove(id);
    _pendingAddAnalytics.remove(id);
    try {
      await ref.read(channelRepoProvider).deleteByPlaylist(id);
      await ref.read(epgRepoProvider).deleteByPlaylist(id);
    } catch (e) {
      if (kDebugMode) debugPrint('[Playlists] orphan cleanup failed: $e');
    }
  }

  Future<void> _reloadHome() async {
    try {
      await ref.read(homeProvider.notifier).reloadPreservingSelection();
    } catch (_) {
      // Home henüz kurulmadıysa sorun değil.
    }
  }

  /// Düzenleme ekranından kayıt. Bağlantı bilgisi değiştiyse (URL / kullanıcı
  /// / şifre / içerik türü) kanallar koşulsuz yeniden indirilir.
  Future<String?> updatePlaylist(PlaylistModel updated) async {
    final repo = ref.read(playlistRepoProvider);
    final old = await repo.getById(updated.id);
    final changed = old == null ||
        old.url.trim() != updated.url.trim() ||
        old.username != updated.username ||
        old.password != updated.password ||
        old.allowedTypes != updated.allowedTypes;
    final toSave = changed
        ? updated.copyWith(etag: '', lastModified: '')
        : updated;
    await repo.update(toSave);
    await reload();
    await _reloadHome();
    if (!changed) return null;
    return sync(toSave, _l10n());
  }

  /// Playlist sil. [fromCloud] false → yalnız cihaz (Android "Cihazdan Sil":
  /// bulut kaydı durur). true → tombstone + Firestore silme.
  Future<void> delete(String id, {bool fromCloud = true}) async {
    // Çalışan sync'i durdur: onBatch artık yazmaz; bittiğinde kanallar
    // yeniden silinir (bkz. sync finally → _purgeDeleted).
    _coord.cancel(id);
    final filtered = (state.value ?? []).where((p) => p.id != id).toList();
    state = AsyncData(filtered);

    final repo = ref.read(playlistRepoProvider);
    if (fromCloud) {
      await repo.delete(id);
    } else {
      await repo.deleteLocalOnly(id);
    }
    await ref.read(channelRepoProvider).deleteByPlaylist(id);
    try {
      await ref.read(epgRepoProvider).deleteByPlaylist(id);
      await HiddenCategoriesRepository(ref.read(settingsRepoProvider)).clear(id);
    } catch (_) {}

    final active = ref.read(activePlaylistProvider);
    if (active == id || filtered.isEmpty) {
      ref.read(activePlaylistProvider.notifier).set(
            filtered.isEmpty ? '' : filtered.first.id,
          );
    }
    ref.invalidate(homeProvider);
  }

  /// Bulut kaydı var mı? (Android isPlaylistInCloud) — bilinmiyorsa null.
  Future<bool?> isInCloud(String id) async {
    try {
      final remote = await CloudSyncService.pullPlaylists();
      return remote.any((m) => m['id'] == id);
    } catch (_) {
      return null;
    }
  }

  /// Cloud'dan gelen ama lokalde kanalı olmayan playlist'leri sırayla indirir
  /// (Android: bulut sync sonrası ilk yükleme).
  Future<int> syncPlaylistsWithoutChannels() async {
    final repo = ref.read(playlistRepoProvider);
    final channels = ref.read(channelRepoProvider);
    var done = 0;
    for (final p in await repo.getAll()) {
      if (await channels.countByPlaylist(p.id) > 0) continue;
      // Oturumda bir kez — sürekli hata veren liste her ön plana dönüşte
      // yeniden indirilmesin.
      if (!_cloudInitialSynced.add(p.id)) continue;
      final err = await syncSilently(p);
      if (err == null) done++;
    }
    if (ref.read(activePlaylistProvider).isEmpty) {
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        ref.read(activePlaylistProvider.notifier).set(all.first.id);
      }
    }
    await reload();
    await _reloadHome();
    return done;
  }
}
