import 'package:dio/dio.dart';

/// AI altyazı hata kodları — dilden bağımsız. Kullanıcı metni
/// `aiErrorMessage` ile (l10n) üretilir; yeniden deneme kararı [AiError.transient].
enum AiErrorCode {
  proRequired,
  quota,
  busy,
  unauthorized,
  invalidKey,
  server,
  rejected,
  network,
  timeout,
  emptyResponse,
  noSpeech,
  extract,
  notConfigured,
  generic,
}

class AiError implements Exception {
  final AiErrorCode code;
  final bool transient;
  final String? detail;
  const AiError(this.code, {this.transient = false, this.detail});

  /// Analytics `error_type` değeri (Android kodlarıyla uyumlu snake_case).
  String get analyticsCode => switch (code) {
        AiErrorCode.proRequired => 'pro_required',
        AiErrorCode.quota => 'quota',
        AiErrorCode.busy => 'http_429',
        AiErrorCode.unauthorized => 'http_401_proxy',
        AiErrorCode.invalidKey => 'http_401',
        AiErrorCode.server => 'http_5xx',
        AiErrorCode.rejected => 'http_other',
        AiErrorCode.network => 'unreachable',
        AiErrorCode.timeout => 'timeout',
        AiErrorCode.emptyResponse => 'empty_body',
        AiErrorCode.noSpeech => 'no_speech',
        AiErrorCode.extract => 'extract_fail',
        AiErrorCode.notConfigured => 'proxy_missing',
        AiErrorCode.generic => 'exception',
      };

  @override
  String toString() => 'AiError($code, transient=$transient, $detail)';
}

/// HTTP durum + gövde → [AiError]. Android WhisperRepository.callApi ile aynı
/// eşleme. [viaProxy] false ise (kullanıcının kendi OpenAI anahtarı) 401 =
/// geçersiz anahtar.
AiError mapAiHttpError({
  required int status,
  String? body,
  required bool viaProxy,
}) {
  final b = body ?? '';
  final detail = 'HTTP $status';
  if (status == 401) {
    return viaProxy
        ? AiError(AiErrorCode.unauthorized, transient: true, detail: detail)
        : AiError(AiErrorCode.invalidKey, detail: detail);
  }
  if (status == 403) {
    return b.contains('PRO_REQUIRED')
        ? AiError(AiErrorCode.proRequired, detail: detail)
        : AiError(AiErrorCode.rejected, transient: true, detail: detail);
  }
  if (status == 429) {
    return b.toLowerCase().contains('quota')
        ? AiError(AiErrorCode.quota, detail: detail)
        : AiError(AiErrorCode.busy, transient: true, detail: detail);
  }
  if (status >= 500) {
    return AiError(AiErrorCode.server, transient: true, detail: detail);
  }
  return AiError(AiErrorCode.rejected, transient: true, detail: detail);
}

AiError mapDioException(DioException e, {required bool viaProxy}) {
  final resp = e.response;
  if (resp != null && resp.statusCode != null) {
    final data = resp.data;
    return mapAiHttpError(
      status: resp.statusCode!,
      body: data is String ? data : data?.toString(),
      viaProxy: viaProxy,
    );
  }
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      AiError(AiErrorCode.timeout, transient: true, detail: e.type.name),
    DioExceptionType.cancel => const AiError(AiErrorCode.generic),
    _ => AiError(AiErrorCode.network, transient: true, detail: e.type.name),
  };
}

/// Geçici hatada [delay] (Android: 800 ms) sonra tek bir kez daha dener.
Future<T> retryOnceIfTransient<T>(
  Future<T> Function() action, {
  Duration delay = const Duration(milliseconds: 800),
}) async {
  try {
    return await action();
  } on AiError catch (e) {
    if (!e.transient) rethrow;
    await Future<void>.delayed(delay);
    return action();
  }
}
