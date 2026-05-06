import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/channel_model.dart';

/// "Sonra İzle" / İzleme Listem (Watchlist).
/// `watchlist` tablosu sadece `(channelId, playlistId, addedAt)` tutar — kanal
/// metadata'sı `channels` tablosundan join ile gelir, böylece sınırlı bellek
/// tüketir ve playlist refresh edildikten sonra otomatik güncel kalır.
class WatchlistRepository {
  static const _table = 'watchlist';

  String? _currentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Watchlist tombstone PK formati — composite (channelId|playlistId).
  /// Tombstone tablosunda `recordId` TEXT, watchlist'in iki anahtari var,
  /// "${cid}__${pid}" formatinda birlestirip recordId'ye yazariz. CloudSync
  /// push tarafi bu formati ayristirip remote dokumani silebilir.
  String _tombstoneKey(String channelId, String playlistId) =>
      '${channelId}__$playlistId';

  Future<bool> isInWatchlist(String channelId, String playlistId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'channelId = ? AND playlistId = ?',
      whereArgs: [channelId, playlistId],
      limit:     1,
    );
    return rows.isNotEmpty;
  }

  Future<void> add(String channelId, String playlistId) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      _table,
      {
        'channelId':  channelId,
        'playlistId': playlistId,
        'addedAt':    now,
        'ownerUid':   _currentUid(),
        'updatedAt':  now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> remove(String channelId, String playlistId) async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete(
        _table,
        where:     'channelId = ? AND playlistId = ?',
        whereArgs: [channelId, playlistId],
      );
      // v7 — tombstone: CloudSync push tarafi remote'tan da silebilsin.
      if (uid != null) {
        await txn.insert(
          'sync_tombstones',
          {
            'tableName': 'watchlist',
            'recordId':  _tombstoneKey(channelId, playlistId),
            'ownerUid':  uid,
            'deletedAt': now,
            'syncedAt':  null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> toggle(String channelId, String playlistId) async {
    if (await isInWatchlist(channelId, playlistId)) {
      await remove(channelId, playlistId);
    } else {
      await add(channelId, playlistId);
    }
  }

  /// Watchlist'teki tüm kanalları en yeni eklenene göre döndürür.
  /// Channel meta'sı join ile alınır — kanal silinmişse satır da uçar.
  Future<List<ChannelModel>> getAll(String playlistId, {int limit = 100}) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT c.* FROM channels c
      INNER JOIN $_table w
        ON w.channelId = c.id AND w.playlistId = c.playlistId
      WHERE w.playlistId = ?
      ORDER BY w.addedAt DESC
      LIMIT ?
    ''', [playlistId, limit]);
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<int> count(String playlistId) async {
    final db = await AppDatabase.instance;
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM $_table WHERE playlistId = ?',
      [playlistId],
    );
    return (r.first['c'] as int?) ?? 0;
  }
}
