import 'package:flutter/foundation.dart';

import '../../models/playlist_model.dart';
import '../m3u_stream_loader.dart';
import 'stalker_client.dart';
import 'stalker_protocol.dart';
import 'stalker_stream_resolver.dart';

/// MAC bicimi gecersiz (ag istegi yapilmadan).
class StalkerMacException implements Exception {
  const StalkerMacException();
  @override
  String toString() => 'StalkerMacException';
}

/// Yukleme fazlari — UI yerellestirir.
enum StalkerPhase { tryingExport, parsingExport, connecting, fetching }

class StalkerLoadOutcome {
  final int count;

  /// true → kanallar M3U export'tan (dogrudan URL); false → tam protokol
  /// (streamUrl = oynatmada `create_link` ile cozulecek komut).
  final bool viaExport;
  final String? epgUrl;
  const StalkerLoadOutcome({
    required this.count,
    required this.viaExport,
    this.epgUrl,
  });
}

/// Stalker portal yukleyicisi — Android StalkerLoader hibrit akisi:
///  1. M3U export uclari (hizli yol, dogrudan URL'ler),
///  2. tam Stalker protokolu: handshake → get_profile → get_genres →
///     get_all_channels (sayfali; bossa get_ordered_list).
///
/// PlaylistModel alan kullanimi: `url` = portal adresi, `username` = MAC.
/// Token kalici yazilmaz (bulut sync'e gitmesin); bellekte
/// [StalkerStreamResolver] onbellegine verilir.
class StalkerLoader {
  StalkerLoader._();

  static Future<StalkerLoadOutcome> load(
    PlaylistModel p, {
    required Future<void> Function(List<Map<String, Object?>> rows) onBatch,
    void Function(StalkerPhase phase)? onPhase,

    /// Export basarisiz/yetersiz → protokol baslamadan once (cagiran yeni
    /// sync nesli acar; export'un kismi satirlari ayri nesilde kalir).
    void Function()? onProtocolStart,
    int previousCount = 0,
    String lang = 'en',
  }) async {
    final mac = StalkerMac.normalize(p.username);
    if (mac == null) throw const StalkerMacException();
    final client = StalkerClient(portalUrl: p.url, mac: mac, lang: lang);
    if (client.endpoints.isEmpty) {
      throw const StalkerConnectException(network: false);
    }

    // ── 1. M3U export (hizli yol) ─────────────────────────────────────────
    onPhase?.call(StalkerPhase.tryingExport);
    final primary = client.endpoints.first;
    for (final url in StalkerUrls.exportCandidates(primary, mac)) {
      var written = 0;
      try {
        final out = await M3uStreamLoader.load(
          playlist: p.copyWith(url: url),
          conditional: false,
          maxAttempts: 1,
          requireExtM3u: true,
          headers: client.headers(primary),
          onPhase: (phase, _) {
            if (phase == M3uLoadPhase.parsing) {
              onPhase?.call(StalkerPhase.parsingExport);
            }
          },
          onBatch: (rows) async {
            await onBatch(rows);
            written += rows.length;
          },
        );
        if (out.count <= 0) continue;
        // Sessiz kisa indirme kapisi (M3U yolu ile ayni): Content-Length
        // yokken onceki listenin yarisindan azsa protokole dus.
        final suspicious =
            !out.sawContentLength &&
            previousCount > 0 &&
            out.count < previousCount ~/ 2;
        if (!suspicious) {
          return StalkerLoadOutcome(
            count: out.count,
            viaExport: true,
            epgUrl: out.epgUrl,
          );
        }
        break;
      } catch (e) {
        if (kDebugMode) debugPrint('[Stalker] export $url failed: $e');
        // Yarida kesildi → aday degistirmek yerine protokole gec.
        if (written > 0) break;
      }
    }

    // ── 2. Tam Stalker protokolu ──────────────────────────────────────────
    onProtocolStart?.call();
    onPhase?.call(StalkerPhase.connecting);
    final session = await client.connect();
    StalkerStreamResolver.remember(p, session);
    onPhase?.call(StalkerPhase.fetching);
    final count = await client.loadLiveChannels(
      session,
      playlistId: p.id,
      onBatch: onBatch,
    );
    return StalkerLoadOutcome(count: count, viaExport: false);
  }
}
