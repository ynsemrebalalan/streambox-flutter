import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/device_tier.dart';
import '../models/channel_model.dart';
import '../services/cloud_sync_service.dart';
import '../services/m3u_parser.dart';

class ChannelRepository {
  static const _table     = 'channels';
  static const _catTable  = 'channel_categories';

  // KULLANICI KURALI: Provider ne isim verdiyse aynen gosterilir.
  // Runtime title parse / reparse / DB UPDATE YAPILMIYOR.

  /// Tek bir kanalı id ile getir. 2026-05-11: Player favorite button için.
  Future<ChannelModel?> getById(String id) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_table,
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ChannelModel.fromMap(rows.first);
  }

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
    // 2026-05-11 v4: Tüm streamType'lar için basit SQL — sort logic Dart'a
    // taşındı. Live için CASE WHEN spor priority SQL'i 5000+ kanalda spinner
    // sonsuz dönmesine sebep oluyordu.
    return 'sortOrder ASC, name ASC';
  }

  /// Dart-side sıralama — Live için BeIN + spor + izleme geçmişi öncelikli.
  /// 2026-05-11: SQL CASE WHEN spinner takılmasına neden oluyordu, Dart'ta.
  static int _liveChannelPriority(ChannelModel ch) {
    final lc = ch.name.toLowerCase();
    final cc = ch.category.toLowerCase();
    if (ch.lastWatched > 0) return 0;
    if (lc.contains('bein')) return 1;
    if (lc.contains('spor') || lc.contains('sport') ||
        cc.contains('spor') || cc.contains('sport')) return 2;
    return 3;
  }

  /// Live kanal listesi için priority sort uygular. Stable, lastWatched DESC.
  static List<ChannelModel> sortLiveChannels(List<ChannelModel> channels) {
    final sorted = List<ChannelModel>.from(channels);
    sorted.sort((a, b) {
      final pa = _liveChannelPriority(a);
      final pb = _liveChannelPriority(b);
      if (pa != pb) return pa.compareTo(pb);
      // Aynı öncelikte son izlenen önce
      final lwCmp = b.lastWatched.compareTo(a.lastWatched);
      if (lwCmp != 0) return lwCmp;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return sorted;
  }

  Future<List<ChannelModel>> getByType(String playlistId, String streamType) async {
    final db = await AppDatabase.instance;
    // 2026-05-11 v4: SQL basitleştirildi — NOT EXISTS junction çok yavaştı
    // (5000+ kanal × subquery → spinner sonsuz). Limit ile guard, kategori
    // adı negatif filter Dart tarafında (_loadChannels) uygulanıyor.
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ?',
      whereArgs: [playlistId, streamType],
      orderBy:   _orderFor(streamType),
      limit:     2000,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// Tab'a göre kategori adı filtresi — Dart tarafında, kanal listesini
  /// daraltır. SQL'de NOT EXISTS yavaş olduğu için buraya taşındı.
  static bool isChannelAllowedForTab(ChannelModel ch, String streamType) {
    final cats = ch.categoryIds.isNotEmpty
        ? ch.categoryIds.map((c) => c.toLowerCase()).toList()
        : [ch.category.toLowerCase()];

    bool any(List<String> keywords) =>
        cats.any((c) => keywords.any((k) => c.contains(k)));

    switch (streamType) {
      case 'live':
        // Live tab: kategori adı film/dizi içeriyorsa gizle
        return !any(const ['film', 'movie', 'vod', 'dizi', 'series']);
      case 'movie':
        // Movie tab: kategori adı spor/haber/dizi içeriyorsa gizle
        return !any(const [
          'spor', 'sport', 'haber', 'news', 'dizi', 'series',
        ]);
      case 'series':
        // Series tab: kategori adı spor/haber içeriyorsa gizle
        return !any(const ['spor', 'sport', 'haber', 'news']);
      default:
        return true;
    }
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
    // 2026-05-11 v4: Basit SQL + Dart filter+sort. Önceki versiyonlarda
    // CASE WHEN priority SQL spinner sonsuz dönmesine neden oluyordu.

    final rows = await db.rawQuery('''
      SELECT DISTINCT cc.category FROM $_catTable cc
      INNER JOIN channels c
        ON c.id = cc.channelId AND c.playlistId = cc.playlistId
      WHERE cc.playlistId = ? AND c.streamType = ?
      ORDER BY cc.category COLLATE NOCASE ASC
    ''', [playlistId, streamType]);

    // Dart filter: kategori adı bazlı negatif filter (yanlış metadata savunması)
    final allCats = rows.map((r) => r['category'] as String).toList();
    final filtered = allCats.where((cat) {
      final lc = cat.toLowerCase();
      return _isCategoryNameAllowedForTab(lc, streamType);
    }).toList();

    // Live için Dart-side priority sort: BeIN > spor > diğer (alfabetik)
    if (streamType == 'live') {
      filtered.sort((a, b) {
        final la = a.toLowerCase();
        final lb = b.toLowerCase();
        int score(String s) {
          if (s.contains('bein')) return 0;
          if (s.contains('spor') || s.contains('sport')) return 1;
          return 2;
        }
        final cmp = score(la).compareTo(score(lb));
        if (cmp != 0) return cmp;
        return la.compareTo(lb);
      });
    }
    return filtered;
  }

  /// Kategori adı tab için uygun mu — kullanıcı görür perspektifi.
  static bool _isCategoryNameAllowedForTab(String catLower, String streamType) {
    switch (streamType) {
      case 'live':
        return !(catLower.contains('film') ||
            catLower.contains('movie') ||
            catLower.contains('vod') ||
            catLower.contains('dizi') ||
            catLower.contains('series'));
      case 'movie':
        return !(catLower.contains('dizi') ||
            catLower.contains('series') ||
            catLower.contains('spor') ||
            catLower.contains('sport') ||
            catLower.contains('haber') ||
            catLower.contains('news'));
      case 'series':
        return !(catLower.contains('spor') ||
            catLower.contains('sport') ||
            catLower.contains('haber') ||
            catLower.contains('news'));
      default:
        return true;
    }
  }

  /// streamType'a göre kategori adı negatif filter — provider yanlış
  /// metadata'ya karşı UX savunması. Adında "film" geçen bir kategori
  /// Live tab'da görünmemeli, "spor" geçen Movie tab'da görünmemeli.
  static String _categoryNameExcludeClause(String streamType) {
    switch (streamType) {
      case 'live':
        return '''
          AND LOWER(cc.category) NOT LIKE '%film%'
          AND LOWER(cc.category) NOT LIKE '%movie%'
          AND LOWER(cc.category) NOT LIKE '%vod%'
          AND LOWER(cc.category) NOT LIKE '%dizi%'
          AND LOWER(cc.category) NOT LIKE '%series%'
        ''';
      case 'movie':
        return '''
          AND LOWER(cc.category) NOT LIKE '%dizi%'
          AND LOWER(cc.category) NOT LIKE '%series%'
          AND LOWER(cc.category) NOT LIKE '%spor%'
          AND LOWER(cc.category) NOT LIKE '%sport%'
          AND LOWER(cc.category) NOT LIKE '%haber%'
          AND LOWER(cc.category) NOT LIKE '%news%'
        ''';
      case 'series':
        return '''
          AND (
            LOWER(cc.category) NOT LIKE '%film%'
            OR LOWER(cc.category) LIKE '%dizi%'
            OR LOWER(cc.category) LIKE '%series%'
          )
          AND LOWER(cc.category) NOT LIKE '%spor%'
          AND LOWER(cc.category) NOT LIKE '%sport%'
          AND LOWER(cc.category) NOT LIKE '%haber%'
        ''';
      default:
        return '';
    }
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

    // 2026-05-11 v4: Live için basit SQL + Dart sort (spinner fix).
    // Önceki versiyonda CASE WHEN sort çok yavaştı.
    if (streamType == 'live') {
      // Daha fazla çek (limit × 3), Dart sort ile priority uygula, sonra kes
      final rows = await db.query(
        _table,
        where:     'playlistId = ? AND streamType = ?',
        whereArgs: [playlistId, 'live'],
        orderBy:   'rowid DESC',
        limit:     limit * 3,
      );
      final list = rows.map(ChannelModel.fromMap).toList();
      final sorted = sortLiveChannels(list);
      return sorted.take(limit).toList();
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
    List<ChannelModel> channels, {
    void Function(int written, int total)? onProgress,
  }) async {
    if (channels.isEmpty) return;
    final db = await AppDatabase.instance;
    final batchSize = DeviceProfile.dbBatchSize;
    final total = channels.length;

    if (kDebugMode) {
      debugPrint('[ChannelRepo] replaceAll: $total channels, '
          'batchSize=$batchSize, tier=${DeviceProfile.tier}');
    }

    await db.transaction((txn) async {
      await txn.delete(_table,
          where: 'playlistId = ?', whereArgs: [playlistId]);
      await txn.delete(_catTable,
          where: 'playlistId = ?', whereArgs: [playlistId]);

      for (var i = 0; i < total; i += batchSize) {
        final end = (i + batchSize < total) ? i + batchSize : total;
        final chunk = channels.sublist(i, end);
        final batch = txn.batch();
        for (final ch in chunk) {
          batch.insert(_table, ch.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          for (final c in _categoryRows(ch)) {
            batch.insert(_catTable, c,
                conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
        await batch.commit(noResult: true);
        // Progress emit — kullanıcı UI'da "X/Y" görsün (2026-05-11)
        onProgress?.call(end, total);
      }
    });

    rebuildFtsForPlaylist(playlistId);
  }

  /// Tek bir playlist için FTS partial rebuild.
  /// rebuildFts (full) yerine sadece etkilenen rowid'leri günceller.
  Future<void> rebuildFtsForPlaylist(String playlistId) async {
    final db = await AppDatabase.instance;
    try {
      // Bu playlist'in mevcut FTS satırlarını sil
      await db.execute('''
        DELETE FROM channel_fts WHERE rowid IN (
          SELECT rowid FROM $_table WHERE playlistId = ?
        )
      ''', [playlistId]);
      // Yeniden ekle
      await db.execute('''
        INSERT INTO channel_fts(rowid, name, category)
        SELECT rowid, name, category FROM $_table
        WHERE playlistId = ?
      ''', [playlistId]);
    } catch (e) {
      debugPrint('[ChannelRepo] FTS partial rebuild failed: $e');
    }
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
  /// Mevcut DB'deki tüm kanalları yeni `_detectStreamType` kuralları ile
  /// yeniden classify et. App bootstrap'ta bir kere çalışır (one-time
  /// migration, settings flag ile guard). 2026-05-11: eski yanlış
  /// classify edilmiş kanallar (film canlı'da görünüyordu) için kritik.
  /// Performans: chunk'lı transaction, 5000 kanal ~2sn.
  Future<int> reclassifyAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_table,
        columns: ['id', 'name', 'category', 'streamUrl', 'streamType']);
    if (rows.isEmpty) return 0;
    int changed = 0;
    await db.transaction((txn) async {
      const batchSize = 200;
      for (var i = 0; i < rows.length; i += batchSize) {
        final end = (i + batchSize < rows.length) ? i + batchSize : rows.length;
        final batch = txn.batch();
        for (final row in rows.sublist(i, end)) {
          final name    = (row['name'] as String?) ?? '';
          final cat     = (row['category'] as String?) ?? '';
          final url     = (row['streamUrl'] as String?) ?? '';
          final oldType = (row['streamType'] as String?) ?? 'live';
          final newType = M3uParser.detectStreamType(cat, name, url);
          if (newType != oldType) {
            batch.update(_table, {'streamType': newType},
                where: 'id = ?', whereArgs: [row['id']]);
            changed++;
          }
        }
        await batch.commit(noResult: true);
      }
    });
    debugPrint('[ChannelRepo] reclassified $changed/${rows.length} channels');
    return changed;
  }

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
