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

  /// Kanalı ekler — Android gibi kanal özelliklerinin snapshot'ı da yazılır;
  /// playlist yenilense/silinse bile liste kaydı görünür kalır (cross-playlist).
  /// Geriye uyumlu imza (player): kanalı DB'den bulup snapshot'lı ekler.
  Future<void> add(String channelId, String playlistId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query('channels',
        where: 'id = ?', whereArgs: [channelId], limit: 1);
    final ch = rows.isNotEmpty
        ? ChannelModel.fromMap(rows.first)
        : ChannelModel(
            id: channelId, playlistId: playlistId, name: '', streamUrl: '');
    await addChannel(ch);
  }

  Future<void> addChannel(ChannelModel ch) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      _table,
      {
        'channelId':     ch.id,
        'playlistId':    ch.playlistId,
        'addedAt':       now,
        'ownerUid':      _currentUid(),
        'updatedAt':     now,
        'name':          ch.name,
        'streamUrl':     ch.streamUrl,
        'logoUrl':       ch.logoUrl,
        'streamType':    ch.streamType,
        'category':      ch.category,
        'seriesName':    ch.seriesName,
        'seasonNumber':  ch.seasonNumber,
        'episodeNumber': ch.episodeNumber,
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

  /// Dönüş: yeni durum (listede mi).
  Future<bool> toggle(ChannelModel ch) async {
    if (await isInWatchlist(ch.id, ch.playlistId)) {
      await remove(ch.id, ch.playlistId);
      return false;
    }
    await addChannel(ch);
    return true;
  }

  /// Tüm playlist'lerden watchlist (Android `getAll`) — en yeni önce, limitsiz.
  /// Kanal hâlâ varsa güncel satır (favori/geçmiş dahil), yoksa snapshot.
  Future<List<ChannelModel>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT w.channelId AS wCid, w.playlistId AS wPid, w.name AS wName, w.streamUrl AS wUrl,
             w.logoUrl AS wLogo, w.streamType AS wType, w.category AS wCat,
             w.seriesName AS wSeries, w.seasonNumber AS wSeason,
             w.episodeNumber AS wEp, c.*
      FROM $_table w
      LEFT JOIN channels c ON c.id = w.channelId
      ORDER BY w.addedAt DESC
    ''');
    return rows.map(fromJoinedRow).whereType<ChannelModel>().toList();
  }

  /// JOIN satırı → model (saf, testli). Kanal yoksa snapshot; snapshot da
  /// boşsa (eski kayıt, kanal silinmiş) null.
  static ChannelModel? fromJoinedRow(Map<String, Object?> r) {
    if (r['id'] != null) return ChannelModel.fromMap(r);
    final url = (r['wUrl'] as String?) ?? '';
    if (url.isEmpty) return null;
    return ChannelModel(
      id:            r['wCid'] as String,
      playlistId:    r['wPid'] as String,
      name:          (r['wName'] as String?) ?? '',
      streamUrl:     url,
      logoUrl:       (r['wLogo'] as String?) ?? '',
      streamType:    (r['wType'] as String?) ?? 'live',
      category:      (r['wCat'] as String?) ?? '',
      seriesName:    (r['wSeries'] as String?) ?? '',
      seasonNumber:  (r['wSeason'] as int?) ?? 0,
      episodeNumber: (r['wEp'] as int?) ?? 0,
    );
  }

  /// Listeyi temizle (Android "Listeyi temizle"). Tombstone'lar yazılır,
  /// CloudSync push uzak kayıtları da siler.
  Future<int> clearAll() async {
    final db = await AppDatabase.instance;
    final uid = _currentUid();
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.transaction((txn) async {
      final rows = await txn.query(_table, columns: ['channelId', 'playlistId']);
      if (uid != null) {
        for (final r in rows) {
          await txn.insert(
            'sync_tombstones',
            {
              'tableName': 'watchlist',
              'recordId':  _tombstoneKey(
                  r['channelId'] as String, r['playlistId'] as String),
              'ownerUid':  uid,
              'deletedAt': now,
              'syncedAt':  null,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await txn.delete(_table);
      return rows.length;
    });
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
