import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/device_tier.dart';

class AppDatabase {
  static const _version = 2;
  static const _name    = 'iptvai.db';

  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _name),
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Performance PRAGMA'lari. Cihaz tier'ina gore adaptive.
  /// High: 16MB cache, aggressive. Low: 2MB cache, guvenli.
  static Future<void> _onConfigure(Database db) async {
    final cacheKB = DeviceProfile.sqliteCacheKB;
    // WAL: yazma sirasinda okumayi bloklanmaz (concurrent read/write).
    await db.execute('PRAGMA journal_mode = WAL');
    // NORMAL: FULL'a gore daha hizli, crash riskine karsi yine guvenli.
    await db.execute('PRAGMA synchronous = NORMAL');
    // Adaptive cache: low=2MB, mid=8MB, high=16MB.
    await db.execute('PRAGMA cache_size = -$cacheKB');
    // Temp tablolari memory'de tut (siralama/join hizlanir).
    await db.execute('PRAGMA temp_store = MEMORY');
    // High-tier cihazlarda mmap ile daha hizli I/O.
    if (DeviceProfile.tier == DeviceTier.high) {
      await db.execute('PRAGMA mmap_size = 67108864'); // 64MB
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
