import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../models/profile_model.dart';

/// Profil CRUD + per-profile favorite/watchlist sorgulari (Phase 6).
class ProfileRepository {
  static const _t = 'profiles';
  static const _favT = 'profile_favorites';
  static const _wlT  = 'profile_watchlist';
  static const defaultProfileId = 'default';
  static final _uuid = Uuid();

  // ── Profiles CRUD ─────────────────────────────────────────────────────────

  Future<List<Profile>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_t, orderBy: 'isDefault DESC, createdAt ASC');
    return rows.map((r) => Profile.fromMap(r)).toList();
  }

  Future<Profile?> getById(String id) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(_t, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Profile.fromMap(rows.first);
  }

  Future<int> count() async {
    final db = await AppDatabase.instance;
    final rows = await db.rawQuery('SELECT COUNT(*) c FROM $_t');
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<Profile> create({required String name, String icon = 'person'}) async {
    final db = await AppDatabase.instance;
    final id = _uuid.v4();
    final p = Profile(
      id:        id,
      name:      name,
      icon:      icon,
      isDefault: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert(_t, p.toMap());
    return p;
  }

  Future<void> update(Profile p) async {
    final db = await AppDatabase.instance;
    await db.update(_t, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> delete(String id) async {
    if (id == defaultProfileId) {
      throw StateError('Default profile cannot be deleted');
    }
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      await txn.delete(_favT, where: 'profileId = ?', whereArgs: [id]);
      await txn.delete(_wlT,  where: 'profileId = ?', whereArgs: [id]);
      await txn.delete(_t,    where: 'id = ?',        whereArgs: [id]);
    });
  }

  // ── Per-profile favorites ─────────────────────────────────────────────────

  Future<void> addFavorite(String profileId, String channelId) async {
    final db = await AppDatabase.instance;
    await db.insert(
      _favT,
      {
        'profileId': profileId,
        'channelId': channelId,
        'addedAt':   DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String profileId, String channelId) async {
    final db = await AppDatabase.instance;
    await db.delete(
      _favT,
      where: 'profileId = ? AND channelId = ?',
      whereArgs: [profileId, channelId],
    );
  }

  Future<bool> isFavorite(String profileId, String channelId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      _favT,
      where: 'profileId = ? AND channelId = ?',
      whereArgs: [profileId, channelId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> favoriteChannelIds(String profileId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      _favT,
      columns: ['channelId'],
      where: 'profileId = ?',
      whereArgs: [profileId],
    );
    return rows.map((r) => r['channelId'] as String).toSet();
  }

  // ── Per-profile watchlist ────────────────────────────────────────────────

  Future<void> addWatchlist(
      String profileId, String channelId, String playlistId) async {
    final db = await AppDatabase.instance;
    await db.insert(
      _wlT,
      {
        'profileId':  profileId,
        'channelId':  channelId,
        'playlistId': playlistId,
        'addedAt':    DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeWatchlist(String profileId, String channelId) async {
    final db = await AppDatabase.instance;
    await db.delete(
      _wlT,
      where: 'profileId = ? AND channelId = ?',
      whereArgs: [profileId, channelId],
    );
  }

  Future<bool> isInWatchlist(String profileId, String channelId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      _wlT,
      where: 'profileId = ? AND channelId = ?',
      whereArgs: [profileId, channelId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
