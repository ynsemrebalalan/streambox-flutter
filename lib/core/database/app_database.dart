import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/device_tier.dart';
import '../utils/search_normalizer.dart';

class AppDatabase {
  // v7 — CloudSync conflict resolution + Anon→linked local migration:
  //   - tum cloud-sync edilen tablolara `ownerUid` (multi-user izolasyon) +
  //     `updatedAt` (LWW conflict resolution) + `lastSyncedAt` (push delta)
  //     kolonlari eklendi.
  //   - `sync_tombstones` tablosu: silmelerin Firestore'a propagate edilebilmesi
  //     icin tombstone log.
  // v8 — Arama: `channels.searchKey` (Türkçe katlanmış name + seriesName).
  //   FTS4 (`channel_fts`) artık bakımı yapılmıyor; tablo yerinde kalır.
  // v9 — Android içerik paritesi:
  //   - playlists: `epgUrl` (playlist başına EPG, eski global ayar taşındı),
  //     `lastRefreshAt` / `lastRefreshAttemptAt` (otomatik yenileme aralığı).
  //   - channels: `syncGen` (akışlı M3U/Xtream yazımı: yerinde upsert, sonunda
  //     eski nesil silinir — 100K+ liste RAM'de iki kez tutulmaz).
  //   - watchlist: kanal snapshot kolonları (cross-playlist liste, kanal
  //     silinse bile kayıt görünür).
  //   - epg_programmes: `syncGen` (akışlı XMLTV yazımı, bayat program temizliği).
  //   - Gizli kategoriler global → aktif playlist anahtarına taşındı.
  static const _version = 9;
  static const _name    = 'iptvai.db';

  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, _name);
    try {
      return await openDatabase(
        fullPath,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      // Open ile pragma'siz retry — onConfigure tarafinda beklenmedik bir
      // exception olursa DB hic acilmasin yerine, yavas ama calisir bir DB
      // ile devam et. Kullaniciya hata patlatmaktan iyidir.
      // ignore: avoid_print
      print('AppDatabase: primary open failed ($e), retrying without pragmas');
      return await openDatabase(
        fullPath,
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  /// Performance PRAGMA'lari. Cihaz tier'ina gore adaptive.
  /// High: 16MB cache, aggressive. Low: 2MB cache, guvenli.
  ///
  /// iOS notu: PRAGMA journal_mode result set dondurur ("wal") — execute()
  /// bunu sqflite_darwin'de "code=0 not an error" exception'i ile reddeder.
  /// rawQuery dogru API. Ayrica her pragma kendi try-catch'inde: biri fail
  /// olsa bile diger pragma'lar uygulanir, DB acik kalir.
  static Future<void> _onConfigure(Database db) async {
    final cacheKB = DeviceProfile.sqliteCacheKB;

    Future<void> tryPragma(String pragma) async {
      try {
        await db.rawQuery(pragma);
      } catch (_) {
        // Sessizce yut: pragma uygulanamadi, default davranis devam eder.
      }
    }

    // WAL: yazma sirasinda okumayi bloklanmaz. iOS sandbox bazen reddeder —
    // o durumda DELETE journal mode (default) ile devam, performans hafif duser.
    await tryPragma('PRAGMA journal_mode = WAL');
    await tryPragma('PRAGMA synchronous = NORMAL');
    await tryPragma('PRAGMA cache_size = -$cacheKB');
    await tryPragma('PRAGMA temp_store = MEMORY');
    if (DeviceProfile.tier == DeviceTier.high) {
      await tryPragma('PRAGMA mmap_size = 67108864'); // 64MB
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE playlists (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        type         TEXT NOT NULL,
        url          TEXT NOT NULL,
        username     TEXT DEFAULT '',
        password     TEXT DEFAULT '',
        addedAt      INTEGER DEFAULT 0,
        allowedTypes TEXT DEFAULT 'live,movie,series',
        etag         TEXT DEFAULT '',
        lastModified TEXT DEFAULT '',
        ownerUid     TEXT,
        updatedAt    INTEGER DEFAULT 0,
        lastSyncedAt INTEGER,
        epgUrl       TEXT DEFAULT '',
        lastRefreshAt        INTEGER DEFAULT 0,
        lastRefreshAttemptAt INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE channels (
        id            TEXT PRIMARY KEY,
        playlistId    TEXT NOT NULL,
        name          TEXT NOT NULL,
        streamUrl     TEXT NOT NULL,
        logoUrl       TEXT DEFAULT '',
        category      TEXT DEFAULT 'Genel',
        streamType    TEXT DEFAULT 'live',
        isFavorite    INTEGER DEFAULT 0,
        lastWatched   INTEGER DEFAULT 0,
        lastPosition  INTEGER DEFAULT 0,
        seriesName    TEXT DEFAULT '',
        seasonNumber  INTEGER DEFAULT 0,
        episodeNumber INTEGER DEFAULT 0,
        sortOrder     INTEGER DEFAULT 0,
        tvgId         TEXT DEFAULT '',
        addedAt       INTEGER DEFAULT 0,
        isWatched     INTEGER DEFAULT 0,
        duration      INTEGER DEFAULT 0,
        ownerUid      TEXT,
        updatedAt     INTEGER DEFAULT 0,
        lastSyncedAt  INTEGER,
        searchKey     TEXT DEFAULT '',
        syncGen       INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_channels_playlist ON channels(playlistId);
    ''');
    await db.execute('''
      CREATE INDEX idx_channels_type ON channels(streamType);
    ''');
    await db.execute('''
      CREATE INDEX idx_channels_category ON channels(category);
    ''');
    // Composite index: home ekrandaki getByType / getByCategory icin optimum.
    // (playlistId, streamType, category) kombinasyonu SQLite'in direkt index-only
    // query yapmasini saglar → tablo taramasi yok.
    await db.execute('''
      CREATE INDEX idx_channels_composite ON channels(playlistId, streamType, category, sortOrder);
    ''');
    await db.execute('''
      CREATE INDEX idx_channels_recent ON channels(playlistId, lastWatched DESC);
    ''');
    // v9 — global "Son İzlenenler" (Android getRecentChannels) için.
    await db.execute('''
      CREATE INDEX idx_channels_lastwatched ON channels(lastWatched);
    ''');

    await db.execute('''
      CREATE TABLE epg_channels (
        tvgId       TEXT NOT NULL,
        playlistId  TEXT NOT NULL,
        displayName TEXT NOT NULL,
        icon        TEXT DEFAULT '',
        PRIMARY KEY (tvgId, playlistId)
      )
    ''');

    await db.execute('''
      CREATE TABLE epg_programmes (
        id          TEXT PRIMARY KEY,
        channelId   TEXT NOT NULL,
        title       TEXT NOT NULL,
        description TEXT DEFAULT '',
        startTime   INTEGER NOT NULL,
        stopTime    INTEGER NOT NULL,
        category    TEXT DEFAULT '',
        icon        TEXT DEFAULT '',
        syncGen     INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_epg_channel ON epg_programmes(channelId, startTime);
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // AI subtitle cache (60-saniyelik segment boundary).
    await db.execute('''
      CREATE TABLE subtitle_cache (
        id         TEXT PRIMARY KEY,
        channelId  TEXT NOT NULL,
        segmentSec INTEGER NOT NULL,
        cuesJson   TEXT NOT NULL DEFAULT '',
        provider   TEXT NOT NULL DEFAULT '',
        cachedAt   INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_subtitle_cache ON subtitle_cache(channelId, segmentSec)
    ''');

    // FTS4 full-text search (100K+ kanalda hizli arama).
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS channel_fts
      USING fts4(name, category, content="channels", tokenize=unicode61)
    ''');

    // Watchlist (Pro: "Sonra İzle" / "İzleme Listem"). Composite PK
    // — aynı kanal listede iki kez olmaz; addedAt sıralama için.
    await db.execute('''
      CREATE TABLE watchlist (
        channelId    TEXT NOT NULL,
        playlistId   TEXT NOT NULL,
        addedAt      INTEGER NOT NULL DEFAULT 0,
        ownerUid     TEXT,
        updatedAt    INTEGER DEFAULT 0,
        lastSyncedAt INTEGER,
        name          TEXT DEFAULT '',
        streamUrl     TEXT DEFAULT '',
        logoUrl       TEXT DEFAULT '',
        streamType    TEXT DEFAULT 'live',
        category      TEXT DEFAULT '',
        seriesName    TEXT DEFAULT '',
        seasonNumber  INTEGER DEFAULT 0,
        episodeNumber INTEGER DEFAULT 0,
        PRIMARY KEY (channelId, playlistId)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_watchlist_added_all ON watchlist(addedAt DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_watchlist_added ON watchlist(playlistId, addedAt DESC)
    ''');

    // Phase 6 — Multi-profile (Pro). Free=1 profil, Pro=sinirsiz.
    await _createProfilesSchema(db);

    // v6 — Channel ↔ Category junction. Xtream `category_ids` (plural array)
    // ve M3U virgüllü group-title (örn. "Aksiyon,Komedi") çoklu kategori
    // desteği için. channels.category KALDI (display + cloud sync diff için);
    // sort/filter junction üzerinden JOIN ile yapılır.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS channel_categories (
        channelId  TEXT NOT NULL,
        playlistId TEXT NOT NULL,
        category   TEXT NOT NULL,
        PRIMARY KEY (channelId, category)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_chcat_playlist_cat
      ON channel_categories(playlistId, category)
    ''');

    // v7 — Sync tombstones: silinen kayitlarin Firestore'a propagate
    // edilebilmesi icin. Push asamasinda syncedAt set edilince temizlenir.
    await _createSyncTombstones(db);
  }

  /// SQLite ALTER TABLE ADD COLUMN idempotent wrapper. Kolon zaten varsa
  /// 'duplicate column name' patlar, yutariz. Tablonun var oldugu varsayilir;
  /// tablo yoksa "no such table" patlar, o da yutulur (defensif migration).
  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      // PRAGMA table_info ile kolon listesi cekip var mi diye check etmek
      // daha temiz olabilir ama 1 round-trip vs 1 try/catch — hot path degil,
      // try/catch yeterli.
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Sessizce yut: kolon zaten var veya tablo yok.
    }
  }

  /// v7 — Sync tombstone tablosu. Local silme → tombstone insert →
  /// CloudSync push delete → syncedAt set. Tombstone reset edilmez (idempotent).
  static Future<void> _createSyncTombstones(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_tombstones (
        tableName TEXT NOT NULL,
        recordId  TEXT NOT NULL,
        ownerUid  TEXT NOT NULL,
        deletedAt INTEGER NOT NULL,
        syncedAt  INTEGER,
        PRIMARY KEY (tableName, recordId, ownerUid)
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tombstones_owner_synced
      ON sync_tombstones(ownerUid, syncedAt)
    ''');
  }

  /// Phase 6 — profiles + profile_favorites + profile_watchlist tablolari.
  /// Default profil insert edilir, isFavorite=1 channels seed edilir.
  static Future<void> _createProfilesSchema(Database db) async {
    await db.execute('''
      CREATE TABLE profiles (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        icon         TEXT DEFAULT 'person',
        isDefault    INTEGER NOT NULL DEFAULT 0,
        createdAt    INTEGER NOT NULL DEFAULT 0,
        ownerUid     TEXT,
        updatedAt    INTEGER DEFAULT 0,
        lastSyncedAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE profile_favorites (
        profileId  TEXT NOT NULL,
        channelId  TEXT NOT NULL,
        addedAt    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (profileId, channelId)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_profile_favorites_profile
      ON profile_favorites(profileId, addedAt DESC)
    ''');
    await db.execute('''
      CREATE TABLE profile_watchlist (
        profileId  TEXT NOT NULL,
        channelId  TEXT NOT NULL,
        playlistId TEXT NOT NULL,
        addedAt    INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (profileId, channelId)
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_profile_watchlist_profile
      ON profile_watchlist(profileId, addedAt DESC)
    ''');

    // Default profili olustur — onCreate'de henuz channel yok ama upgrade'de
    // isFavorite=1 channel'lar bu profile aktarilir.
    await db.insert('profiles', {
      'id':        'default',
      'name':      'Default',
      'icon':      'person',
      'isDefault': 1,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: composite index'ler ekle (home hiz optimizasyonu).
    if (oldVersion < 2) {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_channels_composite
        ON channels(playlistId, streamType, category, sortOrder)
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_channels_recent
        ON channels(playlistId, lastWatched DESC)
      ''');
    }
    // v2 → v3: subtitle_cache + FTS4 tablosu.
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subtitle_cache (
          id         TEXT PRIMARY KEY,
          channelId  TEXT NOT NULL,
          segmentSec INTEGER NOT NULL,
          cuesJson   TEXT NOT NULL DEFAULT '',
          provider   TEXT NOT NULL DEFAULT '',
          cachedAt   INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_subtitle_cache
        ON subtitle_cache(channelId, segmentSec)
      ''');
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS channel_fts
        USING fts4(name, category, content="channels", tokenize=unicode61)
      ''');
    }
    // v3 → v4: Watchlist tablosu (Pro feature — "Sonra İzle").
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS watchlist (
          channelId  TEXT NOT NULL,
          playlistId TEXT NOT NULL,
          addedAt    INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY (channelId, playlistId)
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_watchlist_added
        ON watchlist(playlistId, addedAt DESC)
      ''');
    }
    // v4 → v5: Multi-profile (Pro). Default profil + mevcut isFavorite=1
    // kanallari profil_favorites'e seed et.
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profiles (
          id        TEXT PRIMARY KEY,
          name      TEXT NOT NULL,
          icon      TEXT DEFAULT 'person',
          isDefault INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile_favorites (
          profileId  TEXT NOT NULL,
          channelId  TEXT NOT NULL,
          addedAt    INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY (profileId, channelId)
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_profile_favorites_profile
        ON profile_favorites(profileId, addedAt DESC)
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile_watchlist (
          profileId  TEXT NOT NULL,
          channelId  TEXT NOT NULL,
          playlistId TEXT NOT NULL,
          addedAt    INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY (profileId, channelId)
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_profile_watchlist_profile
        ON profile_watchlist(profileId, addedAt DESC)
      ''');

      // Default profili insert et (yoksa).
      final existing = await db.query(
        'profiles',
        where: 'id = ?',
        whereArgs: ['default'],
      );
      if (existing.isEmpty) {
        await db.insert('profiles', {
          'id':        'default',
          'name':      'Default',
          'icon':      'person',
          'isDefault': 1,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Mevcut isFavorite=1 channels -> default profile_favorites.
      await db.execute('''
        INSERT OR IGNORE INTO profile_favorites (profileId, channelId, addedAt)
        SELECT 'default', id,
               CASE WHEN lastWatched > 0 THEN lastWatched
                    ELSE strftime('%s','now') * 1000 END
        FROM channels
        WHERE isFavorite = 1
      ''');

      // Mevcut watchlist -> default profile_watchlist.
      await db.execute('''
        INSERT OR IGNORE INTO profile_watchlist (profileId, channelId, playlistId, addedAt)
        SELECT 'default', channelId, playlistId, addedAt
        FROM watchlist
      ''');
    }
    // v5 → v6: Channel ↔ Category junction (Xtream `category_ids` + M3U çoklu
    // group-title). Mevcut channels.category seed edilir; geriye dönük
    // veritabanlarında IF NOT EXISTS ile idempotent.
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS channel_categories (
          channelId  TEXT NOT NULL,
          playlistId TEXT NOT NULL,
          category   TEXT NOT NULL,
          PRIMARY KEY (channelId, category)
        )
      ''');
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_chcat_playlist_cat
        ON channel_categories(playlistId, category)
      ''');
      // Seed: mevcut channels.category değerinden junction doldur.
      // TRIM ile baş/son boşluk normalize, boş kategori atla.
      await db.execute('''
        INSERT OR IGNORE INTO channel_categories (channelId, playlistId, category)
        SELECT id, playlistId, TRIM(category)
        FROM channels
        WHERE category IS NOT NULL AND TRIM(category) != ''
      ''');
    }

    // v6 → v7: CloudSync conflict resolution (LWW) + Anon→linked migration.
    // - Tum cloud-sync edilen tablolara ownerUid + updatedAt + lastSyncedAt
    //   kolonlari eklenir.
    // - sync_tombstones tablosu: silmelerin remote'a propagate edilebilmesi.
    //
    // SQLite ALTER TABLE ADD COLUMN: IF NOT EXISTS desteklemez. Migration
    // idempotent olsun diye her ALTER kendi try/catch'inde — kolon zaten varsa
    // 'duplicate column' patlar, yutariz.
    if (oldVersion < 7) {
      const tablesNeedingOwnerUid = [
        'playlists',
        'channels',
        'watchlist',
        'profiles',
      ];
      for (final t in tablesNeedingOwnerUid) {
        await _addColumnIfMissing(db, t, 'ownerUid', 'TEXT');
        await _addColumnIfMissing(db, t, 'updatedAt', 'INTEGER DEFAULT 0');
        await _addColumnIfMissing(db, t, 'lastSyncedAt', 'INTEGER');
      }

      // Mevcut satirlar icin updatedAt seed: NULL/0 -> simdi (ms epoch).
      // Boylece migration sonrasi local satirlar "yeni" sayilir, ilk
      // sync'te push'e dahil olur. (Cloud'da daha yeni varsa LWW ezer.)
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final t in tablesNeedingOwnerUid) {
        try {
          await db.execute(
            'UPDATE $t SET updatedAt = ? WHERE updatedAt IS NULL OR updatedAt = 0',
            [now],
          );
        } catch (_) {
          // Tablo yoksa atla (defensif).
        }
      }

      // Tombstone tablosu.
      await _createSyncTombstones(db);
    }

    // v7 → v8: Arama anahtarı. Burada YALNIZ kolon eklenir: 50k kanallık
    // backfill onUpgrade'de (DB açılışını bloklayan transaction) yapılırsa
    // açılış saniyelerce takılır / iOS watchdog'a takılabilir. Katlama
    // (İ/ı/ş/ğ...) main.dart'taki açılış sonrası backfillSearchKeys ile
    // Dart'ta doldurulur (idempotent).
    if (oldVersion < 8) {
      await _addColumnIfMissing(db, 'channels', 'searchKey', "TEXT DEFAULT ''");
      // Eski FTS index'i bayat token'larla dolu — boşalt (tablo yerinde kalır).
      try {
        await db.execute(
            "INSERT INTO channel_fts(channel_fts) VALUES('delete-all')");
      } catch (_) {
        // FTS tablosu yoksa atla.
      }
    }

    // v8 → v9: Android içerik paritesi (bkz. _version notu).
    if (oldVersion < 9) {
      await _upgradeToV9(db);
    }

    // Ensure all tables exist even if upgrading from a corrupted/partial state
    if (oldVersion < newVersion) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS playlists (
          id           TEXT PRIMARY KEY,
          name         TEXT NOT NULL,
          type         TEXT NOT NULL,
          url          TEXT NOT NULL,
          username     TEXT DEFAULT '',
          password     TEXT DEFAULT '',
          addedAt      INTEGER DEFAULT 0,
          allowedTypes TEXT DEFAULT 'live,movie,series',
          etag         TEXT DEFAULT '',
          lastModified TEXT DEFAULT '',
          epgUrl       TEXT DEFAULT '',
          lastRefreshAt        INTEGER DEFAULT 0,
          lastRefreshAttemptAt INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS channels (
          id            TEXT PRIMARY KEY,
          playlistId    TEXT NOT NULL,
          name          TEXT NOT NULL,
          streamUrl     TEXT NOT NULL,
          logoUrl       TEXT DEFAULT '',
          category      TEXT DEFAULT 'Genel',
          streamType    TEXT DEFAULT 'live',
          isFavorite    INTEGER DEFAULT 0,
          lastWatched   INTEGER DEFAULT 0,
          lastPosition  INTEGER DEFAULT 0,
          seriesName    TEXT DEFAULT '',
          seasonNumber  INTEGER DEFAULT 0,
          episodeNumber INTEGER DEFAULT 0,
          sortOrder     INTEGER DEFAULT 0,
          tvgId         TEXT DEFAULT '',
          addedAt       INTEGER DEFAULT 0,
          isWatched     INTEGER DEFAULT 0,
          duration      INTEGER DEFAULT 0,
          searchKey     TEXT DEFAULT '',
          syncGen       INTEGER DEFAULT 0
        )
      ''');
    }
  }

  /// v9 şema + veri taşıma. Her adım idempotent; biri patlarsa diğerleri
  /// yine uygulanır (DB açılışı düşmesin).
  static Future<void> _upgradeToV9(Database db) async {
    await _addColumnIfMissing(db, 'playlists', 'epgUrl', "TEXT DEFAULT ''");
    await _addColumnIfMissing(
        db, 'playlists', 'lastRefreshAt', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing(
        db, 'playlists', 'lastRefreshAttemptAt', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing(db, 'channels', 'syncGen', 'INTEGER DEFAULT 0');
    await _addColumnIfMissing(
        db, 'epg_programmes', 'syncGen', 'INTEGER DEFAULT 0');
    const wlCols = <String, String>{
      'name':          "TEXT DEFAULT ''",
      'streamUrl':     "TEXT DEFAULT ''",
      'logoUrl':       "TEXT DEFAULT ''",
      'streamType':    "TEXT DEFAULT 'live'",
      'category':      "TEXT DEFAULT ''",
      'seriesName':    "TEXT DEFAULT ''",
      'seasonNumber':  'INTEGER DEFAULT 0',
      'episodeNumber': 'INTEGER DEFAULT 0',
    };
    for (final e in wlCols.entries) {
      await _addColumnIfMissing(db, 'watchlist', e.key, e.value);
    }
    Future<void> tryExec(String sql) async {
      try {
        await db.execute(sql);
      } catch (_) {
        // Defansif: tablo/kayıt yoksa atla.
      }
    }

    await tryExec('CREATE INDEX IF NOT EXISTS idx_channels_lastwatched '
        'ON channels(lastWatched)');
    await tryExec('CREATE INDEX IF NOT EXISTS idx_watchlist_added_all '
        'ON watchlist(addedAt DESC)');
    // Watchlist snapshot backfill — mevcut kayıtlar kanal tablosundan dolar.
    await tryExec('''
      UPDATE watchlist SET
        name          = COALESCE((SELECT c.name FROM channels c WHERE c.id = watchlist.channelId), name),
        streamUrl     = COALESCE((SELECT c.streamUrl FROM channels c WHERE c.id = watchlist.channelId), streamUrl),
        logoUrl       = COALESCE((SELECT c.logoUrl FROM channels c WHERE c.id = watchlist.channelId), logoUrl),
        streamType    = COALESCE((SELECT c.streamType FROM channels c WHERE c.id = watchlist.channelId), streamType),
        category      = COALESCE((SELECT c.category FROM channels c WHERE c.id = watchlist.channelId), category),
        seriesName    = COALESCE((SELECT c.seriesName FROM channels c WHERE c.id = watchlist.channelId), seriesName),
        seasonNumber  = COALESCE((SELECT c.seasonNumber FROM channels c WHERE c.id = watchlist.channelId), seasonNumber),
        episodeNumber = COALESCE((SELECT c.episodeNumber FROM channels c WHERE c.id = watchlist.channelId), episodeNumber)
      WHERE name IS NULL OR name = ''
    ''');
    // Global EPG URL → (boş olan) tüm playlist'ler. Eski sürümde tek URL
    // hangi playlist aktifse onun için kullanılıyordu.
    await tryExec('''
      UPDATE playlists SET epgUrl = (
        SELECT value FROM settings WHERE key = 'epg_url'
      )
      WHERE (epgUrl IS NULL OR epgUrl = '')
        AND EXISTS (SELECT 1 FROM settings WHERE key = 'epg_url' AND value != '')
    ''');
    // Global gizli kategoriler → aktif playlist'in anahtarı.
    await tryExec('''
      INSERT OR IGNORE INTO settings (key, value)
      SELECT 'hidden_categories_' || a.value, h.value
      FROM settings h, settings a
      WHERE h.key = 'hidden_categories' AND a.key = 'active_playlist_id'
        AND a.value != ''
    ''');
  }

  /// `searchKey` boş/NULL olan kanalları Dart'ta katlanmış anahtarla doldurur.
  /// Chunk'lı: bellek sabit kalır, 50k kanalda bile tek seferde yüklenmez.
  /// Dönüş: güncellenen satır sayısı.
  /// rowid imleçli sayfa sorgusu: her tur yalnız ilerideki satırlara bakar
  /// (aynı boş satırları tekrar tekrar taramaz, sonsuz döngü riski yok).
  static const searchKeyBackfillSql =
      'SELECT rowid AS rid, name, seriesName FROM channels '
      "WHERE rowid > ? AND (searchKey IS NULL OR searchKey = '') "
      'ORDER BY rowid LIMIT ?';

  static Future<int> backfillSearchKeys(DatabaseExecutor db,
      {int chunkSize = 1000}) async {
    var total = 0;
    var lastRowid = 0;
    while (true) {
      final rows =
          await db.rawQuery(searchKeyBackfillSql, [lastRowid, chunkSize]);
      if (rows.isEmpty) break;
      final batch = db.batch();
      for (final r in rows) {
        var key = buildSearchKey(
          (r['name'] as String?) ?? '',
          (r['seriesName'] as String?) ?? '',
        );
        // Boş ad: tek boşluk = "işlendi" (sonraki açılışlarda yeniden taranmaz).
        if (key.isEmpty) key = ' ';
        final rid = r['rid'] as int;
        batch.update('channels', {'searchKey': key},
            where: 'rowid = ?', whereArgs: [rid]);
        if (rid > lastRowid) lastRowid = rid;
      }
      await batch.commit(noResult: true);
      total += rows.length;
      if (rows.length < chunkSize) break;
    }
    return total;
  }
}
