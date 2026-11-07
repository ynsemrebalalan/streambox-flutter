/// AI altyazı hedef dilleri — Android `SupportedAiLanguages.kt` ve sunucu
/// `groq-proxy.php` langMap ile birebir (sunucu tanımadığı kodu İngilizce'ye düşürür).
///
/// Android adları `Locale.getDisplayLanguage(uiLocale)` ile cihaz diline göre
/// üretiyor; Flutter'da bu API yok ve ek paket eklememek için dil adları
/// kendi dilinde (endonym) gösterilir — her kullanıcı kendi dilini tanır.
abstract final class SupportedAiLanguages {
  static const List<String> codes = [
    'ar', 'az', 'bg', 'cs', 'da', 'de', 'el', 'en', 'es', 'fa',
    'fi', 'fr', 'he', 'hi', 'hr', 'hu', 'id', 'it', 'ja', 'ka',
    'ko', 'ms', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sr',
    'sv', 'th', 'tr', 'uk', 'vi', 'zh',
  ];

  static const Map<String, String> _names = {
    'ar': 'العربية',
    'az': 'Azərbaycanca',
    'bg': 'Български',
    'cs': 'Čeština',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'fa': 'فارسی',
    'fi': 'Suomi',
    'fr': 'Français',
    'he': 'עברית',
    'hi': 'हिन्दी',
    'hr': 'Hrvatski',
    'hu': 'Magyar',
    'id': 'Bahasa Indonesia',
    'it': 'Italiano',
    'ja': '日本語',
    'ka': 'ქართული',
    'ko': '한국어',
    'ms': 'Bahasa Melayu',
    'nl': 'Nederlands',
    'no': 'Norsk',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'ru': 'Русский',
    'sk': 'Slovenčina',
    'sr': 'Српски',
    'sv': 'Svenska',
    'th': 'ไทย',
    'tr': 'Türkçe',
    'uk': 'Українська',
    'vi': 'Tiếng Việt',
    'zh': '中文',
  };

  static bool isSupported(String code) => codes.contains(code.toLowerCase());

  static String displayName(String code) {
    if (code.isEmpty) return '';
    return _names[code.toLowerCase()] ?? code.toUpperCase();
  }

  /// Ada göre sıralı (kod → ad) liste.
  static List<MapEntry<String, String>> sortedByDisplay() =>
      codes.map((c) => MapEntry(c, displayName(c))).toList()
        ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
}

/// Hedef dil: kullanıcı tercihi > cihaz dili (destekleniyorsa) > 'en'.
String resolveAiTargetLang({required String pref, required String deviceLang}) {
  final p = pref.trim().toLowerCase();
  if (p.isNotEmpty && SupportedAiLanguages.isSupported(p)) return p;
  final d = deviceLang.split(RegExp('[_-]')).first.toLowerCase();
  if (d.isNotEmpty && SupportedAiLanguages.isSupported(d)) return d;
  return 'en';
}
