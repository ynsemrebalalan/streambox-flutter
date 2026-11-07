import 'dart:convert';

import 'settings_repository.dart';

/// Gizli kategoriler — playlist başına (Android CategoryFilterScreen paritesi).
/// Eski global `hidden_categories` anahtarı DB v9'da aktif playlist'e taşındı.
class HiddenCategoriesRepository {
  final SettingsRepository _settings;
  HiddenCategoriesRepository(this._settings);

  static String keyFor(String playlistId) => 'hidden_categories_$playlistId';

  static Set<String> decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      return (jsonDecode(raw) as List)
          .map((e) => '$e'.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> get(String playlistId) async {
    if (playlistId.isEmpty) return {};
    return decode(await _settings.get(keyFor(playlistId)));
  }

  Future<void> set(String playlistId, Set<String> hidden) async {
    if (playlistId.isEmpty) return;
    if (hidden.isEmpty) {
      await _settings.delete(keyFor(playlistId));
      return;
    }
    await _settings.set(keyFor(playlistId), jsonEncode(hidden.toList()));
  }

  Future<void> clear(String playlistId) => _settings.delete(keyFor(playlistId));
}
