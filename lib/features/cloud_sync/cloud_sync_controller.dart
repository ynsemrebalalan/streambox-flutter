import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../data/services/cloud_sync_service.dart';
import '../auth/data/auth_state.dart';
import '../auth/providers/auth_providers.dart';
import '../billing/providers/purchases_providers.dart';

/// Cloud Sync UI durumu — Settings ekranında gösterilir.
enum CloudSyncPhase { idle, syncing, error }

class CloudSyncStatus {
  final CloudSyncPhase phase;
  final DateTime?      lastSyncedAt;
  final String?        lastError;

  const CloudSyncStatus({
    this.phase = CloudSyncPhase.idle,
    this.lastSyncedAt,
    this.lastError,
  });

  CloudSyncStatus copyWith({
    CloudSyncPhase? phase,
    DateTime?       lastSyncedAt,
    String?         lastError,
  }) =>
      CloudSyncStatus(
        phase:        phase        ?? this.phase,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        lastError:    lastError    ?? this.lastError,
      );
}

/// Cross-device cloud sync orchestrator.
///
/// Manuel `syncNow()` veya auth state değişiminde otomatik tetiklenir.
/// Yalnızca Pro + authenticated user'da gerçekten Firestore'a yazar/okur;
/// aksi halde no-op (status idle kalır, lastError boş).
class CloudSyncController extends Notifier<CloudSyncStatus> {
  @override
  CloudSyncStatus build() => const CloudSyncStatus();

  bool _eligible() {
    final auth = ref.read(authStateProvider).valueOrNull;
    final isPro = ref.read(isProProvider);
    return isPro && auth is AuthAuthenticated;
  }

  /// Manuel veya app foreground / login sonrası tam senkron.
  /// Pull → merge → (gerekirse) push delta. İlk faz pull-only basit
  /// implementasyon — push tetikleri repository write'larında zaten
  /// fire-and-forget yapılıyor, çift yönlü deltayı bu metod GARANTİ
  /// etmez (bu MVP'nin sınırlamasıdır, P2 sonrası iyileştirilebilir).
  Future<void> syncNow() async {
    if (!_eligible()) {
      // Sessizce no-op; UI Pro değilse zaten sync sekmesini kilitler.
      return;
    }
    state = state.copyWith(phase: CloudSyncPhase.syncing, lastError: null);
    try {
      await _pullAndMerge();
      final now = DateTime.now();
      state = state.copyWith(
        phase: CloudSyncPhase.idle,
        lastSyncedAt: now,
      );
      await ref
          .read(settingsRepoProvider)
          .set('cloud_sync_last_at', now.millisecondsSinceEpoch.toString());
    } catch (e) {
      state = state.copyWith(
        phase: CloudSyncPhase.error,
        lastError: e.toString(),
      );
      debugPrint('[CloudSyncController] syncNow fail: $e');
    }
  }

  Future<void> _pullAndMerge() async {
    final db = await AppDatabase.instance;

    // 1) Playlists — yoksa ekle, varsa updatedAt karşılaştırma yapmıyoruz
    //    (MVP). İleride: cloud.updatedAt > local.addedAt → güncelle.
    final cloudPlaylists = await CloudSyncService.pullPlaylists();
    for (final p in cloudPlaylists) {
      await db.insert(
        'playlists',
        {
          'id':           p['id'] ?? '',
          'name':         p['name'] ?? '',
          'type':         p['type'] ?? 'm3u',
          'url':          p['url'] ?? '',
          'username':     p['username'] ?? '',
          'password':     p['password'] ?? '',
          'allowedTypes': p['allowedTypes'] ?? 'live,movie,series',
          'addedAt':      DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // 2) Favorites — channels.isFavorite=1 işaretle (kanal local'de varsa).
    final cloudFavs = await CloudSyncService.pullFavorites();
    for (final f in cloudFavs) {
      final pid = f['playlistId'] as String?;
      final cid = f['channelId'] as String?;
      if (pid == null || cid == null) continue;
      await db.update(
        'channels',
        {'isFavorite': 1},
        where: 'id = ? AND playlistId = ?',
        whereArgs: [cid, pid],
      );
    }

    // 3) Watchlist — watchlist tablosuna upsert.
    final cloudWl = await CloudSyncService.pullWatchlist();
    for (final w in cloudWl) {
      final pid = w['playlistId'] as String?;
      final cid = w['channelId'] as String?;
      if (pid == null || cid == null) continue;
      await db.insert(
        'watchlist',
        {
          'channelId':  cid,
          'playlistId': pid,
          'addedAt':    DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // 4) History — last-write-wins by lastWatched timestamp.
    final cloudHist = await CloudSyncService.pullHistory();
    for (final h in cloudHist) {
      final pid = h['playlistId'] as String?;
      final cid = h['channelId'] as String?;
      if (pid == null || cid == null) continue;
      final cloudLw = (h['lastWatched'] as num?)?.toInt() ?? 0;
      final cloudPos = (h['lastPosition'] as num?)?.toInt() ?? 0;
      final cloudDur = (h['duration'] as num?)?.toInt() ?? 0;
      final cloudWatched = (h['isWatched'] as num?)?.toInt() ?? 0;

      // Yerel kaydı bul, lastWatched daha eskiyse cloud'u uygula.
      final rows = await db.query(
        'channels',
        columns: ['lastWatched'],
        where: 'id = ? AND playlistId = ?',
        whereArgs: [cid, pid],
        limit: 1,
      );
      if (rows.isEmpty) continue;
      final localLw = rows.first['lastWatched'] as int? ?? 0;
      if (cloudLw > localLw) {
        await db.update(
          'channels',
          {
            'lastWatched':  cloudLw,
            'lastPosition': cloudPos,
            'duration':     cloudDur,
            'isWatched':    cloudWatched,
          },
          where: 'id = ? AND playlistId = ?',
          whereArgs: [cid, pid],
        );
      }
    }
  }

  /// SharedPrefs'ten son sync timestamp'ini yükle (UI gösterimi için).
  Future<void> loadLastSyncedAt() async {
    final raw = await ref.read(settingsRepoProvider).get('cloud_sync_last_at');
    if (raw == null) return;
    final ms = int.tryParse(raw);
    if (ms == null) return;
    state = state.copyWith(
      lastSyncedAt: DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }
}

final cloudSyncControllerProvider =
    NotifierProvider<CloudSyncController, CloudSyncStatus>(
  CloudSyncController.new,
);
