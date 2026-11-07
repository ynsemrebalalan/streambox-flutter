import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../models/playlist_model.dart';
import 'm3u_parser.dart';

/// M3U indirme hatası — UI kullanıcı mesajına çevirir (bkz. PlaylistSync).
class M3uLoadException implements Exception {
  /// 'http' | 'network' | 'timeout' | 'tls' | 'unknown'
  final String kind;
  final int? statusCode;
  final String message;
  const M3uLoadException(this.kind, this.message, {this.statusCode});

  @override
  String toString() => 'M3uLoadException($kind, $statusCode): $message';
}

/// Başarılı (veya 304) indirmenin sonucu.
class M3uLoadOutcome {
  final bool notModified;
  final int count;
  final String etag;
  final String lastModified;
  final String? epgUrl;
  /// Sunucu Content-Length bildirdi mi? Bildirmediyse erken kapanma normal
  /// dosya sonu gibi görünür — çağıran "yarım liste" kapısını uygular
  /// (Android M3uLoader v4.1.14 paritesi).
  final bool sawContentLength;

  const M3uLoadOutcome({
    this.notModified = false,
    this.count = 0,
    this.etag = '',
    this.lastModified = '',
    this.epgUrl,
    this.sawContentLength = false,
  });
}

/// İlerleme fazları — UI yerelleştirir.
enum M3uLoadPhase { downloading, retrying, parsing }

/// Akışlı M3U yükleyici (Android M3uLoader paritesi).
///
/// İndirme + gzip açma + satır parse **ayrı isolate**'ta yapılır; ana isolate'a
/// DB'ye yazılmaya hazır satır map'leri batch'ler halinde gelir. Her batch
/// [onBatch] bitince isolate'a "ack" gider (akış kontrolü): parse, DB yazımından
/// hızlı olsa bile bellekte en fazla bir batch birikir — 100K+ kanallık liste
/// RAM'de hiçbir zaman bütün halde tutulmaz.
///
///  - İlk batch [firstBatchSize] (UI hızlı dolsun), sonrakiler [batchSize].
///  - `If-None-Match` / `If-Modified-Since` → 304'te [M3uLoadOutcome.notModified].
///  - `.m3u.gz` (gzip magic) otomatik açılır; Content-Encoding gzip'i
///    HttpClient zaten açar.
///  - Ağ hatasında 3 deneme; her denemede [onRetry] çağrılır (çağıran o ana
///    kadar yazılanları idempotent upsert ile yeniden yazar).
class M3uStreamLoader {
  M3uStreamLoader._();

  static const int firstBatchSize = 200;
  /// Satır map'inde kategori listesinin anahtarı (channels kolonu değil).
  static const String categoriesKey = '__cats';

  static Future<M3uLoadOutcome> load({
    required PlaylistModel playlist,
    required Future<void> Function(List<Map<String, Object?>> rows) onBatch,
    void Function(M3uLoadPhase phase, int attempt)? onPhase,
    void Function()? onRetry,
    int batchSize = 2000,
    bool conditional = true,
    // Stalker M3U export hizli yolu: MAG basliklari, tek deneme, govde
    // `#EXTM3U` ile baslamiyorsa (JSON/HTML hata sayfasi) 0 kanal.
    Map<String, String> headers = const {},
    int maxAttempts = 3,
    bool requireExtM3u = false,
  }) async {
    final config = <String, Object?>{
      'headers':      headers,
      'maxAttempts':  maxAttempts,
      'requireExtM3u': requireExtM3u,
      'url':          playlist.url.trim(),
      'playlistId':   playlist.id,
      'allowed':      playlist.allowedTypes,
      'etag':         conditional ? playlist.etag : '',
      'lastModified': conditional ? playlist.lastModified : '',
      'batchSize':    batchSize,
    };
    final inbox = ReceivePort();
    final errors = ReceivePort();
    final iterator = StreamIterator<Object?>(
        StreamGroupLite.merge([inbox, errors]));
    Isolate? isolate;
    try {
      isolate = await Isolate.spawn(
        _worker,
        [inbox.sendPort, config],
        onError: errors.sendPort,
        onExit: errors.sendPort,
      );
      SendPort? ackPort;
      while (await iterator.moveNext()) {
        final msg = iterator.current;
        if (msg == null) {
          throw const M3uLoadException('unknown', 'isolate exited');
        }
        if (msg is SendPort) {
          ackPort = msg;
          continue;
        }
        if (msg is List && msg.length == 2 && msg.first is String?) {
          // onError: [error, stack]
          throw M3uLoadException('unknown', '${msg.first}');
        }
        final m = msg as Map;
        switch (m['t']) {
          case 'phase':
            onPhase?.call(
                M3uLoadPhase.values[m['phase'] as int], m['attempt'] as int);
          case 'retry':
            onRetry?.call();
          case 'batch':
            final rows = (m['rows'] as List).cast<Map<String, Object?>>();
            try {
              await onBatch(rows);
              ackPort?.send(true);
            } catch (_) {
              ackPort?.send(false);
              rethrow;
            }
          case 'nm':
            return const M3uLoadOutcome(notModified: true);
          case 'done':
            return M3uLoadOutcome(
              count:            m['count'] as int,
              etag:             m['etag'] as String? ?? '',
              lastModified:     m['lastModified'] as String? ?? '',
              epgUrl:           m['epgUrl'] as String?,
              sawContentLength: m['sawLength'] as bool? ?? false,
            );
          case 'error':
            throw M3uLoadException(
              m['kind'] as String,
              m['message'] as String? ?? '',
              statusCode: m['status'] as int?,
            );
        }
      }
      throw const M3uLoadException('unknown', 'isolate closed');
    } finally {
      isolate?.kill(priority: Isolate.immediate);
      inbox.close();
      errors.close();
    }
  }

  // ── Isolate tarafı ──────────────────────────────────────────────────────────

  static Future<void> _worker(List<Object?> args) async {
    final out = args[0] as SendPort;
    final cfg = args[1] as Map<String, Object?>;
    final acks = ReceivePort();
    out.send(acks.sendPort);
    final ackIt = StreamIterator<Object?>(acks);
    try {
      await _run(out, cfg, ackIt);
    } catch (e) {
      out.send({'t': 'error', 'kind': 'unknown', 'message': '$e'});
    } finally {
      acks.close();
    }
  }

  static Future<void> _run(
    SendPort out,
    Map<String, Object?> cfg,
    StreamIterator<Object?> ackIt,
  ) async {
    var url = cfg['url'] as String;
    final allowed = (cfg['allowed'] as String)
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    final batchSize = cfg['batchSize'] as int;
    final etag = cfg['etag'] as String;
    final lastMod = cfg['lastModified'] as String;
    var triedHttpFallback = false;
    final headers = (cfg['headers'] as Map?)?.cast<String, String>() ?? const {};
    final maxAttempts = cfg['maxAttempts'] as int? ?? 3;
    final requireExtM3u = cfg['requireExtM3u'] as bool? ?? false;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        out.send({'t': 'phase', 'phase': M3uLoadPhase.retrying.index,
          'attempt': attempt});
        out.send({'t': 'retry'});
        await Future<void>.delayed(Duration(milliseconds: 1500 * (attempt - 1)));
      } else {
        out.send({'t': 'phase', 'phase': M3uLoadPhase.downloading.index,
          'attempt': attempt});
      }
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        ..idleTimeout = const Duration(seconds: 30)
        ..badCertificateCallback = (cert, host, port) => true;
      try {
        final req = await client.getUrl(Uri.parse(url));
        req.headers.set(HttpHeaders.userAgentHeader, 'IPTV-AI-Player');
        headers.forEach(req.headers.set);
        if (etag.isNotEmpty) {
          req.headers.set(HttpHeaders.ifNoneMatchHeader, etag);
        } else if (lastMod.isNotEmpty) {
          req.headers.set(HttpHeaders.ifModifiedSinceHeader, lastMod);
        }
        final resp = await req.close().timeout(const Duration(seconds: 60));
        if (resp.statusCode == 304) {
          out.send({'t': 'nm'});
          return;
        }
        if (resp.statusCode != 200) {
          final code = resp.statusCode;
          final retryable = code == 408 || code == 429 || code >= 500;
          await resp.drain<void>().catchError((_) {});
          if (retryable && attempt < maxAttempts) continue;
          out.send({'t': 'error', 'kind': 'http', 'status': code,
            'message': 'HTTP $code'});
          return;
        }
        out.send({'t': 'phase', 'phase': M3uLoadPhase.parsing.index,
          'attempt': attempt});
        final parser = M3uLineParser(
            playlistId: cfg['playlistId'] as String, allowedTypes: allowed);
        var count = 0;
        var batch = <Map<String, Object?>>[];
        var limit = firstBatchSize;

        Future<bool> flush() async {
          if (batch.isEmpty) return true;
          out.send({'t': 'batch', 'rows': batch});
          count += batch.length;
          batch = <Map<String, Object?>>[];
          limit = batchSize;
          if (!await ackIt.moveNext()) return false;
          return ackIt.current == true;
        }

        final lines = _maybeGunzip(resp)
            .timeout(const Duration(seconds: 120))
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const LineSplitter());
        var sawFirstLine = !requireExtM3u;
        await for (final line in lines) {
          if (!sawFirstLine) {
            if (line.trim().isEmpty) continue;
            sawFirstLine = true;
            if (!line.trimLeft().startsWith('#EXTM3U')) break;
          }
          final ch = parser.addLine(line);
          if (ch == null) continue;
          batch.add({
            ...ch.toMap(),
            categoriesKey: ch.categoryIds,
          });
          if (batch.length >= limit && !await flush()) return;
        }
        if (!await flush()) return;
        out.send({
          't':            'done',
          'count':        count,
          'etag':         resp.headers.value(HttpHeaders.etagHeader) ?? '',
          'lastModified': resp.headers.value(HttpHeaders.lastModifiedHeader) ?? '',
          'epgUrl':       parser.epgUrl,
          'sawLength':    resp.contentLength >= 0,
        });
        return;
      } on HandshakeException catch (e) {
        if (!_fallbackToHttp(url, triedHttpFallback)) {
          if (attempt >= maxAttempts) return _sendErr(out, 'tls', e);
          continue;
        }
        triedHttpFallback = true;
        url = Uri.parse(url).replace(scheme: 'http').toString();
      } on TlsException catch (e) {
        if (!_fallbackToHttp(url, triedHttpFallback)) {
          if (attempt >= maxAttempts) return _sendErr(out, 'tls', e);
          continue;
        }
        triedHttpFallback = true;
        url = Uri.parse(url).replace(scheme: 'http').toString();
      } on TimeoutException catch (e) {
        if (attempt >= maxAttempts) return _sendErr(out, 'timeout', e);
      } on SocketException catch (e) {
        if (attempt >= maxAttempts) return _sendErr(out, 'network', e);
      } on HttpException catch (e) {
        if (attempt >= maxAttempts) return _sendErr(out, 'network', e);
      } on FormatException catch (e) {
        // Bozuk gzip / URL — tekrar denemek fayda etmez.
        return _sendErr(out, 'unknown', e);
      } on ArgumentError catch (e) {
        return _sendErr(out, 'unknown', e);
      } finally {
        client.close(force: true);
      }
    }
  }

  static bool _fallbackToHttp(String url, bool alreadyTried) =>
      !alreadyTried && url.toLowerCase().startsWith('https:');

  static void _sendErr(SendPort out, String kind, Object e) =>
      out.send({'t': 'error', 'kind': kind, 'message': '$e'});

  /// İlk chunk gzip magic (1f 8b) ise akışı açar; değilse aynen geçirir.
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

    final isGz = first.length >= 2 && first[0] == 0x1f && first[1] == 0x8b;
    if (isGz) {
      yield* rest().transform(gzip.decoder);
    } else {
      yield* rest();
    }
  }
}

/// Birden fazla stream'i tek stream'e birleştirir (async paketi bağımlılığı
/// olmadan). Tüm kaynaklar kapanınca kapanır.
class StreamGroupLite {
  static Stream<T> merge<T>(List<Stream<T>> sources) {
    late StreamController<T> ctrl;
    final subs = <StreamSubscription<T>>[];
    var open = sources.length;
    ctrl = StreamController<T>(
      onListen: () {
        for (final s in sources) {
          subs.add(s.listen(ctrl.add, onError: ctrl.addError, onDone: () {
            if (--open == 0) ctrl.close();
          }));
        }
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return ctrl.stream;
  }
}
