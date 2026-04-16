import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/secure_storage.dart';
import '../models/playlist_model.dart';

/// Firestore playlist backup/restore + proxy secret fetch.
/// Android native ile ayni collection yapisi.
class FirebaseSyncService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Anonim login (Firestore rules auth gerektirir).
  static Future<bool> _ensureAuth() async {
    try {
      if (_auth.currentUser != null) return true;
      await _auth.signInAnonymously();
      return _auth.currentUser != null;
    } catch (e) {
      debugPrint('[Sync] auth failed: $e');
      return false;
    }
  }

  /// Cihaz kimlik ID'si (UUID-based).
  static Future<String> _deviceId() async {
    final uuid = await SecureStorage.getOrCreateDeviceUuid();
    return uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  // ── Proxy Secret ───────────────────────────────────────────────────────────

  /// Global config'den proxy secret cek ve SecureStorage'a kaydet.
  static Future<void> fetchAndCacheProxySecret() async {
    try {
      if (!await _ensureAuth()) return;
      final doc =
          await _firestore.collection('streambox_config').doc('app_config').get();
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;

      final secret = data['proxySecret'] as String? ?? '';
      if (secret.isNotEmpty) {
        await SecureStorage.setProxySecret(secret);
      }
      final apiKey = data['openAiApiKey'] as String? ?? '';
      if (apiKey.isNotEmpty) {
        await SecureStorage.setOpenAiKey(apiKey);
      }
    } catch (e) {
      debugPrint('[Sync] fetchProxySecret failed: $e');
    }
  }

  // ── Upload (Backup) ────────────────────────────────────────────────────────

  /// Local playlist'leri Firestore'a yedekle.
  static Future<void> uploadPlaylists(List<PlaylistModel> playlists) async {
    if (!await _ensureAuth()) return;
    final deviceId = await _deviceId();
    final deviceRef = _firestore.collection('streambox_devices').doc(deviceId);

    try {
      // Cihaz bilgisi
      await deviceRef.set({
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Playlist'leri yükle
      final playlistCol = deviceRef.collection('playlists');
      for (final p in playlists) {
        await playlistCol.doc(p.id).set({
          'id': p.id,
          'name': p.name,
          'type': p.type,
          'url': p.url,
          'username': p.username,
          'password': p.password, // TODO: encrypt with device UUID
          'allowedTypes': p.allowedTypes,
          'syncedAt': FieldValue.serverTimestamp(),
          'ttlDays': 7,
          'expiresAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 7))),
        });
      }
    } catch (e) {
      debugPrint('[Sync] upload failed: $e');
      rethrow;
    }
  }

  // ── Download (Restore) ─────────────────────────────────────────────────────

  /// Firestore'dan playlist'leri indir.
  static Future<List<PlaylistModel>> downloadPlaylists() async {
    if (!await _ensureAuth()) return [];
    final deviceId = await _deviceId();

    try {
      final snap = await _firestore
          .collection('streambox_devices')
          .doc(deviceId)
          .collection('playlists')
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        // allowedTypes: String veya Array olabilir (eski surum uyumu)
        String allowedTypes = 'live,movie,series';
        final raw = d['allowedTypes'];
        if (raw is String) {
          allowedTypes = raw;
        } else if (raw is List) {
          allowedTypes = raw.cast<String>().join(',');
        }

        return PlaylistModel(
          id: d['id'] as String? ?? doc.id,
          name: d['name'] as String? ?? '',
          type: d['type'] as String? ?? 'm3u',
          url: d['url'] as String? ?? '',
          username: d['username'] as String? ?? '',
          password: d['password'] as String? ?? '',
          allowedTypes: allowedTypes,
        );
      }).where((p) => p.url.isNotEmpty).toList();
    } catch (e) {
      debugPrint('[Sync] download failed: $e');
      return [];
    }
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  /// TTL suresi dolmus playlist'leri Firestore'dan sil.
  static Future<void> cleanExpired() async {
    if (!await _ensureAuth()) return;
    final deviceId = await _deviceId();

    try {
      final snap = await _firestore
          .collection('streambox_devices')
          .doc(deviceId)
          .collection('playlists')
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('[Sync] cleanup failed: $e');
    }
  }
}
