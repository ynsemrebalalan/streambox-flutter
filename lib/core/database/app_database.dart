import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/device_tier.dart';

class AppDatabase {
  static const _version = 3;
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
        lastModified TEXT DEFAULT ''
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
        duration      INTEGER DEFAULT 0
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
        icon        TEXT DEFAULT ''
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
          lastModified TEXT DEFAULT ''
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
          duration      INTEGER DEFAULT 0
        )
      ''');
    }
  }
}
