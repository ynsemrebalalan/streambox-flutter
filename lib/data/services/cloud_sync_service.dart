import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/channel_model.dart';
import '../models/playlist_model.dart';

/// Pro: kullanıcı bazlı cross-device cloud sync. Firestore'da user UID
/// altında 4 koleksiyon: playlists / favorites / watchlist / history.
///
/// Mimari:
///   - Local SQLite primary; cloud mirror.
///   - Push fire-and-forget (UI bloklamaz, fail debugPrint).
///   - Pull last-write-wins (timestamp karşılaştırması).
///   - Anon kullanıcı sync KAPALI — sadece authenticated + isPro.
///
/// Şema:
///   users/{uid}/playlists/{pid}    → {id, name, type, url, username, password, allowedTypes, updatedAt}
///   users/{uid}/favorites/{key}    → {playlistId, channelId, name, logo, addedAt}
///   users/{uid}/watchlist/{key}    → {playlistId, channelId, name, logo, addedAt}
///   users/{uid}/history/{key}      → {playlistId, channelId, lastWatched, lastPosition, duration, isWatched, updatedAt}
///   key = "${playlistId}__${channelId}"  (Firestore doc id'si — `/` legal değil)
///
/// Tüm metodlar lazy Firebase erişimi yapar — `firebaseReadyProvider` ile
/// gate edilen path'lerden çağrılmalı (`firebase_sync_service.dart` ile aynı
/// pattern, race önleme).
class CloudSyncService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Authenticated + non-anon ise UID döner. Anon/null → null.
  static String? _userUid() {
    final u = _auth.currentUser;
    if (u == null || u.isAnonymous) return null;
    return u.uid;
  }

  static String _key(String playlistId, String channelId) =>
      '${playlistId}__$channelId';

  // ── Push (local → cloud) ─────────────────────────────────────────────────

  static Future<void> pushPlaylist(PlaylistModel p) async {
    final uid = _userUid();
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('playlists')
          .doc(p.id)
          .set({
        'id':           p.id,
        'name':         p.name,
        'type':         p.type,
        'url':          p.url,
        'username':     p.username,
        // TODO: encrypt password with device UUID before storing.
        'password':     p.password,
        'allowedTypes': p.allowedTypes,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[CloudSync] pushPlaylist fail: $e');
    }
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final uid = _userUid();
    if (uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('playlists')
          .doc(playlistId)
          .delete();
    } catch (e) {
      debugPrint('[CloudSync] deletePlaylist fail: $e');
    }
  }

  static Future<void> pushFavorite(ChannelModel ch, {required bool added}) async {
    final uid = _userUid();
    if (uid == null) return;
    final key = _key(ch.playlistId, ch.id);
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(key);
      if (added) {
        await docRef.set({
          'playlistId': ch.playlistId,
          'channelId':  ch.id,
          'name':       ch.name,
          'logo':       ch.logoUrl,
          'addedAt':    FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint('[CloudSync] pushFavorite fail: $e');
    }
  }

  static Future<void> pushWatchlist(ChannelModel ch, {required bool added}) async {
    final uid = _userUid();
    if (uid == null) return;
    final key = _key(ch.playlistId, ch.id);
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('watchlist')
          .doc(key);
      if (added) {
        await docRef.set({
          'playlistId': ch.playlistId,
          'channelId':  ch.id,
          'name':       ch.name,
          'logo':       ch.logoUrl,
          'addedAt':    FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint('[CloudSync] pushWatchlist fail: $e');
    }
  }

  static Future<void> pushHistory({
    required String playlistId,
    required String channelId,
    required int lastWatched,
    required int lastPosition,
    required int duration,
    required bool isWatched,
  }) async {
    final uid = _userUid();
    if (uid == null) return;
    final key = _key(playlistId, channelId);
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(key)
          .set({
        'playlistId':   playlistId,
        'channelId':    channelId,
        'lastWatched':  lastWatched,
        'lastPosition': lastPosition,
        'duration':     duration,
        'isWatched':    isWatched ? 1 : 0,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[CloudSync] pushHistory fail: $e');
    }
  }

  // ── Pull (cloud → local) ─────────────────────────────────────────────────
  //
  // Pull metodları raw Map listesi döner; çağıran taraf local DB'ye merge eder
  // (last-write-wins by lastWatched/addedAt timestamps).

  static Future<List<Map<String, dynamic>>> pullPlaylists() async {
    final uid = _userUid();
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('playlists')
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('[CloudSync] pullPlaylists fail: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> pullFavorites() async {
    return _pullCollection('favorites');
  }

  static Future<List<Map<String, dynamic>>> pullWatchlist() async {
    return _pullCollection('watchlist');
  }

  static Future<List<Map<String, dynamic>>> pullHistory() async {
    return _pullCollection('history');
  }

  static Future<List<Map<String, dynamic>>> _pullCollection(String name) async {
    final uid = _userUid();
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection(name)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('[CloudSync] pull $name fail: $e');
      return [];
    }
  }
}
