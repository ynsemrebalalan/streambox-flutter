import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/epg_model.dart';

class EpgRepository {
  static const _chTable  = 'epg_channels';
  static const _prTable  = 'epg_programmes';

  // ── Channels ─────────────────────────────────────────────────────────────

  Future<List<EpgChannelModel>> getChannels(String playlistId) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _chTable,
      where:     'playlistId = ?',
      whereArgs: [playlistId],
    );
    return rows.map(EpgChannelModel.fromMap).toList();
  }

  Future<void> bulkInsertChannels(List<EpgChannelModel> channels) async {
    if (channels.isEmpty) return;
    final db    = await AppDatabase.instance;
    final batch = db.batch();
    for (final ch in channels) {
      batch.insert(_chTable, ch.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteChannelsByPlaylist(String playlistId) async {
    final db = await AppDatabase.instance;
    await db.delete(_chTable,
        where: 'playlistId = ?', whereArgs: [playlistId]);
  }

  // ── Programmes ────────────────────────────────────────────────────────────

  /// Returns currently live and upcoming programmes for a tvg-id.
  Future<List<EpgProgrammeModel>> getProgrammes(
    String tvgId, {
    int? fromMs,
    int limit = 10,
  }) async {
    final db  = await AppDatabase.instance;
    final now = fromMs ?? DateTime.now().millisecondsSinceEpoch;
    // Get running + upcoming programmes
    final rows = await db.query(
      _prTable,
      where:     'channelId = ? AND stopTime > ?',
      whereArgs: [tvgId, now],
      orderBy:   'startTime ASC',
      limit:     limit,
    );
    return rows.map(EpgProgrammeModel.fromMap).toList();
  }

  Future<EpgProgrammeModel?> getCurrent(String tvgId) async {
    final db  = await AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      _prTable,
      where:     'channelId = ? AND startTime <= ? AND stopTime > ?',
      whereArgs: [tvgId, now, now],
      limit:     1,
    );
    return rows.isEmpty ? null : EpgProgrammeModel.fromMap(rows.first);
  }

  Future<void> bulkInsertProgrammes(List<EpgProgrammeModel> progs) async {
    if (progs.isEmpty) return;
    final db    = await AppDatabase.instance;
    final batch = db.batch();
    for (final p in progs) {
      batch.insert(_prTable, p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Süresi geçmiş programlar — Android `deleteExpired`: 2 günden eski.
  /// (Rehber "dün" gününü göstermeye devam eder.)
  static const retentionMs = 2 * 24 * 3600 * 1000;

  Future<int> deleteOld() async {
    final db  = await AppDatabase.instance;
    final cutoff = DateTime.now().millisecondsSinceEpoch - retentionMs;
    return db.delete(_prTable, where: 'stopTime < ?', whereArgs: [cutoff]);
  }

  // ── Akışlı EPG yazımı (v9) ───────────────────────────────────────────────

  /// Program batch'i — INSERT OR REPLACE (id = kanal_başlangıç) + nesil.
  Future<void> upsertProgrammes(
      List<Map<String, Object?>> rows, int gen) async {
    if (rows.isEmpty) return;
    final db = await AppDatabase.instance;
    final batch = db.batch();
    for (final r in rows) {
      batch.insert(_prTable, {...r, 'syncGen': gen},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Playlist'in EPG kanal listesini yenisiyle değiştirir (tek transaction).
  Future<void> replaceChannels(
      String playlistId, List<Map<String, Object?>> channels) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      await txn.delete(_chTable,
          where: 'playlistId = ?', whereArgs: [playlistId]);
      final batch = txn.batch();
      for (final c in channels) {
        batch.insert(_chTable, c, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  /// Bu tazelemede gelmeyen (kaymış/iptal) programları siler — yalnız
  /// [tvgIds] kanallarında. Yeni veri yazıldıktan SONRA çağrılır: hata
  /// durumunda eski rehber korunur.
  Future<void> deleteStaleProgrammes(List<String> tvgIds, int gen) async {
    if (tvgIds.isEmpty) return;
    final db = await AppDatabase.instance;
    const size = 400;
    for (var i = 0; i < tvgIds.length; i += size) {
      final part = tvgIds.sublist(i, (i + size).clamp(0, tvgIds.length));
      final ph = List.filled(part.length, '?').join(',');
      await db.rawDelete(
          'DELETE FROM $_prTable WHERE channelId IN ($ph) AND syncGen != ?',
          [...part, gen]);
    }
  }

  /// Rehber kapsamının sonu (ms): playlist'in kanallarındaki en geç bitiş.
  /// [tvgIds] boşsa epg_channels üzerinden. Veri yoksa 0.
  Future<int> coverageEndMs(String playlistId) async {
    final db = await AppDatabase.instance;
    final r = await db.rawQuery('''
      SELECT MAX(p.stopTime) AS m FROM $_prTable p
      INNER JOIN $_chTable c ON c.tvgId = p.channelId
      WHERE c.playlistId = ?
    ''', [playlistId]);
    return (r.first['m'] as int?) ?? 0;
  }

  /// Şu an + sonraki program (kanal listesi now/next).
  Future<({EpgProgrammeModel? now, EpgProgrammeModel? next})> getNowNext(
      String tvgId) async {
    if (tvgId.isEmpty) return (now: null, next: null);
    final list = await getProgrammes(tvgId, limit: 2);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (list.isEmpty) return (now: null, next: null);
    final first = list.first;
    if (first.startTime <= nowMs) {
      return (now: first, next: list.length > 1 ? list[1] : null);
    }
    return (now: null, next: first);
  }

  Future<void> deleteByPlaylist(String playlistId) async {
    // Programmes keyed by channelId (tvgId) — need join through epg_channels
    final db       = await AppDatabase.instance;
    final channels = await getChannels(playlistId);
    if (channels.isEmpty) {
      await deleteChannelsByPlaylist(playlistId);
      return;
    }
    // GUVENLIK: tvgId, IPTV/XMLTV saglayicisinin kontrolundeki <channel id="...">
    // attribute'undan gelir — guvenilmez. SQL'e ham gomme = SQL injection.
    // Placeholder + args ile parametrele, SQLite IN limiti icin batch'le
    // (getProgrammesForChannelsInWindow ile ayni desen).
    final ids = channels.map((c) => c.tvgId).toList();
    const batchSize = 400;
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
      final placeholders = List.filled(batch.length, '?').join(',');
      await db.rawDelete(
          'DELETE FROM $_prTable WHERE channelId IN ($placeholders)', batch);
    }
    await deleteChannelsByPlaylist(playlistId);
  }

  /// Birden fazla tvgId için belirli zaman aralığındaki programları toplu
  /// çeker. EPG Guide grid'i için optimize: tek sorgu N×M gösterimi.
  Future<Map<String, List<EpgProgrammeModel>>> getProgrammesForChannelsInWindow({
    required List<String> tvgIds,
    required int startMs,
    required int endMs,
  }) async {
    if (tvgIds.isEmpty) return {};
    final db = await AppDatabase.instance;
    // SQLite IN limit ~500 — playlist'lerde live kanal sayısı genelde
    // 1000-3000, batchle.
    final result = <String, List<EpgProgrammeModel>>{};
    const batchSize = 400;
    for (var i = 0; i < tvgIds.length; i += batchSize) {
      final batch = tvgIds.sublist(
          i, (i + batchSize).clamp(0, tvgIds.length));
      final placeholders = List.filled(batch.length, '?').join(',');
      final rows = await db.rawQuery(
        'SELECT * FROM $_prTable '
        'WHERE channelId IN ($placeholders) '
        'AND stopTime > ? AND startTime < ? '
        'ORDER BY channelId, startTime ASC',
        [...batch, startMs, endMs],
      );
      for (final r in rows) {
        final p = EpgProgrammeModel.fromMap(r);
        result.putIfAbsent(p.channelId, () => []).add(p);
      }
    }
    return result;
  }
}
