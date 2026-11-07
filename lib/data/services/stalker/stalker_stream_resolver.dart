import 'package:flutter/foundation.dart';

import '../../models/playlist_model.dart';
import '../../repositories/playlist_repository.dart';
import 'stalker_client.dart';
import 'stalker_protocol.dart';

/// Oynatma aninda Stalker komutunu (`ffrt http://localhost/ch/..`) gercek
/// akis URL'sine cevirir — Android StalkerLoader.resolveUrl paritesi:
/// onbellekteki token ile `create_link`; olmazsa (401 / suresi dolmus /
/// bos cmd) yeniden handshake + bir kez daha.
///
/// Token yalniz bellekte tutulur (DB'ye / buluta yazilmaz). Android'den
/// bulutla gelen kayitlarda `password` alanindaki token ilk deneme olarak
/// kullanilir.
class StalkerStreamResolver {
  StalkerStreamResolver._();

  static final _sessions = <String, StalkerSession>{};

  static String _key(PlaylistModel p) =>
      '${p.id}|${p.url.trim()}|${p.username.trim().toUpperCase()}';

  static void remember(PlaylistModel p, StalkerSession s) =>
      _sessions[_key(p)] = s;

  @visibleForTesting
  static void clearCache() => _sessions.clear();

  /// Oynatilacak URL; Stalker disi / cozum gerektirmeyen URL aynen doner.
  /// null → portal link vermedi (oynatici hata gosterir).
  static Future<String?> resolve(
    PlaylistModel p,
    String url, {
    String lang = 'en',
  }) async {
    if (p.type != 'stalker' || !stalkerNeedsResolve(url)) return url;
    final mac = StalkerMac.normalize(p.username) ?? p.username.trim();
    final client = StalkerClient(portalUrl: p.url, mac: mac, lang: lang);
    if (client.endpoints.isEmpty) return null;

    final key = _key(p);
    var session = _sessions[key];
    if (session == null && p.password.trim().isNotEmpty) {
      session = StalkerSession(client.endpoints.first, p.password.trim());
    }
    if (session != null) {
      final link = await client.createLink(session, url);
      if (link != null) {
        _sessions[key] = session;
        return link;
      }
    }

    // Token yok / suresi dolmus → yenile ve tekrar dene.
    try {
      session = await client.connect(preferred: session?.endpoint);
    } catch (_) {
      _sessions.remove(key);
      return null;
    }
    _sessions[key] = session;
    return client.createLink(session, url);
  }

  /// Oynatici girisi: kanalin playlist'i Stalker degilse / bulunamazsa URL
  /// aynen doner (ek maliyet yok).
  static Future<String?> resolveForPlaylist(
    PlaylistRepository playlists,
    String? playlistId,
    String url, {
    String lang = 'en',
  }) async {
    if (playlistId == null || !stalkerNeedsResolve(url)) return url;
    final p = await playlists.getById(playlistId);
    if (p == null) return url;
    return resolve(p, url, lang: lang);
  }
}
