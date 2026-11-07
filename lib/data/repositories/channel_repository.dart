import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/device_tier.dart';
import '../../core/utils/search_normalizer.dart';
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
    if (lc.contains('spor') ||
        lc.contains('sport') ||
        cc.contains('spor') ||
        cc.contains('sport')) {
      return 2;
    }
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
        // Series tab: kategori adı film/spor/haber içeriyorsa gizle.
        // M3U sağlayıcısı bir kanali yanlislikla `series` streamType ile
        // etiketlerse ve kategori adi "Aile Filmleri" gibi olursa series
        // tabinda gozukmesin — kullanici raporu 2026-05-25.
        return !any(const [
          'film', 'movie', 'vod',
          'spor', 'sport', 'haber', 'news',
        ]);
      default:
        return true;
    }
  }

  /// Tek bolumlu "dizileri" film tab'inda gostermek icin yardimci.
  /// streamType='series' AND seriesName != '' AND seriesName 1 bolume sahip
  /// olan kanallari dondurur. 2026-05-25: M3U providers yanlis etiketleme
  /// savunmasi — kullanici "1 bolumlu dizi olmaz, bunlar film".
  ///
  /// [category] verilirse sadece o kategorideki orphan'lari dondurur (junction
  /// uzerinden, cati category ya da categoryIds ile eslesir).
  Future<List<ChannelModel>> getOrphanSeriesAsMovies(
    String playlistId, {
    String? category,
  }) async {
    final db = await AppDatabase.instance;
    // "Tek bolumlu seri" = seriesName != '' VE COUNT(*) = 1.
    // Subquery ile orphan seriesName listesini bul, sonra channels'tan cek.
    if (category == null) {
      return (await db.rawQuery('''
        SELECT * FROM channels
        WHERE playlistId = ? AND streamType = 'series' AND seriesName != ''
          AND NOT $_containerSqlBare
          AND seriesName IN (
            SELECT seriesName FROM channels
            WHERE playlistId = ? AND streamType = 'series' AND seriesName != ''
            GROUP BY seriesName HAVING COUNT(*) = 1
          )
        ORDER BY name COLLATE NOCASE ASC
        LIMIT 2000
      ''', [playlistId, playlistId]))
          .map(ChannelModel.fromMap)
          .toList();
    }
    // Kategoriye gore — junction tablosu uzerinden
    return (await db.rawQuery('''
      SELECT channels.* FROM channels
      INNER JOIN $_catTable cc
        ON cc.channelId = channels.id AND cc.playlistId = channels.playlistId
      WHERE channels.playlistId = ?
        AND channels.streamType = 'series'
        AND channels.seriesName != ''
        AND cc.category = ?
        AND NOT ${_containerSqlFor('channels')}
        AND channels.seriesName IN (
          SELECT seriesName FROM channels
          WHERE playlistId = ? AND streamType = 'series' AND seriesName != ''
          GROUP BY seriesName HAVING COUNT(*) = 1
        )
      ORDER BY channels.name COLLATE NOCASE ASC
      LIMIT $listLimit
    ''', [playlistId, category.trim(), playlistId]))
        .map(ChannelModel.fromMap)
        .toList();
  }

  /// Tek bolumlu "dizilerin" kategori adlari (junction uzerinden distinct).
  /// Movie tab kategori chip bar'ina eklenir. 2026-05-25.
  /// LIMIT 200 — kategori sayisi pratikte 50'yi gecmez, ic ice subquery'lerin
  /// 10k+ kanalda yavaslamasini onler (skill: SQL CASE WHEN spinner).
  Future<List<String>> getOrphanSeriesCategories(String playlistId) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT DISTINCT cc.category FROM $_catTable cc
      INNER JOIN channels c
        ON c.id = cc.channelId AND c.playlistId = cc.playlistId
      WHERE cc.playlistId = ? AND c.streamType = 'series' AND c.seriesName != ''
        AND NOT $_containerSql
        AND c.seriesName IN (
          SELECT seriesName FROM channels
          WHERE playlistId = ? AND streamType = 'series' AND seriesName != ''
          GROUP BY seriesName HAVING COUNT(*) = 1
        )
      LIMIT 200
    ''', [playlistId, playlistId]);
    return rows.map((r) => r['category'] as String).toList();
  }

  /// Kategori/sekme listelerinde bellek tavanı. 100K+ listede tek kategori
  /// on binlerce satır olabilir; UI lazy builder olsa da model listesi RAM'de
  /// tutulur. Dizi sheet'i bölümleri DB'den ayrıca çeker (kesilme etkilemez).
  static const listLimit = 5000;

  Future<List<ChannelModel>> getByCategory(
    String playlistId,
    String streamType,
    String category, {
    int limit = listLimit,
  }) async {
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
      LIMIT ?
    ''', [playlistId, streamType, category.trim(), limit]);
    return rows.map(ChannelModel.fromMap).toList();
  }

  Future<List<String>> getCategories(String playlistId, String streamType) async {
    final db = await AppDatabase.instance;
    // 2026-05-11 v4: Basit SQL + Dart filter+sort. Önceki versiyonlarda
    // CASE WHEN priority SQL spinner sonsuz dönmesine neden oluyordu.
    //
    // 2026-05-25: Series tab icin ek kural — "1 bolumlu dizi olmaz".
    // M3U providers bazi filmleri yanlislikla streamType=series etiketliyor;
    // bunlarin kategorileri (jenerik adlarla: "Aksiyon", "Komedi", ...)
    // dizi tab'inda gozukmesin. Kural: kategoride EN AZ BIR seriesName'in
    // 2+ bolumu olmali → `COUNT(*) > COUNT(DISTINCT seriesName)` (toplam
    // bolum sayisi distinct dizi sayisindan fazlaysa, en az bir dizi
    // birden fazla bolume sahip demektir).
    final List<Map<String, Object?>> rows;
    if (streamType == 'series') {
      rows = await db.rawQuery('''
        SELECT cc.category FROM $_catTable cc
        INNER JOIN channels c
          ON c.id = cc.channelId AND c.playlistId = cc.playlistId
        WHERE cc.playlistId = ? AND c.streamType = 'series'
          AND c.seriesName != ''
        GROUP BY cc.category
        HAVING COUNT(*) > COUNT(DISTINCT c.seriesName)
            OR SUM($_containerSql) > 0
        ORDER BY MIN(c.sortOrder), cc.category COLLATE NOCASE ASC
      ''', [playlistId]);
    } else {
      // 2026-07-07: Sağlayıcı sırası korunur — MIN(sortOrder) = kategorinin
      // kaynak listede ilk göründüğü konum. Alfabetik sıralama kullanıcı
      // şikayetiydi ("TR en altta, özel kanallar üstte").
      rows = await db.rawQuery('''
        SELECT cc.category FROM $_catTable cc
        INNER JOIN channels c
          ON c.id = cc.channelId AND c.playlistId = cc.playlistId
        WHERE cc.playlistId = ? AND c.streamType = ?
        GROUP BY cc.category
        ORDER BY MIN(c.sortOrder), cc.category COLLATE NOCASE ASC
      ''', [playlistId, streamType]);
    }

    // Dart filter: kategori adı bazlı negatif filter (yanlış metadata savunması)
    final allCats = rows.map((r) => r['category'] as String).toList();
    final filtered = allCats.where((cat) {
      final lc = cat.toLowerCase();
      return _isCategoryNameAllowedForTab(lc, streamType);
    }).toList();

    // Live için Dart-side priority sort: BeIN > spor > diğer.
    // Eşit skorda sağlayıcı sırası korunur (alfabetik DEĞİL — List.sort
    // stable olmadığı için orijinal index ile tie-break yapılır).
    if (streamType == 'live') {
      final origIdx = <String, int>{
        for (var i = 0; i < filtered.length; i++) filtered[i]: i,
      };
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
        return (origIdx[a] ?? 0).compareTo(origIdx[b] ?? 0);
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
        // Series tab kategori chip bar'i: film/movie/vod ve spor/haber adli
        // kategoriler gozukmemeli. Yanlis metadata savunmasi — 2026-05-25.
        return !(catLower.contains('film') ||
            catLower.contains('movie') ||
            catLower.contains('vod') ||
            catLower.contains('spor') ||
            catLower.contains('sport') ||
            catLower.contains('haber') ||
            catLower.contains('news'));
      default:
        return true;
    }
  }

  Future<List<ChannelModel>> getFavorites(String playlistId) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND isFavorite = 1',
      whereArgs: [playlistId],
      orderBy:   'name ASC',
      limit:     listLimit,
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// Son izlenenler — Android `getRecentChannels` paritesi: GLOBAL (tüm
  /// playlist'ler), lastWatched DESC. [playlistId] imza uyumu için kalır,
  /// filtrelemez. Aynı yayın birden fazla grupta/playlist'te izlendiyse
  /// tek kart (id + streamUrl dedup, Android v4.1.22).
  Future<List<ChannelModel>> getRecentlyWatched(String playlistId, {int limit = 20}) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'lastWatched > 0',
      orderBy:   'lastWatched DESC',
      limit:     limit * 2,
    );
    return dedupeRecents(rows.map(ChannelModel.fromMap).toList(), limit: limit);
  }

  /// id + streamUrl bazlı dedup, sıra korunur.
  static List<ChannelModel> dedupeRecents(List<ChannelModel> list,
      {int limit = 20}) {
    final ids = <String>{};
    final urls = <String>{};
    final out = <ChannelModel>[];
    for (final c in list) {
      if (!ids.add(c.id)) continue;
      if (!urls.add(c.streamUrl.isEmpty ? c.id : c.streamUrl)) continue;
      out.add(c);
      if (out.length >= limit) break;
    }
    return out;
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

  /// Arama — Android paritesi (AppDatabase.kt searchChannels).
  /// `searchKey` = fold(name + seriesName) üzerinde `LIKE %q%` (substring,
  /// Türkçe katlanmış), sağlayıcı sırası (sortOrder). FTS4 kullanılmıyor:
  /// external-content index sync'lerde bayat token biriktiriyordu ve yalnız
  /// prefix + name/category arıyordu. Dizi bölümleri tek sonuçta toplanır.
  /// [streamType] verilirse yalnız o tip. Gizli kategori filtresi caller'da
  /// ([isChannelVisibleInSearch]) uygulanır.
  Future<List<ChannelModel>> search(String playlistId, String query,
      {String? streamType}) async {
    final pattern = searchLikePattern(query);
    if (pattern == null || playlistId.isEmpty) return const [];
    final db = await AppDatabase.instance;
    final where = StringBuffer(
        r"playlistId = ? AND searchKey LIKE ? ESCAPE '\'");
    final args = <Object?>[playlistId, pattern];
    if (streamType != null && streamType.isNotEmpty) {
      where.write(' AND streamType = ?');
      args.add(streamType);
    }
    // Dizi gruplaması Dart'ta: aynı dizinin onlarca bölümü 200 limitini
    // doldurmasın diye geniş çek, grupla, sonra kes.
    final rows = await db.query(
      _table,
      where:     where.toString(),
      whereArgs: args,
      orderBy:   'sortOrder ASC',
      limit:     _searchFetchLimit,
    );
    return groupSearchResults(rows.map(ChannelModel.fromMap).toList());
  }

  static const _searchFetchLimit = 1000;
  static const searchResultLimit = 200;

  /// Dizi bölümlerini `seriesName` başına tek sonuca indirger (ilk görülen
  /// = sortOrder'a göre ilk bölüm). Diğer tipler aynen, sıra korunur.
  static List<ChannelModel> groupSearchResults(
    List<ChannelModel> rows, {
    int limit = searchResultLimit,
  }) {
    final seen = <String>{};
    final out = <ChannelModel>[];
    for (final ch in rows) {
      if (ch.streamType == 'series' && ch.seriesName.isNotEmpty) {
        if (!seen.add(ch.seriesName)) continue;
      }
      out.add(ch);
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Arama sonucu listelerde görünür mü — home listeleriyle aynı kurallar:
  /// tab kategori filtresi ([isChannelAllowedForTab]) + gizli kategoriler.
  static bool isChannelVisibleInSearch(ChannelModel ch, Set<String> hidden) {
    if (!isChannelAllowedForTab(ch, ch.streamType)) return false;
    if (hidden.isEmpty) return true;
    final trimmed = hidden.map((e) => e.trim()).toSet();
    return !trimmed.contains(ch.category.trim());
  }

  /// Bir dizinin tüm bölümleri (seriesName + playlistId). Seri detay
  /// sheet'i için — sortOrder tek güvenilir izleme sırası.
  Future<List<ChannelModel>> getSeriesEpisodes(
      String playlistId, String seriesName) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     "playlistId = ? AND streamType = 'series' AND seriesName = ?",
      whereArgs: [playlistId, seriesName],
      orderBy:   'sortOrder ASC',
    );
    return rows.map(ChannelModel.fromMap).toList();
  }

  // ── Xtream dizi container'ları (lazy bölüm yükleme) ─────────────────────────

  /// Container satırı = Xtream `get_series` kaydı; bölümler açılışta
  /// `get_series_info` ile çekilir (Android XtreamLoader paritesi).
  static const _containerSqlBare =
      "(seasonNumber = 0 AND episodeNumber = 0 AND streamUrl LIKE '%action=get_series_info%')";
  static const _containerSql =
      "(c.seasonNumber = 0 AND c.episodeNumber = 0 AND c.streamUrl LIKE '%action=get_series_info%')";
  static String _containerSqlFor(String t) =>
      "($t.seasonNumber = 0 AND $t.episodeNumber = 0 AND $t.streamUrl LIKE '%action=get_series_info%')";

  /// Bölümü henüz çekilmemiş container'lar (prefetch için), sağlayıcı sırası.
  Future<List<ChannelModel>> getPendingSeriesContainers(String playlistId,
      {int limit = 300}) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT * FROM channels
      WHERE playlistId = ? AND streamType = 'series' AND $_containerSqlBare
      ORDER BY sortOrder ASC
      LIMIT ?
    ''', [playlistId, limit]);
    return rows.map(ChannelModel.fromMap).toList();
  }

  /// Lazy çekilen bölümleri yazar (upsert — kullanıcı verisi korunur) ve
  /// container'ı siler. Bölüm yoksa container kalır.
  Future<void> replaceSeriesContainer(
    ChannelModel container,
    List<ChannelModel> episodes,
  ) async {
    if (episodes.isEmpty) return;
    final db = await AppDatabase.instance;
    final gen = await _rowSyncGen(db, container.id);
    // Container'ın çoklu kategorisi ve favori durumu bölümlere geçer.
    final catRows = await db.query(_catTable,
        columns: ['category'],
        where: 'channelId = ?', whereArgs: [container.id]);
    final cats = catRows.map((r) => r['category'] as String).toList();
    final favRow = await db.query(_table,
        columns: ['isFavorite'], where: 'id = ?', whereArgs: [container.id],
        limit: 1);
    final wasFav = favRow.isNotEmpty && (favRow.first['isFavorite'] == 1);
    await _upsertRows(db, container.playlistId, gen, [
      for (final e in episodes)
        {...e.toMap(), _catsKey: cats.isNotEmpty ? cats : e.categoryIds},
    ]);
    if (wasFav) {
      await setSeriesFavorite(container.playlistId, container.seriesName, true);
    }
    await db.delete(_table, where: 'id = ?', whereArgs: [container.id]);
    await db.delete(_catTable,
        where: 'channelId = ?', whereArgs: [container.id]);
  }

  static Future<int> _rowSyncGen(DatabaseExecutor db, String id) async {
    final r = await db.query(_table,
        columns: ['syncGen'], where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isEmpty ? 0 : (r.first['syncGen'] as int? ?? 0);
  }

  // ── Akışlı sync yazımı (v9) ────────────────────────────────────────────────
  //
  // Eski yol (replaceAllForPlaylist) tüm listeyi RAM'de tutup tek transaction'da
  // sil+yaz yapıyordu. Yeni yol: her batch yerinde UPSERT (id deterministik
  // uuid v5) + `syncGen` damgası; liste tamamen inince eski nesil silinir.
  //  - Kullanıcı kolonları (favori, geçmiş, süre) ve addedAt / rowid UPSERT'te
  //    değişmez → ayrı "preserve" haritası gerekmez, "yeni eklenen" sırası
  //    gerçekten yeni kanalları gösterir.
  //  - Yarıda kalan indirme eski listeyi bozmaz: bayat nesil silinmez.

  static const _catsKey = '__cats';

  /// Yeni sync nesli (ms epoch — her zaman öncekinden büyük).
  static int newSyncGeneration() => DateTime.now().millisecondsSinceEpoch;

  /// UPSERT'te güncellenen (sağlayıcıdan gelen) kolonlar.
  static const providerColumns = <String>[
    'playlistId', 'name', 'streamUrl', 'logoUrl', 'category', 'streamType',
    'seriesName', 'seasonNumber', 'episodeNumber', 'sortOrder', 'tvgId',
    'searchKey', 'syncGen',
  ];

  /// UPSERT SQL'i — kullanıcı kolonları ve addedAt SET listesinde YOK.
  static String upsertSql() {
    final cols = ['id', ...providerColumns, 'addedAt'];
    final ph = List.filled(cols.length, '?').join(', ');
    final set = providerColumns.map((c) => '$c = excluded.$c').join(', ');
    return 'INSERT INTO $_table (${cols.join(', ')}) VALUES ($ph) '
        'ON CONFLICT(id) DO UPDATE SET $set';
  }

  /// SQLite < 3.24 (Android API < 30) UPSERT sözdizimini bilmez; ilk syntax
  /// hatasında bu bayrak açılır ve süreç boyunca [legacyInsertSql] +
  /// [legacyUpdateSql] yolu kullanılır.
  static bool _upsertUnsupported = false;

  /// Eski SQLite: satır yoksa ekle (varsa dokunma) …
  static String legacyInsertSql() {
    final cols = ['id', ...providerColumns, 'addedAt'];
    final ph = List.filled(cols.length, '?').join(', ');
    return 'INSERT OR IGNORE INTO $_table (${cols.join(', ')}) VALUES ($ph)';
  }

  /// … sonra yalnız sağlayıcı kolonlarını güncelle (UPSERT'in SET listesiyle
  /// aynı: kullanıcı kolonları + addedAt korunur).
  static String legacyUpdateSql() {
    final set = providerColumns.map((c) => '$c = ?').join(', ');
    return 'UPDATE $_table SET $set WHERE id = ?';
  }

  /// UPSERT desteklenmiyor hatası mı (`near "ON"/"DO": syntax error`)?
  static bool isUpsertUnsupportedError(Object e) {
    final m = '$e'.toLowerCase();
    return m.contains('syntax error') &&
        (m.contains('near "on"') || m.contains('near "do"'));
  }

  /// Bir satırın yazım ifadeleri. [legacy]=false → tek UPSERT; true →
  /// INSERT OR IGNORE + UPDATE … WHERE id = ? (aynı kolonlar).
  static List<(String, List<Object?>)> upsertStatements(
      String playlistId, int gen, int now, Map<String, Object?> r,
      {required bool legacy}) {
    final args = upsertArgs(playlistId, gen, now, r);
    if (!legacy) return [(upsertSql(), args)];
    // args = [id, ...providerColumns, addedAt]
    return [
      (legacyInsertSql(), args),
      (legacyUpdateSql(), [...args.sublist(1, args.length - 1), args.first]),
    ];
  }

  /// [upsertSql] parametreleri — satır map'inden (toMap + opsiyonel `__cats`).
  static List<Object?> upsertArgs(
      String playlistId, int gen, int now, Map<String, Object?> r) => [
        r['id'],
        playlistId,
        r['name'] ?? '',
        r['streamUrl'] ?? '',
        r['logoUrl'] ?? '',
        r['category'] ?? 'Genel',
        r['streamType'] ?? 'live',
        r['seriesName'] ?? '',
        r['seasonNumber'] ?? 0,
        r['episodeNumber'] ?? 0,
        r['sortOrder'] ?? 0,
        r['tvgId'] ?? '',
        r['searchKey'] ??
            buildSearchKey('${r['name'] ?? ''}', '${r['seriesName'] ?? ''}'),
        gen,
        now,
      ];

  /// Bir batch satırı yaz. [rows] = `ChannelModel.toMap()` + opsiyonel
  /// `__cats` (kategori listesi). Batch tek transaction'da commit edilir.
  Future<void> upsertSyncBatch(
    String playlistId,
    int gen,
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return;
    final db = await AppDatabase.instance;
    // Sync sürerken playlist silindiyse yazma (yetim satır kalmasın).
    final alive = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM playlists WHERE id = ?) AS e',
        [playlistId]);
    if ((alive.first['e'] as int? ?? 0) == 0) return;
    await _upsertRows(db, playlistId, gen, rows);
  }

  static Future<void> _upsertRows(
    Database db,
    String playlistId,
    int gen,
    List<Map<String, Object?>> rows,
  ) async {
    if (!_upsertUnsupported) {
      try {
        await _commitRows(db, playlistId, gen, rows, legacy: false);
        return;
      } on DatabaseException catch (e) {
        if (!isUpsertUnsupportedError(e)) rethrow;
        // Batch transaction'da: hata = hiçbir satır yazılmadı → güvenle tekrar.
        _upsertUnsupported = true;
        debugPrint('[ChannelRepo] UPSERT unsupported, using legacy path');
      }
    }
    await _commitRows(db, playlistId, gen, rows, legacy: true);
  }

  static Future<void> _commitRows(
    Database db,
    String playlistId,
    int gen,
    List<Map<String, Object?>> rows, {
    required bool legacy,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final r in rows) {
      final id = r['id'] as String;
      for (final (sql, args)
          in upsertStatements(playlistId, gen, now, r, legacy: legacy)) {
        batch.rawInsert(sql, args);
      }
      batch.delete(_catTable, where: 'channelId = ?', whereArgs: [id]);
      final cats = (r[_catsKey] as List?)?.cast<String>() ?? const <String>[];
      final raw = cats.isNotEmpty ? cats : <String>['${r['category'] ?? ''}'];
      final seen = <String>{};
      for (final c in raw) {
        final t = c.trim();
        if (t.isEmpty || !seen.add(t)) continue;
        batch.insert(_catTable,
            {'channelId': id, 'playlistId': playlistId, 'category': t},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    await batch.commit(noResult: true);
  }

  /// Sync bitti: bu nesilde gelmeyen satırları sil. Xtream'de lazy çekilmiş
  /// bölümler, container'ı bu nesilde yeniden gelmiş dizilerde korunur
  /// (kullanıcının izleme durumu kaybolmasın; açılışta tazelenir).
  /// Dönüş: silinen kanal sayısı.
  /// [keepTypes]: bu sync'te yüklenemeyen türler (Xtream tür bazlı hata
  /// toleransı) — o türün eski satırları silinmez.
  Future<int> deleteStaleGeneration(String playlistId, int gen,
      {Set<String> keepTypes = const {}}) async {
    final db = await AppDatabase.instance;
    final keep = keepTypes
        .where((t) => const {'live', 'movie', 'series'}.contains(t))
        .map((t) => "'$t'")
        .join(',');
    final staleWhere = '''
      playlistId = ? AND syncGen != ?
      ${keep.isEmpty ? '' : 'AND streamType NOT IN ($keep)'}
      AND NOT (streamType = 'series' AND seasonNumber > 0 AND seriesName IN (
        SELECT seriesName FROM channels
        WHERE playlistId = ? AND syncGen = ? AND streamType = 'series'
          AND $_containerSqlBare
      ))
    ''';
    final args = [playlistId, gen, playlistId, gen];
    return db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM $_catTable WHERE playlistId = ? AND channelId IN (
          SELECT id FROM channels WHERE $staleWhere
        )
      ''', [playlistId, ...args]);
      return txn.rawDelete('DELETE FROM channels WHERE $staleWhere', args);
    });
  }

  /// Sonraki bölüm — Android `getNextEpisode` (sortOrder) → yedek bölüm
  /// numarası → sonraki sezonun ilk bölümü. Yoksa null.
  Future<ChannelModel?> getNextEpisode(ChannelModel ep) async {
    if (ep.seriesName.isEmpty) return null;
    final db = await AppDatabase.instance;
    Future<ChannelModel?> one(
        String where, List<Object?> args, String order) async {
      final rows = await db.query(_table,
          where: "playlistId = ? AND streamType = 'series' "
              'AND seriesName = ? AND $where',
          whereArgs: [ep.playlistId, ep.seriesName, ...args],
          orderBy: order,
          limit: 1);
      return rows.isEmpty ? null : ChannelModel.fromMap(rows.first);
    }

    return await one('seasonNumber = ? AND sortOrder > ?',
            [ep.seasonNumber, ep.sortOrder], 'sortOrder ASC') ??
        (ep.episodeNumber > 0
            ? await one('seasonNumber = ? AND episodeNumber > ?',
                [ep.seasonNumber, ep.episodeNumber], 'episodeNumber ASC')
            : null) ??
        await one('seasonNumber > ?', [ep.seasonNumber],
            'seasonNumber ASC, sortOrder ASC, episodeNumber ASC');
  }

  /// Dizi favorisi — Android `setFavoriteBySeriesName`: tüm bölümler.
  Future<void> setSeriesFavorite(
      String playlistId, String seriesName, bool isFavorite) async {
    if (seriesName.isEmpty) return;
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isFavorite': isFavorite ? 1 : 0},
      where: "playlistId = ? AND streamType = 'series' AND seriesName = ?",
      whereArgs: [playlistId, seriesName],
    );
  }

  /// Dizinin favori durumu: en az bir bölüm favoriyse true.
  Future<bool> isSeriesFavorite(String playlistId, String seriesName) async {
    if (seriesName.isEmpty) return false;
    final db = await AppDatabase.instance;
    final rows = await db.query(_table,
        columns: ['id'],
        where: "playlistId = ? AND streamType = 'series' AND seriesName = ? "
            'AND isFavorite = 1',
        whereArgs: [playlistId, seriesName],
        limit: 1);
    return rows.isNotEmpty;
  }

  /// Tüm izleme geçmişini temizle — Android `clearAllWatchHistory`.
  /// Favoriler korunur; cloud history kayıtları sıfırlanır (arka planda).
  /// Dönüş: temizlenen satır sayısı.
  Future<int> clearAllWatchHistory() async {
    final db = await AppDatabase.instance;
    const where = 'lastWatched > 0 OR lastPosition > 0 OR isWatched = 1';
    final rows = await db.query(_table,
        columns: ['id', 'playlistId'], where: where);
    if (rows.isEmpty) return 0;
    await db.update(
        _table, {'lastWatched': 0, 'lastPosition': 0, 'isWatched': 0},
        where: where);
    () async {
      for (final r in rows) {
        try {
          await CloudSyncService.pushHistory(
            playlistId:   r['playlistId'] as String,
            channelId:    r['id'] as String,
            lastWatched:  0,
            lastPosition: 0,
            duration:     0,
            isWatched:    false,
          );
        } catch (_) {}
      }
    }();
    return rows.length;
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
      // Sync kullanıcı verisini silmesin: favori / izleme geçmişi id bazlı
      // (uuid v5 → deterministik) korunur, yeni satırlara geri yazılır.
      final preserved = await _loadPreservedUserState(txn, playlistId);

      await txn.delete(_table,
          where: 'playlistId = ?', whereArgs: [playlistId]);
      await txn.delete(_catTable,
          where: 'playlistId = ?', whereArgs: [playlistId]);

      for (var i = 0; i < total; i += batchSize) {
        final end = (i + batchSize < total) ? i + batchSize : total;
        final chunk = channels.sublist(i, end);
        final batch = txn.batch();
        for (final ch in chunk) {
          batch.insert(
              _table, applyPreservedUserState(ch.toMap(), preserved[ch.id]),
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

  }

  /// Sync sırasında korunan kullanıcı kolonları.
  static const preservedUserColumns = <String>[
    'isFavorite', 'lastWatched', 'lastPosition', 'isWatched', 'duration',
  ];

  /// Playlist'in varsayılan dışı kullanıcı verisi olan satırları: id → kolonlar.
  static Future<Map<String, Map<String, Object?>>> _loadPreservedUserState(
      DatabaseExecutor db, String playlistId) async {
    final rows = await db.query(
      _table,
      columns: ['id', ...preservedUserColumns],
      where: 'playlistId = ? AND (isFavorite != 0 OR lastWatched > 0 '
          'OR lastPosition > 0 OR isWatched != 0 OR duration > 0)',
      whereArgs: [playlistId],
    );
    return {
      for (final r in rows)
        r['id'] as String: {
          for (final c in preservedUserColumns) c: r[c],
        },
    };
  }

  /// Yeni satır map'ine korunan kullanıcı verisini uygular (yeni map döner,
  /// girdi mutate edilmez). [preserved] null ise satır aynen döner.
  static Map<String, dynamic> applyPreservedUserState(
    Map<String, dynamic> row,
    Map<String, Object?>? preserved,
  ) {
    if (preserved == null || preserved.isEmpty) return row;
    return {
      ...row,
      for (final c in preservedUserColumns)
        if (preserved[c] != null) c: preserved[c],
    };
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?', whereArgs: [id],
    );
  }

  /// [updatePositionLocal] satir degerleri (saf, testli). Sure 10 sn'den
  /// kisaysa (henuz bilinmiyor / canli) `duration` yazilmaz.
  static Map<String, Object?> positionLocalValues(int position, int duration,
          {required int nowMs}) =>
      {
        'lastPosition': position,
        'lastWatched': nowMs,
        if (duration > 10000) 'duration': duration,
      };

  /// Yalniz yerel DB — Firestore'a YAZMAZ. Oynaticinin ~5 sn'lik ilerleme
  /// kaydi icin (bulut push'u cikista [updateWatched] / markWatched ile).
  Future<void> updatePositionLocal(String id, int position, int duration) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      positionLocalValues(position, duration,
          nowMs: DateTime.now().millisecondsSinceEpoch),
      where: 'id = ?',
      whereArgs: [id],
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

  /// Kanali izleme gecmisinden cikar — Son Izlenenler / Nerede Kaldim
  /// satirlarinda gozukmemesi icin lastWatched + lastPosition + isWatched
  /// sifirlanir. Favori durumu korunur. Cloud sync icin tombstone yerine
  /// pushHistory(0,0,0) sinyali kullanilir (LWW ile diger cihazda da silinir).
  Future<void> clearWatched(String id) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {
        'lastWatched':  0,
        'lastPosition': 0,
        'isWatched':    0,
      },
      where: 'id = ?', whereArgs: [id],
    );
    // Cloud mirror — playlistId al, history kaydini sifirla.
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
          lastWatched:  0,
          lastPosition: 0,
          duration:     0,
          isWatched:    false,
        );
      } catch (_) {}
    }();
  }

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
            // Tip değişince dizi alanları da tutarlı olmalı: series'ten
            // çıkan kanal seriesName taşımaz ("TRT" dizisi oluşmasın), yeni
            // series olan ad/bölüm ayrıştırılır. searchKey seriesName içerir.
            final (sName, season, ep) = newType == 'series'
                ? M3uParser.parseSeriesInfo(name)
                : ('', 0, 0);
            batch.update(_table, {
              'streamType':    newType,
              'seriesName':    sName,
              'seasonNumber':  season,
              'episodeNumber': ep,
              'searchKey':     buildSearchKey(name, sName),
            }, where: 'id = ?', whereArgs: [row['id']]);
            changed++;
          }
        }
        await batch.commit(noResult: true);
      }
    });
    debugPrint('[ChannelRepo] reclassified $changed/${rows.length} channels');
    return changed;
  }

  /// Playlist'teki canlı kanalların tvg-id'leri (EPG filtresi için).
  Future<Set<String>> getLiveTvgIds(String playlistId) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT DISTINCT tvgId FROM channels
      WHERE playlistId = ? AND streamType = 'live' AND tvgId != ''
    ''', [playlistId]);
    return rows.map((r) => r['tvgId'] as String).toSet();
  }

  /// Küçülme kapısı (Xtream) için tür başına sync birimi sayısı. Diziler
  /// container olarak gelir ama açılmış diziler bölümlerle değişir → dizi
  /// başına 1 (DISTINCT seriesName) sayılır.
  Future<Map<String, int>> countSyncUnitsByType(String playlistId) async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('''
      SELECT streamType AS t,
        CASE WHEN streamType = 'series'
          THEN COUNT(DISTINCT CASE WHEN seriesName != '' THEN seriesName ELSE id END)
          ELSE COUNT(*) END AS cnt
      FROM $_table WHERE playlistId = ? GROUP BY streamType
    ''', [playlistId]);
    return {
      for (final r in rows) '${r['t']}': (r['cnt'] as int?) ?? 0,
    };
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
