import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/build_config.dart';
import '../../core/utils/secure_storage.dart';
import '../../features/player/logic/ai_entitlement.dart';

/// groq-proxy.php ortak yapılandırma + kimlik başlıkları.
///
/// Yeni istemciler `X-Firebase-Token` (Firebase ID token) + `X-Device-Id`
/// gönderir; sunucu AI hakkını Pro (RevenueCat, App User ID = Firebase UID)
/// veya sunucu saatli 7 günlük deneme ile verir. `X-Proxy-Secret` yalnızca
/// yapılandırılmışsa eklenir (geçiş dönemi; token varken gerekmez).
class AiProxyConfig {
  final String url;
  final String secret;
  const AiProxyConfig(this.url, this.secret);
  bool get isConfigured => url.isNotEmpty;

  static Future<AiProxyConfig> resolve() async {
    final overrideUrl = await SecureStorage.getProxyUrl();
    final overrideSecret = await SecureStorage.getProxySecret();
    return AiProxyConfig(
      overrideUrl.isNotEmpty ? overrideUrl : BuildConfig.groqProxyUrl,
      overrideSecret.isNotEmpty ? overrideSecret : BuildConfig.groqProxySecret,
    );
  }

  Future<Map<String, String>> headers() async {
    final h = <String, String>{if (secret.isNotEmpty) 'X-Proxy-Secret': secret};
    try {
      final token = await FirebaseAuth.instance.currentUser
          ?.getIdToken()
          .timeout(const Duration(seconds: 5));
      if (token != null && token.isNotEmpty) h['X-Firebase-Token'] = token;
    } catch (e) {
      debugPrint('[AiProxy] id token alinamadi: $e');
    }
    try {
      final uuid = await SecureStorage.getOrCreateDeviceUuid();
      h['X-Device-Id'] = uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    } catch (_) {}
    return h;
  }

  String endpoint(String action) {
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}action=$action';
  }
}

/// `POST ?action=entitlement` — [start] true ise deneme yoksa başlatır.
/// Ağ/kimlik hatası → null (çağıran fail-open uygular; sunucu her AI
/// isteğinde hakkı yeniden doğrular).
Future<AiEntitlementStatus?> fetchAiEntitlement({bool start = true, Dio? dio}) async {
  try {
    final cfg = await AiProxyConfig.resolve();
    if (!cfg.isConfigured) return null;
    final client = dio ??
        Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ));
    final resp = await client.post<String>(
      cfg.endpoint('entitlement'),
      data: FormData.fromMap({if (start) 'start': '1'}),
      options: Options(
        headers: await cfg.headers(),
        responseType: ResponseType.plain,
        validateStatus: (s) => s != null && s < 500,
      ),
    );
    if (resp.statusCode != 200) {
      debugPrint('[AiProxy] entitlement HTTP ${resp.statusCode}');
      return null;
    }
    return AiEntitlementStatus.tryParse(resp.data);
  } catch (e) {
    debugPrint('[AiProxy] entitlement failed: $e');
    return null;
  }
}
