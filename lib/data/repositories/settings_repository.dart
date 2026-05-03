import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';

class SettingsRepository {
  static const _table = 'settings';

  Future<String?> get(String key) async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(_table, where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> set(String key, String value) async {
    final db = await AppDatabase.instance;
    await db.insert(
      _table,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String key) async {
    final db = await AppDatabase.instance;
    await db.delete(_table, where: 'key = ?', whereArgs: [key]);
  }

  Future<Map<String, String>> getAll() async {
    final db   = await AppDatabase.instance;
    final rows = await db.query(_table);
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }
}

// Well-known keys
abstract final class SettingsKeys {
  static const String activePlaylistId = 'active_playlist_id';
  static const String themeMode        = 'theme_mode';       // 'dark' | 'light' | 'system'
  static const String epgUrl           = 'epg_url';
  static const String openAiApiKey     = 'openai_api_key';
  static const String openAiLanguage   = 'openai_language';
  static const String groqProxyUrl     = 'groq_proxy_url';
  static const String groqProxySecret  = 'groq_proxy_secret';
  static const String defaultTab       = 'default_tab';      // 'live' | 'movie' | 'series'
  static const String displayMode      = 'display_mode';     // 'list' | 'vod'
  static const String uiMode           = 'ui_mode';
  static const String parentalPin              = 'parental_pin';              // SecureStorage'a taşınacak (PIN encrypted)
  static const String parentalLockEnabled      = 'parental_lock_enabled';      // 'true'|'false'
  static const String parentalLockedCategories = 'parental_locked_categories'; // JSON List<String>
  static const String themeVariant             = 'theme_variant';              // 'default'|'crimson'|'royal'|'forest'|'ocean'
  static const String epgAutoRefreshHours      = 'epg_auto_refresh_hours';     // '0'|'6'|'12'|'24' (0=off, Pro)
  static const String epgLastAutoFetchMs       = 'epg_last_auto_fetch_ms';     // unix ms
  static const String watchlistAddedKeys       = 'watchlist_added_keys';       // (cache; gerçek kayıt watchlist tablosunda)
  static const String lastCategory       = 'last_category';
  static const String disclaimerAccepted = 'disclaimer_accepted';
  static const String hiddenCategories   = 'hidden_categories'; // JSON Set<String>
  static const String subtitleTextColor  = 'subtitle_text_color';
  static const String subtitleBgColor    = 'subtitle_bg_color';
  static const String subtitleFontSize   = 'subtitle_font_size';
  static const String refreshIntervalH   = 'refresh_interval_hours'; // 0=off, -1=on_open
  static const String secureStorageMigrated = 'secure_storage_migrated';
  static const String language = 'language'; // 'system' | 'tr' | 'en' | 'de' | 'ar'
  static const String welcomeShown = 'welcome_shown'; // 'true' = welcome screen kapatildi
  static const String activeProfileId = 'active_profile_id'; // Phase 6 (default 'default')
}
