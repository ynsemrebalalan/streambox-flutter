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

  Future<void> deleteOld() async {
    final db  = await AppDatabase.instance;
    final cutoff = DateTime.now().millisecondsSinceEpoch - 3600000; // 1h ago
    await db.delete(_prTable,
        where: 'stopTime < ?', whereArgs: [cutoff]);
  }

  Future<void> deleteByPlaylist(String playlistId) async {
    // Programmes keyed by channelId (tvgId) — need join through epg_channels
    final db       = await AppDatabase.instance;
    final channels = await getChannels(playlistId);
    if (channels.isEmpty) return;
    final ids = channels.map((c) => "'${c.tvgId}'").join(',');
    await db.rawDelete(
        'DELETE FROM $_prTable WHERE channelId IN ($ids)');
    await deleteChannelsByPlaylist(playlistId);
  }
}
