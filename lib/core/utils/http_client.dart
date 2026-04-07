import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'device_tier.dart';

/// Global HTTP client: connection pooling + automatic retry with backoff.
///
/// Tum API cagrilarinin bu client uzerinden gitmesi gerekiyor. Her request
/// icin yeni socket acmaktan kacinir (keep-alive) ve sunucu 5xx/timeout
/// donerse exponential backoff ile tekrar dener.
///
/// IPTV saglayicilarinin cogu self-signed sertifika veya duz HTTP kullanir.
/// [badCertificateCallback] ile gecersiz sertifikalar kabul edilir,
/// TLS handshake basarisiz olursa otomatik HTTP fallback denenir.
class AppHttp {
  AppHttp._();

  static final http.Client _client = _createClient();

  static http.Client _createClient() {
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12)
      ..idleTimeout = const Duration(seconds: 30)
      // Adaptive: low=3, mid=6, high=8 eszamanli baglanti.
      ..maxConnectionsPerHost = DeviceProfile.maxConnectionsPerHost
      // IPTV panelleri genelde self-signed veya gecersiz sertifika kullanir.
      // Bunlari kabul etmezsek "unable to parse TLS packet header" aliriz.
      ..badCertificateCallback = (cert, host, port) => true;
    return _IOHttpClient(ioClient);
  }

  /// GET with retry. [retries] = tekrar sayisi (toplam deneme = retries+1).
  /// [timeout] = her bir denemenin timeout'u.
  /// [retryOn] = hangi HTTP kodlarinda tekrar denenecek (default: 408/429/5xx).
  static Future<http.Response> get(
    Uri url, {
    int retries = 3,
    Duration timeout = const Duration(seconds: 15),
    Map<String, String>? headers,
    bool Function(int statusCode)? retryOn,
  }) async {
    final shouldRetry = retryOn ??
        (code) => code == 408 || code == 429 || (code >= 500 && code < 600);

    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final resp =
            await _client.get(url, headers: headers).timeout(timeout);
        if (resp.statusCode == 200) return resp;
        if (!shouldRetry(resp.statusCode) || attempt == retries) return resp;
        lastError = 'HTTP ${resp.statusCode}';
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt == retries) rethrow;
      } on SocketException catch (e) {
        lastError = e;
        if (attempt == retries) rethrow;
      } on HttpException catch (e) {
        lastError = e;
        if (attempt == retries) rethrow;
      } on HandshakeException catch (e) {
        // TLS handshake hatasi: "unable to parse TLS packet header" vb.
        // Genelde HTTP sunucuya HTTPS ile gidildiginde olur.
        // HTTPS → HTTP fallback dene.
        lastError = e;
        if (url.scheme == 'https') {
          final httpUrl = url.replace(scheme: 'http');
          if (kDebugMode) {
            debugPrint('[AppHttp] TLS handshake failed, falling back to HTTP: $httpUrl');
          }
          try {
            final resp = await _client.get(httpUrl, headers: headers).timeout(timeout);
            if (resp.statusCode == 200) return resp;
          } catch (_) {
            // HTTP fallback da basarisiz, devam et
          }
        }
        if (attempt == retries) rethrow;
      } on TlsException catch (e) {
        // Diger TLS hatalari (sertifika, protokol uyumsuzlugu).
        lastError = e;
        if (url.scheme == 'https') {
          final httpUrl = url.replace(scheme: 'http');
          if (kDebugMode) {
            debugPrint('[AppHttp] TLS error, falling back to HTTP: $httpUrl');
          }
          try {
            final resp = await _client.get(httpUrl, headers: headers).timeout(timeout);
            if (resp.statusCode == 200) return resp;
          } catch (_) {}
        }
        if (attempt == retries) rethrow;
      }

      // Exponential backoff: 400ms, 800ms, 1600ms, 3200ms...
      final delay = Duration(milliseconds: 400 * (1 << attempt));
      if (kDebugMode) {
        debugPrint('[AppHttp] retry ${attempt + 1}/$retries after $delay '
            '(reason: $lastError) url=$url');
      }
      await Future.delayed(delay);
    }

    throw Exception('AppHttp.get failed after $retries retries: $lastError');
  }

  /// GET that returns bytes (for XML/gzip EPG files).
  static Future<List<int>> getBytes(
    Uri url, {
    int retries = 2,
    Duration timeout = const Duration(seconds: 60),
    Map<String, String>? headers,
  }) async {
    final resp = await get(url,
        retries: retries, timeout: timeout, headers: headers);
    if (resp.statusCode != 200) {
      throw HttpStatusException(resp.statusCode, url.toString());
    }
    return resp.bodyBytes;
  }
}

/// Thin wrapper over dart:io HttpClient so we get pooling without pulling
/// in extra packages.
class _IOHttpClient extends http.BaseClient {
  final HttpClient _inner;
  _IOHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final ioReq = await _inner.openUrl(request.method, request.url);
    request.headers.forEach(ioReq.headers.set);
    ioReq.followRedirects = request.followRedirects;
    ioReq.maxRedirects = request.maxRedirects;
    ioReq.contentLength = request.contentLength ?? -1;
    ioReq.persistentConnection = request.persistentConnection;
    if (request is http.Request) {
      ioReq.add(request.bodyBytes);
    }
    final ioResp = await ioReq.close();
    final headers = <String, String>{};
    ioResp.headers.forEach((name, values) => headers[name] = values.join(','));
    return http.StreamedResponse(
      ioResp.handleError((e) => throw HttpException(e.toString())),
      ioResp.statusCode,
      contentLength: ioResp.contentLength < 0 ? null : ioResp.contentLength,
      request: request,
      headers: headers,
      isRedirect: ioResp.isRedirect,
      persistentConnection: ioResp.persistentConnection,
      reasonPhrase: ioResp.reasonPhrase,
    );
  }

  @override
  void close() {
    _inner.close(force: false);
    super.close();
  }
}

/// Provider/IPTV servisinin donusturdugu HTTP hatalari icin typed exception.
class HttpStatusException implements Exception {
  final int statusCode;
  final String url;
  HttpStatusException(this.statusCode, this.url);

  bool get isServerError => statusCode >= 500 && statusCode < 600;
  bool get isRateLimited => statusCode == 429;
  bool get isAuthError => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;

  /// Kullaniciya gosterilecek anlamli Turkce mesaj.
  String get userMessage {
    if (isAuthError) {
      return 'Kullanici adi veya sifre hatali. Playlist ayarlarini kontrol edin.';
    }
    if (isRateLimited) {
      return 'Saglayici istek limitini astiginizi bildiriyor. Birazdan tekrar deneyin.';
    }
    if (statusCode == 503) {
      return 'Saglayici su an yogun (503). Birkac dakika sonra tekrar deneyin.';
    }
    if (statusCode == 504 || statusCode == 408) {
      return 'Saglayici cevap veremedi (timeout). Baglantinizi kontrol edin.';
    }
    if (isServerError) {
      return 'Saglayicida gecici bir sorun var (HTTP $statusCode).';
    }
    if (isNotFound) {
      return 'Playlist adresi bulunamadi. URL dogru mu?';
    }
    return 'Baglanti hatasi (HTTP $statusCode).';
  }

  @override
  String toString() => 'HttpStatusException($statusCode) $url';
}
