import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iOS Keychain / Android EncryptedSharedPreferences ile
/// hassas verileri güvenli saklama.
class SecureStorage {
  // App Review / fresh install cihazlarinda first_unlock
  // errSecInteractionNotAllowed atabilir. first_unlock_this_device + synchronizable:false
  // ile bu riski kaldiriyoruz.
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
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

  // ── Parental Lock PIN — SHA-256 + salt ────────────────────────────────────
  //
  // v1 (eski): 'parental_pin' key'inde plain-text saklanıyordu.
  // v2 (yeni): 'parental_pin_hash' + 'parental_pin_salt' çifti kullanılır.
  //   Salt: 16 random byte (base64url), Hash: sha256(saltBase64 + pin).
  //
  // Migration: setParentalPin / verifyParentalPin ilk çağrısında eski key
  //   varsa otomatik olarak hashlenip yeni key'lere taşınır, eski key silinir.

  static const _keyParentalPin = 'parental_pin'; // legacy – migration source
  static const _keyParentalPinHash = 'parental_pin_hash';
  static const _keyParentalPinSalt = 'parental_pin_salt';

  // SharedPreferences keys (cooldown gizli veri değil, SecureStorage gereksiz)
  static const _prefFailedAttempts = 'parental_failed_attempts';
  static const _prefCooldownUntil = 'parental_cooldown_until';

  /// Salt üretimi: 16 kriptografik random byte → base64url string.
  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(16, (_) => rng.nextInt(256)),
    );
    return base64Url.encode(bytes);
  }

  /// saltBase64 + pin'i SHA-256 ile hashler.
  static String _hashPin(String saltBase64, String pin) {
    final data = utf8.encode('$saltBase64$pin');
    return sha256.convert(data).toString();
  }

  /// Eski plain-text PIN varsa tek seferlik hash'e migrate et.
  static Future<void> _migrateLegacyPinIfNeeded() async {
    final legacyPin = await _storage.read(key: _keyParentalPin);
    if (legacyPin == null || legacyPin.isEmpty) return;
    // Zaten yeni format varsa tekrar yazma.
    final existingHash = await _storage.read(key: _keyParentalPinHash);
    if (existingHash != null && existingHash.isNotEmpty) {
      await _storage.delete(key: _keyParentalPin);
      return;
    }
    // Hash'le ve kaydet.
    final salt = _generateSalt();
    final hash = _hashPin(salt, legacyPin);
    await _storage.write(key: _keyParentalPinSalt, value: salt);
    await _storage.write(key: _keyParentalPinHash, value: hash);
    await _storage.delete(key: _keyParentalPin);
  }

  /// PIN'i hash + salt olarak Keychain'e yazar.
  static Future<void> setParentalPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(salt, pin);
    await _storage.write(key: _keyParentalPinSalt, value: salt);
    await _storage.write(key: _keyParentalPinHash, value: hash);
    // Legacy key temizle (varsa).
    await _storage.delete(key: _keyParentalPin);
  }

  /// Girilen PIN'i kayıtlı hash ile karşılaştırır.
  /// Migration otomatik uygulanır.
  static Future<bool> verifyParentalPin(String input) async {
    await _migrateLegacyPinIfNeeded();
    final salt = await _storage.read(key: _keyParentalPinSalt);
    final hash = await _storage.read(key: _keyParentalPinHash);
    if (salt == null || hash == null) return false;
    return _hashPin(salt, input) == hash;
  }

  /// Kayıtlı PIN var mı? (hash key'in varlığına bakılır)
  static Future<bool> hasParentalPin() async {
    await _migrateLegacyPinIfNeeded();
    final hash = await _storage.read(key: _keyParentalPinHash);
    return hash != null && hash.isNotEmpty;
  }

  static Future<void> deleteParentalPin() async {
    await _storage.delete(key: _keyParentalPinHash);
    await _storage.delete(key: _keyParentalPinSalt);
    await _storage.delete(key: _keyParentalPin); // legacy temizle
  }

  // ── Brute-force cooldown (SharedPreferences) ───────────────────────────────

  static Future<int> getFailedPinAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefFailedAttempts) ?? 0;
  }

  static Future<void> incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_prefFailedAttempts) ?? 0;
    await prefs.setInt(_prefFailedAttempts, current + 1);
  }

  static Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefFailedAttempts);
  }

  static Future<DateTime?> getCooldownUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_prefCooldownUntil);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> setCooldownUntil(DateTime until) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _prefCooldownUntil, until.millisecondsSinceEpoch);
  }

  static Future<void> clearCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCooldownUntil);
  }

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
