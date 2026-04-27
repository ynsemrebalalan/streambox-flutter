import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/device_tier.dart';
import '../models/channel_model.dart';

class ChannelRepository {
  static const _table = 'channels';

  // KULLANICI KURALI: Provider ne isim verdiyse aynen gosterilir.
  // Runtime title parse / reparse / DB UPDATE YAPILMIYOR.

  Future<List<ChannelModel>> getByPlaylist(String playlistId) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:    'playlistId = ?',
      whereArgs: [playlistId],
      orderBy:  'sortOrder ASC, name ASC',
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// v3.8.2: Kullanici raporu — bazi provider'lar title'i yanlis veriyor
  /// ("S01E04" etiketli bolum aslinda 1. bolum). Title parse ile episodeNumber
  /// sort etmek yaniltici. Arama zaten sortOrder kullaniyor — sezon listesi de
  /// ayni kaynaga geldi. **sortOrder primary**: provider API response'undaki
  /// sira tek guvenilir izleme sirasidir.
  static String _orderFor(String streamType) {
    if (streamType == 'series') {
      return '''
        seriesName COLLATE NOCASE ASC,
        CASE WHEN seasonNumber = 0 THEN 9999 ELSE seasonNumber END ASC,
        sortOrder ASC
      ''';
    }
    return 'sortOrder ASC, name ASC';
  }

  Future<List<ChannelModel>> getByType(String playlistId, String streamType) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ?',
      whereArgs: [playlistId, streamType],
      orderBy:   _orderFor(streamType),
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<ChannelModel>> getByCategory(
    String playlistId,
    String streamType,
    String category,
  ) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ? AND category = ?',
      whereArgs: [playlistId, streamType, category],
      orderBy:   _orderFor(streamType),
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<String>> getCategories(String playlistId, String streamType) async {
    final db   = await AppDatabase.instance;
    final rows = await db.rawQuery(
      'SELECT DISTINCT category FROM $_table '
      'WHERE playlistId = ? AND streamType = ? '
      'ORDER BY category ASC',
      [playlistId, streamType],
    );
    return rows.map((r) => r['category'] as String).toList();
  }

  Future<List<ChannelModel>> getFavorites(String playlistId) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND isFavorite = 1',
      whereArgs: [playlistId],
      orderBy:   'name ASC',
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<ChannelModel>> getRecentlyWatched(String playlistId, {int limit = 20}) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND lastWatched > 0',
      whereArgs: [playlistId],
      orderBy:   'lastWatched DESC',
      limit:     limit,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// En son eklenen kanallar — rowid DESC'e göre (SQLite'ta insert sırası).
  /// Ana Sayfa row'ları için kullanılır.
  Future<List<ChannelModel>> getLatestByType(
    String playlistId,
    String streamType, {
    int limit = 20,
  }) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ?',
      whereArgs: [playlistId, streamType],
      orderBy:   'rowid DESC',
      limit:     limit,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// Dizi bölümleri için devam ettirilebilir olanlar (lastPosition > 0 ve izlenmemiş)
  Future<List<ChannelModel>> getContinueWatching(String playlistId, {int limit = 20}) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND lastPosition > 0 AND isWatched = 0 AND lastWatched > 0',
      whereArgs: [playlistId],
      orderBy:   'lastWatched DESC',
      limit:     limit,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<ChannelModel>> search(String playlistId, String query) async {
    final db = await AppDatabase.instance;
    // FTS4 varsa hizli match, yoksa LIKE fallback.
    try {
      final rows = await db.rawQuery('''
        SELECT c.* FROM $_table c
        INNER JOIN channel_fts fts ON fts.rowid = c.rowid
        WHERE c.playlistId = ? AND channel_fts MATCH ?
        ORDER BY c.name ASC LIMIT 200
      ''', [playlistId, '$query*']);
      return rows.map(ChannelModel.fromMap).toList();
    } catch (_) {
      // FTS tablosu yoksa veya bozuksa LIKE fallback.
      final q = '%${query.toLowerCase()}%';
      final rows = await db.query(
        _table,
        where:     'playlistId = ? AND LOWER(name) LIKE ?',
        whereArgs: [playlistId, q],
        orderBy:   'name ASC',
        limit:     200,
      );
      return rows.map(ChannelModel.fromMap).toList();
    }
  }

  Future<void> bulkInsert(List<ChannelModel> channels) async {
    if (channels.isEmpty) return;
    final db = await AppDatabase.instance;
    final batch = db.batch();
    for (final ch in channels) {
      batch.insert(_table, ch.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteByPlaylist(String playlistId) async {
    final db = await AppDatabase.instance;
    await db.delete(_table, where: 'playlistId = ?', whereArgs: [playlistId]);
  }

  /// Atomik sync: eski kanallari sil + yenilerini yaz.
  /// Cihaz tier'ina gore adaptive strateji:
  /// - High: tek buyuk transaction (en hizli, 10k+ kanal ~1sn)
  /// - Mid:  2000'lik chunk'lar (bellek dostu, hala hizli)
  /// - Low:  500'luk chunk'lar (eMMC/RAM dostu, donma yok)
  Future<void> replaceAllForPlaylist(
    String playlistId,
    List<ChannelModel> channels,
  ) async {
    if (channels.isEmpty) return;
    final db = await AppDatabase.instance;
    final batchSize = DeviceProfile.dbBatchSize;

    if (kDebugMode) {
      debugPrint('[ChannelRepo] replaceAll: ${channels.length} channels, '
          'batchSize=$batchSize, tier=${DeviceProfile.tier}');
    }

    // Tek transaction icinde: once sil, sonra chunk'li yaz.
    // Transaction butunlugu korunur — crash'te eski veri kalir.
    await db.transaction((txn) async {
      await txn.delete(_table,
          where: 'playlistId = ?', whereArgs: [playlistId]);

      // Chunk'li batch: her chunk ayri batch.commit ile yazilir
      // ama hepsi ayni transaction icinde → atomik.
      for (var i = 0; i < channels.length; i += batchSize) {
        final end = (i + batchSize < channels.length) ? i + batchSize : channels.length;
        final chunk = channels.sublist(i, end);
        final batch = txn.batch();
        for (final ch in chunk) {
          batch.insert(_table, ch.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      }
    });

    // FTS indexini guncelle (transaction disinda, non-blocking).
    rebuildFts();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<void> updateWatched(String id, {required int position, int duration = 0}) async {
    final db = await AppDatabase.instance;
    final values = <String, Object?>{
      'lastWatched':  DateTime.now().millisecondsSinceEpoch,
      'lastPosition': position,
    };
    if (duration > 0) {
      values['duration'] = duration;
      // %90 izlendiyse "izlendi" say.
      if (position > duration * 0.9) {
        values['isWatched'] = 1;
      }
    }
    await db.update(_table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markWatched(String id) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isWatched': 1},
      where: 'id = ?', whereArgs: [id],
    );
  }

  /// FTS4 indexini channels tablosundan yeniden olusturur.
  /// replaceAllForPlaylist sonrasi cagirilir.
  Future<void> rebuildFts() async {
    final db = await AppDatabase.instance;
    try {
      // Eski veriyi sil, channels'tan tekrar doldur.
      await db.execute('DELETE FROM channel_fts');
      await db.execute(
        'INSERT INTO channel_fts(rowid, name, category) '
        'SELECT rowid, name, category FROM $_table',
      );
    } catch (e) {
      debugPrint('[ChannelRepo] FTS rebuild failed: $e');
    }
  }

  Future<int> countByPlaylist(String playlistId) async {
    final db = await AppDatabase.instance;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $_table WHERE playlistId = ?',
      [playlistId],
    );
    return result.first['cnt'] as int;
  }
}
