import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// iOS Keychain / Android EncryptedSharedPreferences ile
/// hassas verileri güvenli saklama.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── OpenAI API Key ─────────────────────────────────────────────────────────
  static const _keyOpenAi = 'openai_api_key';

  static Future<void> setOpenAiKey(String key) =>
      _storage.write(key: _keyOpenAi, value: key);

  static Future<String> getOpenAiKey() async =>
      await _storage.read(key: _keyOpenAi) ?? '';

  // ── Groq Proxy Secret ──────────────────────────────────────────────────────
  static const _keyProxySecret = 'groq_proxy_secret';

  static Future<void> setProxySecret(String secret) =>
      _storage.write(key: _keyProxySecret, value: secret);

  static Future<String> getProxySecret() async =>
      await _storage.read(key: _keyProxySecret) ?? '';

  // ── Groq Proxy URL ─────────────────────────────────────────────────────────
  static const _keyProxyUrl = 'groq_proxy_url';

  static Future<void> setProxyUrl(String url) =>
      _storage.write(key: _keyProxyUrl, value: url);

  static Future<String> getProxyUrl() async =>
      await _storage.read(key: _keyProxyUrl) ?? '';

  // ── Device UUID (encryption key derivation) ────────────────────────────────
  static const _keyDeviceUuid = 'device_uuid';

  static Future<String> getOrCreateDeviceUuid() async {
    final existing = await _storage.read(key: _keyDeviceUuid);
    if (existing != null && existing.isNotEmpty) return existing;
    final uuid = DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
        Object().hashCode.toRadixString(36);
    await _storage.write(key: _keyDeviceUuid, value: uuid);
    return uuid;
  }

  /// Settings tablosundaki plain-text değerleri secure storage'a taşır.
  /// İlk çalıştırmada bir kez çağrılır.
  static Future<void> migrateFromPlainSettings(
    Future<String?> Function(String key) readSetting,
    Future<void> Function(String key) deleteSetting,
  ) async {
    // OpenAI key
    final existingSecure = await _storage.read(key: _keyOpenAi);
    if (existingSecure == null || existingSecure.isEmpty) {
      final plain = await readSetting('openai_api_key');
      if (plain != null && plain.isNotEmpty) {
        await setOpenAiKey(plain);
        await deleteSetting('openai_api_key');
      }
    }
    // Proxy secret
    final existingSecret = await _storage.read(key: _keyProxySecret);
    if (existingSecret == null || existingSecret.isEmpty) {
      final plain = await readSetting('groq_proxy_secret');
      if (plain != null && plain.isNotEmpty) {
        await setProxySecret(plain);
        await deleteSetting('groq_proxy_secret');
      }
    }
    // Proxy URL
    final existingUrl = await _storage.read(key: _keyProxyUrl);
    if (existingUrl == null || existingUrl.isEmpty) {
      final plain = await readSetting('groq_proxy_url');
      if (plain != null && plain.isNotEmpty) {
        await setProxyUrl(plain);
        await deleteSetting('groq_proxy_url');
      }
    }
  }
}
