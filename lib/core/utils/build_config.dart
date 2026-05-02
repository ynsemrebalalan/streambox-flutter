/// Build-time configuration constants — `--dart-define` flag'leriyle beslenir.
///
/// AI altyazı (Whisper) için Groq proxy URL ve secret'ı APK'ya gömülü olarak
/// dağıtırız; kullanıcıya Settings'te göstermeyiz.
///
/// **CI / production:** Codemagic Secret variable'larıyla `--dart-define`
/// üzerinden inject edilir (build sırasında aşağıdaki defaultValue'ları
/// override eder):
///
/// ```
/// flutter build ipa --release \
///   --dart-define=GROQ_PROXY_URL=$GROQ_PROXY_URL \
///   --dart-define=GROQ_PROXY_SECRET=$GROQ_PROXY_SECRET
/// ```
///
/// **Lokal / debug build:** flag verilmezse aşağıdaki `defaultValue`'lar
/// kullanılır (Android `local.properties` ile aynı canlı değerler). Bu
/// sayede `flutter run`'da AI altyazı sıfır konfigürasyonla çalışır.
class BuildConfig {
  /// Groq Whisper proxy endpoint'i (PHP server). Boşsa Whisper devre dışı.
  static const String groqProxyUrl =
      String.fromEnvironment(
    'GROQ_PROXY_URL',
    defaultValue: 'https://iptvaiplayer.com.tr/api/groq-proxy.php',
  );

  /// Proxy istek başlığında gönderilen `X-Proxy-Secret` değeri.
  static const String groqProxySecret =
      String.fromEnvironment(
    'GROQ_PROXY_SECRET',
    defaultValue:
        'sH0nN2pyIZ5jjGtqewMOZ1czE34QlV3EkTTnQqvg8JMBrVWSuYDGfp9mgqznRxrw',
  );

  /// AI altyazı kullanıcı tarafından açılıp kapatılabilir mi? Şimdilik her
  /// zaman aktif (true). Default kapalıya çevirmek için false yap.
  static const bool aiSubtitlesAlwaysOn = true;
}
