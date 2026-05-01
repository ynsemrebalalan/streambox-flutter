/// Build-time configuration constants — `--dart-define` flag'leriyle beslenir.
///
/// AI altyazı (Whisper) için Groq proxy URL ve secret'ı APK'ya gömülü olarak
/// dağıtırız; kullanıcıya Settings'te göstermeyiz. CI (Codemagic) build
/// komutunda Secret variable'larından inject edilir:
///
/// ```
/// flutter build apk --release \
///   --dart-define=GROQ_PROXY_URL=https://iptvaiplayer.com.tr/groq-proxy.php \
///   --dart-define=GROQ_PROXY_SECRET=<gizli>
/// ```
///
/// Defaults boş string — debug build'de flag verilmezse [WhisperService]
/// `SecureStorage`'tan kullanıcı override'ına bakar (geliştirici hattı).
class BuildConfig {
  /// Groq Whisper proxy endpoint'i (PHP server). Boşsa Whisper devre dışı.
  static const String groqProxyUrl =
      String.fromEnvironment('GROQ_PROXY_URL', defaultValue: '');

  /// Proxy istek başlığında gönderilen `X-Proxy-Secret` değeri.
  static const String groqProxySecret =
      String.fromEnvironment('GROQ_PROXY_SECRET', defaultValue: '');

  /// AI altyazı kullanıcı tarafından açılıp kapatılabilir mi? Şimdilik her
  /// zaman aktif (true). Default kapalıya çevirmek için false yap.
  static const bool aiSubtitlesAlwaysOn = true;
}
