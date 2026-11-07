import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/playlist_model.dart';
import '../services/cloud_sync_service.dart';

class PlaylistRepository {
  static const _table = 'playlists';
  static const _uuid  = Uuid();

  /// Mevcut Firebase UID — anon dahil. Yoksa null.
  /// CloudSync push delta ve tombstone insert icin kullanilir.
  String? _currentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      // Firebase init henuz yapilmadi (cold start race) — null don.
      return null;
    }
  }

  Future<List<PlaylistModel>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_table, orderBy: 'addedAt ASC');
    return rows.map(PlaylistModel.fromMap).toList();
  }

  Future<PlaylistModel?> getById(String id) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : PlaylistModel.fromMap(rows.first);
  }

  Future<PlaylistModel> insert(PlaylistModel playlist) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    final p = playlist.copyWith(
      id: playlist.id.isEmpty ? _uuid.v4() : playlist.id,
      addedAt: playlist.addedAt == 0 ? now : playlist.addedAt,
      ownerUid: playlist.ownerUid ?? _currentUid(),
      updatedAt: now,
    );
    await db.insert(_table, p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    // Cloud sync (Pro + auth) — fire-and-forget.
    // ignore: unawaited_futures
    CloudSyncService.pushPlaylist(p);
    return p;
  }

  Future<void> update(PlaylistModel playlist) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    final p = playlist.copyWith(
      ownerUid: playlist.ownerUid ?? _currentUid(),
      updatedAt: now,
    );
    await db.update(_table, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    // ignore: unawaited_futures
    CloudSyncService.pushPlaylist(p);
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    final now = DateTime.now().millisecondsSinceEpoch;
    // Atomik temizlik — tüm bağlı satırlar tek transaction'da.
    // v6: channel_categories junction da temizlenir (orphan kalmasın).
    // v7: tombstone insert — CloudSync push tarafi remote'tan da siler.
    await db.transaction((txn) async {
      await txn.delete('channel_categories', where: 'playlistId = ?', whereArgs: [id]);
      await txn.delete('channels', where: 'playlistId = ?', whereArgs: [id]);
      await txn.delete(_table, where: 'id = ?', whereArgs: [id]);
      if (uid != null) {
        await txn.insert(
          'sync_tombstones',
          {
            'tableName': 'playlists',
            'recordId':  id,
            'ownerUid':  uid,
            'deletedAt': now,
            'syncedAt':  null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    // ignore: unawaited_futures
    CloudSyncService.deletePlaylist(id);
  }

  /// Yalnız bu cihazdan sil (Android "Cihazdan Sil"): tombstone YAZILMAZ,
  /// bulut kaydı durur — "Buluttan İndir"/sync ile geri gelir.
  Future<void> deleteLocalOnly(String id) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      await txn.delete('channel_categories', where: 'playlistId = ?', whereArgs: [id]);
      await txn.delete('channels', where: 'playlistId = ?', whereArgs: [id]);
      await txn.delete(_table, where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Otomatik yenileme damgaları — cihaz yerel metadata, cloud'a gitmez.
  Future<void> markRefreshAttempt(String id, int ms) => _updateLocal(
      id, {'lastRefreshAttemptAt': ms});

  Future<void> markRefreshed(String id, int ms) =>
      _updateLocal(id, {'lastRefreshAt': ms, 'lastRefreshAttemptAt': ms});

  /// Playlist'in EPG URL'i (boş = kaldır). Cloud'a yazılmaz; yerel ayar.
  Future<void> updateEpgUrl(String id, String url) =>
      _updateLocal(id, {'epgUrl': url.trim()});

  Future<void> _updateLocal(String id, Map<String, Object?> values) async {
    final db = await AppDatabase.instance;
    await db.update(_table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateEtag(String id, {required String etag, required String lastModified}) async {
    final db = await AppDatabase.instance;
    // ETag/lastModified HTTP cache metadata'sidir — gercek user data degil.
    // updatedAt'i ezmiyoruz ki sync delta'yi yanlislikla tetiklemesin.
    await db.update(
      _table,
      {'etag': etag, 'lastModified': lastModified},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
