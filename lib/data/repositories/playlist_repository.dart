import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../models/playlist_model.dart';

class PlaylistRepository {
  static const _table = 'playlists';
  static const _uuid  = Uuid();

  Future<List<PlaylistModel>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_table, orderBy: 'addedAt ASC');
    return rows.map(PlaylistModel.fromMap).toList();
  }

  Future<PlaylistModel?> getById(String id) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : PlaylistModel.fromMap(rows.first);
  }

  Future<PlaylistModel> insert(PlaylistModel playlist) async {
    final db = await AppDatabase.instance;
    final p  = playlist.id.isEmpty
        ? playlist.copyWith(id: _uuid.v4(), addedAt: DateTime.now().millisecondsSinceEpoch)
        : playlist;
    await db.insert(_table, p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return p;
  }

  Future<void> update(PlaylistModel playlist) async {
    final db = await AppDatabase.instance;
    await db.update(_table, playlist.toMap(), where: 'id = ?', whereArgs: [playlist.id]);
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateEtag(String id, {required String etag, required String lastModified}) async {
    final db = await AppDatabase.instance;
    await db.update(
      _table,
      {'etag': etag, 'lastModified': lastModified},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
