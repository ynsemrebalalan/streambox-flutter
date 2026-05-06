import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/device_tier.dart';
import '../models/channel_model.dart';
import '../services/cloud_sync_service.dart';

class ChannelRepository {
  static const _table     = 'channels';
  static const _catTable  = 'channel_categories';

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
    final db = await AppDatabase.instance;
    // v6: junction üzerinden JOIN — kanal birden fazla kategoride olabilir.
    // _orderFor server-side string; channels alias'ı zaten kolonlara cleanly
    // referans verecek (seriesName/seasonNumber/sortOrder/name).
    final rows = await db.rawQuery('''
      SELECT channels.* FROM channels
      INNER JOIN $_catTable cc
        ON cc.channelId = channels.id AND cc.playlistId = channels.playlistId
      WHERE channels.playlistId = ?
        AND channels.streamType = ?
        AND cc.category = ?
      ORDER BY ${_orderFor(streamType)}
    ''', [playlistId, streamType, category.trim()]);
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<String>> getCategories(String playlistId, String streamType) async {
    final db = await AppDatabase.instance;
    // v6: junction üzerinden DISTINCT — çoklu kategori varsa hepsi görünür.
    final rows = await db.rawQuery('''
      SELECT DISTINCT cc.category FROM $_catTable cc
      INNER JOIN channels c
        ON c.id = cc.channelId AND c.playlistId = cc.playlistId
      WHERE cc.playlistId = ? AND c.streamType = ?
      ORDER BY cc.category COLLATE NOCASE ASC
    ''', [playlistId, streamType]);
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
  /// Dizi tipi için GROUP BY seriesName → her dizi tek kart olarak görünür.
  Future<List<ChannelModel>> getLatestByType(
    String playlistId,
    String streamType, {
    int limit = 20,
  }) async {
    final db = await AppDatabase.instance;

    if (streamType == 'series') {
      final rows = await db.rawQuery('''
        SELECT * FROM channels
        WHERE playlistId = ? AND streamType = 'series'
          AND rowid IN (
            SELECT MAX(rowid) FROM channels
            WHERE playlistId = ? AND streamType = 'series'
            GROUP BY COALESCE(NULLIF(seriesName,''), name)
          )
        ORDER BY rowid DESC
        LIMIT ?
      ''', [playlistId, playlistId, limit]);
      return rows.map(ChannelModel.fromMap).toList();
    }

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

  /// Sadece film tipi izleme geçmişi (Ana Sayfa "İzlediğin Filmler" satırı için).
  /// Android paritesi: `getWatchedMovies()` Flow karşılığı.
  Future<List<ChannelModel>> getWatchedMovies(String playlistId, {int limit = 20}) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ? AND lastWatched > 0',
      whereArgs: [playlistId, 'movie'],
      orderBy:   'lastWatched DESC',
      limit:     limit,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// Sadece dizi bölümü tipi izleme geçmişi (Ana Sayfa "İzlediğin Diziler" satırı için).
  /// `getContinueWatching` ile fark: burada isWatched filtresi yok — tamamlanmış ve
  /// devam eden tüm dizi bölümlerinin son aktivite sırası.
  /// Her diziden yalnızca en son izlenen bölüm gösterilir (MAX(lastWatched) dedup).
  Future<List<ChannelModel>> getWatchedSeriesEpisodes(String playlistId, {int limit = 20}) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT * FROM channels
      WHERE playlistId = ? AND streamType = 'series' AND lastWatched IS NOT NULL AND lastWatched > 0
        AND rowid IN (
          SELECT rowid FROM channels c1
          WHERE c1.playlistId = ? AND c1.streamType = 'series'
            AND c1.lastWatched IS NOT NULL AND c1.lastWatched > 0
            AND c1.lastWatched = (
              SELECT MAX(c2.lastWatched) FROM channels c2
              WHERE c2.playlistId = c1.playlistId
                AND COALESCE(NULLIF(c2.seriesName,''), c2.name)
                  = COALESCE(NULLIF(c1.seriesName,''), c1.name)
            )
        )
      ORDER BY lastWatched DESC
      LIMIT ?
    ''', [playlistId, playlistId, limit]);
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
      // v6: junction yazımı — her kategori için bir satır.
      for (final c in _categoryRows(ch)) {
        batch.insert(_catTable, c, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteByPlaylist(String playlistId) async {
    final db = await AppDatabase.instance;
    await db.delete(_table, where: 'playlistId = ?', whereArgs: [playlistId]);
    // v6: junction da temizlenmeli — orphan satır kalmasın.
    await db.delete(_catTable, where: 'playlistId = ?', whereArgs: [playlistId]);
  }

  /// Bir kanalın junction tablosuna yazılacak satırlarını döndürür.
  /// `categoryIds` doluysa o liste; boşsa fallback olarak `category` alanı
  /// (legacy / migration sonrası seed). Hepsi TRIM + boş atlanır.
  static List<Map<String, Object?>> _categoryRows(ChannelModel ch) {
    final raw = ch.categoryIds.isNotEmpty
        ? ch.categoryIds
        : <String>[ch.category];
    final seen = <String>{};
    final out = <Map<String, Object?>>[];
    for (final c in raw) {
      final t = c.trim();
      if (t.isEmpty) continue;
      if (!seen.add(t)) continue;
      out.add({
        'channelId':  ch.id,
        'playlistId': ch.playlistId,
        'category':   t,
      });
    }
    return out;
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
      // v6: junction da sil — yeni veri ile yeniden seed edilecek.
      await txn.delete(_catTable,
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
          // v6: junction satırları (1..N kategori per kanal).
          for (final c in _categoryRows(ch)) {
            batch.insert(_catTable, c,
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
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
    final lw = DateTime.now().millisecondsSinceEpoch;
    final values = <String, Object?>{
      'lastWatched':  lw,
      'lastPosition': position,
    };
    final isWatchedFlag = duration > 0 && position > duration * 0.9;
    if (duration > 0) {
      values['duration'] = duration;
      if (isWatchedFlag) values['isWatched'] = 1;
    }
    await db.update(_table, values, where: 'id = ?', whereArgs: [id]);

    // Cloud sync — playlistId için ek query gerek (current row'dan al).
    // Fire-and-forget: history kaydı tüm cihazlara senkron olur.
    () async {
      try {
        final rows = await db.query(_table,
            columns: ['playlistId'],
            where: 'id = ?',
            whereArgs: [id],
            limit: 1);
        if (rows.isEmpty) return;
        final pid = rows.first['playlistId'] as String? ?? '';
        if (pid.isEmpty) return;
        await CloudSyncService.pushHistory(
          playlistId:   pid,
          channelId:    id,
          lastWatched:  lw,
          lastPosition: position,
          duration:     duration,
          isWatched:    isWatchedFlag,
        );
      } catch (_) {}
    }();
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
