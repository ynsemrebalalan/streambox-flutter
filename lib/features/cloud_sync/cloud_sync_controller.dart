import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
/// v7 mimari:
///   1) Pull → merge (LWW: cloud.updatedAt vs local.updatedAt, en yüksek kazanir)
///   2) Push delta → local'de updatedAt > lastSyncedAt olan satirlari Firestore'a
///      yaz, lastSyncedAt = now.
///   3) Tombstone push → sync_tombstones'da syncedAt=NULL satirlar icin remote
///      delete + syncedAt = now.
///
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

  String? _currentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Manuel veya app foreground / login sonrası tam senkron.
  /// Pull → merge (LWW) → push delta → push tombstones.
  Future<void> syncNow() async {
    if (!_eligible()) {
      // Sessizce no-op; UI Pro değilse zaten sync sekmesini kilitler.
      return;
    }
    state = state.copyWith(phase: CloudSyncPhase.syncing, lastError: null);
    try {
      await _pullAndMerge();
      await _pushDirty();
      await _pushTombstones();
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

  /// Cloud'dan cek, local ile LWW merge.
  Future<void> _pullAndMerge() async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    if (uid == null) return;

    // 1) Playlists — LWW: cloud.updatedAt vs local.updatedAt.
    final cloudPlaylists = await CloudSyncService.pullPlaylists();
    for (final p in cloudPlaylists) {
      await _mergePlaylist(db, p, uid);
    }

    // 2) Favorites — channels.isFavorite=1 işaretle (kanal local'de varsa).
    //    Favorite "boolean toggle" oldugu icin LWW yerine cloud'da varsa local'de
    //    isFavorite=1 isaretle (basit upsert). Tombstone push tarafi cloud'dan
    //    silinenleri zaten local'de de sileceği için divergence kapaniyor.
    final cloudFavs = await CloudSyncService.pullFavorites();
    for (final f in cloudFavs) {
      final pid = f['playlistId'] as String?;
      final cid = f['channelId'] as String?;
      if (pid == null || cid == null) continue;
      await db.update(
        'channels',
        {
          'isFavorite': 1,
          'ownerUid':   uid,
          'updatedAt':  DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ? AND playlistId = ?',
        whereArgs: [cid, pid],
      );
    }

    // 3) Watchlist — LWW upsert.
    final cloudWl = await CloudSyncService.pullWatchlist();
    for (final w in cloudWl) {
      await _mergeWatchlist(db, w, uid);
    }

    // 4) History — channels tablosunda lastWatched LWW (eski mantik korundu).
    final cloudHist = await CloudSyncService.pullHistory();
    for (final h in cloudHist) {
      final pid = h['playlistId'] as String?;
      final cid = h['channelId'] as String?;
      if (pid == null || cid == null) continue;
      final cloudLw = (h['lastWatched'] as num?)?.toInt() ?? 0;
      final cloudPos = (h['lastPosition'] as num?)?.toInt() ?? 0;
      final cloudDur = (h['duration'] as num?)?.toInt() ?? 0;
      final cloudWatched = (h['isWatched'] as num?)?.toInt() ?? 0;

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
            'ownerUid':     uid,
            'updatedAt':    DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ? AND playlistId = ?',
          whereArgs: [cid, pid],
        );
      }
    }
  }

  /// Tek playlist icin LWW merge.
  /// remote.updatedAt > local.updatedAt → ezme (cloud kazandi).
  /// local.updatedAt > remote.updatedAt → no-op (local push'ta uzerine yazacak).
  Future<void> _mergePlaylist(
    Database db,
    Map<String, dynamic> remote,
    String uid,
  ) async {
    final id = remote['id'] as String?;
    if (id == null || id.isEmpty) return;

    // Firestore'da updatedAt alani Timestamp (server) — millisecond'a cevir.
    final remoteUpdated = _toMs(remote['updatedAt']);

    final localRows = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (localRows.isEmpty) {
      // Yeni remote satir — local'e ekle.
      await db.insert(
        'playlists',
        {
          'id':           id,
          'name':         remote['name'] ?? '',
          'type':         remote['type'] ?? 'm3u',
          'url':          remote['url'] ?? '',
          'username':     remote['username'] ?? '',
          'password':     remote['password'] ?? '',
          'allowedTypes': remote['allowedTypes'] ?? 'live,movie,series',
          'addedAt':      DateTime.now().millisecondsSinceEpoch,
          'ownerUid':     uid,
          'updatedAt':    remoteUpdated > 0
              ? remoteUpdated
              : DateTime.now().millisecondsSinceEpoch,
          'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }

    final local = localRows.first;
    final localUpdated = local['updatedAt'] as int? ?? 0;

    if (remoteUpdated > localUpdated) {
      // Cloud daha yeni → ez. lastSyncedAt = now (artik dirty degil).
      await db.update(
        'playlists',
        {
          'name':         remote['name'] ?? local['name'],
          'type':         remote['type'] ?? local['type'],
          'url':          remote['url'] ?? local['url'],
          'username':     remote['username'] ?? local['username'],
          'password':     remote['password'] ?? local['password'],
          'allowedTypes': remote['allowedTypes'] ?? local['allowedTypes'],
          'ownerUid':     uid,
          'updatedAt':    remoteUpdated,
          'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    // local >= remote ise no-op; push fazi local'i remote'a propagate eder.
  }

  Future<void> _mergeWatchlist(
    Database db,
    Map<String, dynamic> remote,
    String uid,
  ) async {
    final pid = remote['playlistId'] as String?;
    final cid = remote['channelId'] as String?;
    if (pid == null || cid == null) return;

    final remoteUpdated = _toMs(remote['updatedAt'] ?? remote['addedAt']);

    final localRows = await db.query(
      'watchlist',
      where: 'channelId = ? AND playlistId = ?',
      whereArgs: [cid, pid],
      limit: 1,
    );

    if (localRows.isEmpty) {
      await db.insert(
        'watchlist',
        {
          'channelId':    cid,
          'playlistId':   pid,
          'addedAt':      remoteUpdated > 0
              ? remoteUpdated
              : DateTime.now().millisecondsSinceEpoch,
          'ownerUid':     uid,
          'updatedAt':    remoteUpdated > 0
              ? remoteUpdated
              : DateTime.now().millisecondsSinceEpoch,
          'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return;
    }

    final localUpdated = localRows.first['updatedAt'] as int? ?? 0;
    if (remoteUpdated > localUpdated) {
      await db.update(
        'watchlist',
        {
          'addedAt':      remoteUpdated,
          'ownerUid':     uid,
          'updatedAt':    remoteUpdated,
          'lastSyncedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'channelId = ? AND playlistId = ?',
        whereArgs: [cid, pid],
      );
    }
  }

  /// Local'de updatedAt > lastSyncedAt olan satirlari Firestore'a push.
  /// Push sonrasi lastSyncedAt = now → satir artik "clean".
  Future<void> _pushDirty() async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    if (uid == null) return;

    // 1) Playlists dirty.
    final dirtyPlaylists = await db.rawQuery('''
      SELECT * FROM playlists
      WHERE ownerUid = ?
        AND (lastSyncedAt IS NULL OR updatedAt > lastSyncedAt)
    ''', [uid]);
    for (final row in dirtyPlaylists) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('playlists')
            .doc(row['id'] as String)
            .set({
          'id':           row['id'],
          'name':         row['name'],
          'type':         row['type'],
          'url':          row['url'],
          'username':     row['username'],
          'password':     row['password'],
          'allowedTypes': row['allowedTypes'],
          'updatedAt':    row['updatedAt'],
        }, SetOptions(merge: true));
        await db.update(
          'playlists',
          {'lastSyncedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      } catch (e) {
        debugPrint('[CloudSync] push playlist ${row['id']} fail: $e');
      }
    }

    // 2) Watchlist dirty.
    final dirtyWl = await db.rawQuery('''
      SELECT * FROM watchlist
      WHERE ownerUid = ?
        AND (lastSyncedAt IS NULL OR updatedAt > lastSyncedAt)
    ''', [uid]);
    for (final row in dirtyWl) {
      final cid = row['channelId'] as String;
      final pid = row['playlistId'] as String;
      final key = '${pid}__$cid';
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('watchlist')
            .doc(key)
            .set({
          'playlistId': pid,
          'channelId':  cid,
          'addedAt':    row['addedAt'],
          'updatedAt':  row['updatedAt'],
        }, SetOptions(merge: true));
        await db.update(
          'watchlist',
          {'lastSyncedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'channelId = ? AND playlistId = ?',
          whereArgs: [cid, pid],
        );
      } catch (e) {
        debugPrint('[CloudSync] push watchlist $key fail: $e');
      }
    }
  }

  /// sync_tombstones'da syncedAt=NULL satirlar icin Firestore delete + mark.
  Future<void> _pushTombstones() async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    if (uid == null) return;

    final tombstones = await db.query(
      'sync_tombstones',
      where: 'ownerUid = ? AND syncedAt IS NULL',
      whereArgs: [uid],
    );

    for (final t in tombstones) {
      final table = t['tableName'] as String;
      final recordId = t['recordId'] as String;
      try {
        await _deleteRemote(uid, table, recordId);
        await db.update(
          'sync_tombstones',
          {'syncedAt': DateTime.now().millisecondsSinceEpoch},
          where: 'tableName = ? AND recordId = ? AND ownerUid = ?',
          whereArgs: [table, recordId, uid],
        );
      } catch (e) {
        debugPrint('[CloudSync] push tombstone $table/$recordId fail: $e');
      }
    }
  }

  /// Tablo adina gore remote dokumani sil. Tombstone'da composite key
  /// "${pid}__${cid}" formatinda recordId — Firestore doc id'si ayni.
  Future<void> _deleteRemote(String uid, String table, String recordId) async {
    final fs = FirebaseFirestore.instance;
    final base = fs.collection('users').doc(uid);
    switch (table) {
      case 'playlists':
        await base.collection('playlists').doc(recordId).delete();
        break;
      case 'watchlist':
        await base.collection('watchlist').doc(recordId).delete();
        break;
      case 'favorites':
        await base.collection('favorites').doc(recordId).delete();
        break;
      case 'channels':
        // Channels Firestore'da yok (history'de mirror edilir); no-op.
        break;
      default:
        debugPrint('[CloudSync] unknown tombstone table: $table');
    }
  }

  /// Firestore'dan gelen updatedAt — Timestamp veya int (ms) olabilir.
  /// Eski sema (string) ihtimaline karsi defansif.
  int _toMs(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is Timestamp) return v.millisecondsSinceEpoch;
    if (v is num) return v.toInt();
    return 0;
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
