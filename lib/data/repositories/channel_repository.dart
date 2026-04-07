import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/device_tier.dart';
import '../models/channel_model.dart';

class ChannelRepository {
  static const _table = 'channels';

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

  Future<List<ChannelModel>> getByType(String playlistId, String streamType) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND streamType = ?',
      whereArgs: [playlistId, streamType],
      orderBy:   'sortOrder ASC, name ASC',
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
      orderBy:   'sortOrder ASC, name ASC',
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

  Future<List<ChannelModel>> search(String playlistId, String query) async {
    final db   = await AppDatabase.instance;
    final q    = '%${query.toLowerCase()}%';
    final rows = await db.query(
      _table,
      where:     'playlistId = ? AND LOWER(name) LIKE ?',
      whereArgs: [playlistId, q],
      orderBy:   'name ASC',
      limit:     100,
    );
    return rows.map(ChannelModel.fromMap).toList();
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
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<void> updateWatched(String id, {required int position}) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {
        'lastWatched':  DateTime.now().millisecondsSinceEpoch,
        'lastPosition': position,
      },
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<void> markWatched(String id) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'isWatched': 1},
      where: 'id = ?', whereArgs: [id],
    );
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
