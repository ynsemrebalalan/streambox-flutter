import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// Isolate tarafında satır batch'lerini ana isolate'a gönderen kanal.
/// [emit] ana taraf batch'i yazıp "ack" verene kadar bekler (akış kontrolü:
/// bellekte en fazla bir batch birikir).
class BatchSink {
  final SendPort _out;
  final StreamIterator<Object?> _acks;
  BatchSink._(this._out, this._acks);

  /// false → ana taraf iptal etti / yazamadı; worker durmalı.
  Future<bool> emit(List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) return true;
    _out.send({'t': 'batch', 'rows': rows});
    if (!await _acks.moveNext()) return false;
    return _acks.current == true;
  }

  /// Serbest bilgi mesajı (faz/ilerleme). `t` anahtarı 'msg' olur.
  void send(Map<String, Object?> msg) => _out.send({'t': 'msg', ...msg});
}

/// Worker isolate'tan gelen hata — sınıflandırılmış.
class IsolateTaskException implements Exception {
  /// 'http' | 'network' | 'timeout' | 'tls' | 'format' | 'unknown'
  final String kind;
  final int? statusCode;
  final String message;
  const IsolateTaskException(this.kind, this.message, {this.statusCode});

  @override
  String toString() => 'IsolateTaskException($kind, $statusCode): $message';
}

/// Worker'ın HTTP hatası için fırlatacağı tip (isolate içinde).
class IsolateHttpStatus implements Exception {
  final int statusCode;
  const IsolateHttpStatus(this.statusCode);
  @override
  String toString() => 'HTTP $statusCode';
}

typedef BatchWorker = Future<Map<String, Object?>> Function(
    BatchSink sink, Map<String, Object?> config);

/// [worker]'ı yeni isolate'ta çalıştırır; gelen her batch [onBatch] ile
/// yazılır. Dönüş: worker'ın sonuç map'i. Hata → [IsolateTaskException].
Future<Map<String, Object?>> runBatchIsolate(
  BatchWorker worker,
  Map<String, Object?> config, {
  required Future<void> Function(List<Map<String, Object?>> rows) onBatch,
  void Function(Map<String, Object?> msg)? onMessage,
}) async {
  final inbox = ReceivePort();
  Isolate? iso;
  try {
    iso = await Isolate.spawn(
      _entry,
      [inbox.sendPort, worker, config],
      onError: inbox.sendPort,
      onExit: inbox.sendPort,
    );
    SendPort? ack;
    await for (final msg in inbox) {
      if (msg == null) {
        throw const IsolateTaskException('unknown', 'isolate exited');
      }
      if (msg is SendPort) {
        ack = msg;
        continue;
      }
      if (msg is List) {
        throw IsolateTaskException('unknown', '${msg.isEmpty ? '' : msg.first}');
      }
      final m = (msg as Map).cast<String, Object?>();
      switch (m['t']) {
        case 'batch':
          try {
            await onBatch((m['rows'] as List).cast<Map<String, Object?>>());
            ack?.send(true);
          } catch (_) {
            ack?.send(false);
            rethrow;
          }
        case 'msg':
          onMessage?.call(m);
        case 'done':
          return (m['result'] as Map).cast<String, Object?>();
        case 'error':
          throw IsolateTaskException(
            m['kind'] as String? ?? 'unknown',
            m['message'] as String? ?? '',
            statusCode: m['status'] as int?,
          );
      }
    }
    throw const IsolateTaskException('unknown', 'isolate closed');
  } finally {
    iso?.kill(priority: Isolate.immediate);
    inbox.close();
  }
}

Future<void> _entry(List<Object?> args) async {
  final out = args[0] as SendPort;
  final worker = args[1] as BatchWorker;
  final cfg = (args[2] as Map).cast<String, Object?>();
  final acks = ReceivePort();
  out.send(acks.sendPort);
  final sink = BatchSink._(out, StreamIterator<Object?>(acks));
  try {
    final result = await worker(sink, cfg);
    out.send({'t': 'done', 'result': result});
  } catch (e) {
    out.send({
      't': 'error',
      'kind': classifyIoError(e),
      'status': e is IsolateHttpStatus ? e.statusCode : null,
      'message': '$e',
    });
  } finally {
    acks.close();
  }
}

/// Hata türü sınıflandırması (isolate içinde/dışında ortak).
String classifyIoError(Object e) {
  if (e is IsolateHttpStatus) return 'http';
  if (e is TimeoutException) return 'timeout';
  if (e is HandshakeException || e is TlsException) return 'tls';
  if (e is SocketException || e is HttpException) return 'network';
  if (e is FormatException) return 'format';
  return 'unknown';
}

/// Isolate içinde kullanılabilir GET (AppHttp main isolate'a bağlı).
/// 408/429/5xx ve ağ hatalarında [retries] kez tekrar; HTTPS TLS hatasında
/// bir kez HTTP'ye düşer (AppHttp davranışı).
Future<List<int>> isolateGetBytes(
  String url, {
  int retries = 2,
  Duration timeout = const Duration(seconds: 60),
}) async {
  var target = url;
  var triedHttp = false;
  Object? last;
  for (var attempt = 0; attempt <= retries; attempt++) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (cert, host, port) => true;
    try {
      final req = await client.getUrl(Uri.parse(target));
      req.headers.set(HttpHeaders.userAgentHeader, 'IPTV-AI-Player');
      final resp = await req.close().timeout(timeout);
      if (resp.statusCode != 200) {
        await resp.drain<void>().catchError((_) {});
        final code = resp.statusCode;
        final retryable = code == 408 || code == 429 || code >= 500;
        if (!retryable || attempt == retries) throw IsolateHttpStatus(code);
        last = IsolateHttpStatus(code);
      } else {
        final builder = BytesBuilder(copy: false);
        await for (final chunk in resp.timeout(timeout)) {
          builder.add(chunk);
        }
        return builder.takeBytes();
      }
    } on IsolateHttpStatus {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (e) {
      last = e;
      final tls = e is HandshakeException || e is TlsException;
      if (tls && !triedHttp && target.toLowerCase().startsWith('https:')) {
        triedHttp = true;
        target = Uri.parse(target).replace(scheme: 'http').toString();
        attempt--; // fallback denemesi hakkı yemesin
        continue;
      }
      if (attempt == retries) rethrow;
    } finally {
      client.close(force: true);
    }
    await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
  }
  throw last ?? const IsolateHttpStatus(0);
}

/// JSON GET (isolate içinde). Bozuk gövde → FormatException.
Future<Object?> isolateGetJson(String url,
    {int retries = 2, Duration timeout = const Duration(seconds: 60)}) async {
  final bytes = await isolateGetBytes(url, retries: retries, timeout: timeout);
  return jsonDecode(utf8.decode(bytes, allowMalformed: true));
}
