import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'isolate_batch_pump.dart';
import 'xmltv_stream_parser.dart';

/// XMLTV indirme + akışlı ayrıştırma — ayrı isolate'ta (Android EpgRepository
/// streaming paritesi). 50-200 MB'lık `.xml.gz` dosyası hiç belleğe alınmaz;
/// programlar batch'ler halinde ana isolate'a gelir.
class EpgParser {
  EpgParser._();

  /// Dönüş: XMLTV'deki kanallar (epg_channels satırları).
  static Future<List<Map<String, Object?>>> load(
    String url,
    String playlistId, {
    required Future<void> Function(List<Map<String, Object?>> batch) onProgrammes,
    Set<String>? allowedTvgIds,
    int minStopMs = 0,
  }) async {
    final res = await runBatchIsolate(
      _worker,
      {
        'url': url.trim(),
        'playlistId': playlistId,
        'allowed': allowedTvgIds?.toList(),
        'minStop': minStopMs,
      },
      onBatch: onProgrammes,
    );
    return ((res['channels'] as List?) ?? const [])
        .cast<Map>()
        .map((m) => m.cast<String, Object?>())
        .toList();
  }

  static Future<Map<String, Object?>> _worker(
      BatchSink sink, Map<String, Object?> cfg) async {
    final allowed = (cfg['allowed'] as List?)?.cast<String>().toSet();
    var url = cfg['url'] as String;
    for (var attempt = 0; attempt < 2; attempt++) {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20)
        ..badCertificateCallback = (cert, host, port) => true;
      try {
        final req = await client.getUrl(Uri.parse(url));
        req.headers.set(HttpHeaders.userAgentHeader, 'IPTV-AI-Player');
        final resp = await req.close().timeout(const Duration(seconds: 90));
        if (resp.statusCode != 200) {
          await resp.drain<void>().catchError((_) {});
          throw IsolateHttpStatus(resp.statusCode);
        }
        final text = _maybeGunzip(resp.timeout(const Duration(seconds: 120)))
            .transform(const Utf8Decoder(allowMalformed: true));
        final r = await XmltvStreamParser.parse(
          text,
          playlistId: cfg['playlistId'] as String,
          allowedTvgIds: allowed,
          minStopMs: cfg['minStop'] as int,
          onProgrammes: (b) async {
            if (!await sink.emit(b)) throw StateError('cancelled');
          },
        );
        return {'channels': r.channels};
      } on HandshakeException {
        if (attempt == 0 && url.toLowerCase().startsWith('https:')) {
          url = Uri.parse(url).replace(scheme: 'http').toString();
          continue;
        }
        rethrow;
      } finally {
        client.close(force: true);
      }
    }
    throw const IsolateHttpStatus(0);
  }

  static Stream<List<int>> _maybeGunzip(Stream<List<int>> src) async* {
    final it = StreamIterator<List<int>>(src);
    if (!await it.moveNext()) return;
    final first = it.current;
    Stream<List<int>> rest() async* {
      yield first;
      while (await it.moveNext()) {
        yield it.current;
      }
    }

    if (first.length >= 2 && first[0] == 0x1f && first[1] == 0x8b) {
      yield* rest().transform(gzip.decoder);
    } else {
      yield* rest();
    }
  }
}
