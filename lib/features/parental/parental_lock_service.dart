import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/utils/secure_storage.dart';
import '../../data/repositories/settings_repository.dart';

/// Pure data-layer ebeveyn kilidi yönetimi.
///
/// PIN: SecureStorage (iOS Keychain / Android EncryptedSharedPreferences),
///   plain-text DB satırı olmaz.
/// Enabled flag + locked categories: settings tablosu.
/// PIN unlock'ları geçici (uygulama oturumu boyunca) — process kill sonrası
/// tekrar PIN istenir. Bu davranış `parentalUnlockedProvider` (StateProvider)
/// ile yönetilir.
class ParentalLockService {
  final SettingsRepository _settings;

  ParentalLockService(this._settings);

  // ── PIN ────────────────────────────────────────────────────────────────────

  Future<bool> hasPin() async {
    final pin = await SecureStorage.getParentalPin();
    return pin.length == 4;
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 4 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN 4 haneli rakam olmalı');
    }
    await SecureStorage.setParentalPin(pin);
  }

  Future<bool> verifyPin(String pin) async {
    final saved = await SecureStorage.getParentalPin();
    return saved == pin;
  }

  Future<void> clearPin() async {
    await SecureStorage.deleteParentalPin();
    await setEnabled(false);
    await setLockedCategories({});
  }

  // ── Enable/Disable ─────────────────────────────────────────────────────────

  Future<bool> isEnabled() async {
    final raw = await _settings.get(SettingsKeys.parentalLockEnabled);
    return raw == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await _settings.set(
      SettingsKeys.parentalLockEnabled,
      enabled ? 'true' : 'false',
    );
  }

  // ── Locked categories ──────────────────────────────────────────────────────

  Future<Set<String>> lockedCategories() async {
    final raw = await _settings.get(SettingsKeys.parentalLockedCategories);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> setLockedCategories(Set<String> cats) async {
    await _settings.set(
      SettingsKeys.parentalLockedCategories,
      jsonEncode(cats.toList()),
    );
  }

  Future<bool> isCategoryLocked(String category) async {
    if (!await isEnabled()) return false;
    final locked = await lockedCategories();
    return locked.contains(category.toLowerCase());
  }
}

// ── Riverpod provider'ları ───────────────────────────────────────────────────

final parentalLockServiceProvider = Provider<ParentalLockService>((ref) {
  return ParentalLockService(ref.read(settingsRepoProvider));
});

/// Aktif oturumda kilit açıldı mı? Process kill ile sıfırlanır (Provider
/// state app yaşam döngüsü boyu yaşar). UI bir kategori için unlock
/// alındıysa session boyunca tekrar PIN sormaz.
final parentalUnlockedProvider = StateProvider<Set<String>>((_) => {});
