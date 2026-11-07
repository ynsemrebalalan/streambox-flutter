/// Oynatıcı için saf karar fonksiyonları (Android PlayerViewModel paritesi).
library;

/// Android: `lastPosition > 10_000` ise "Devam / Baştan" sorulur.
const int kResumeThresholdMs = 10000;

/// Sona bu kadar yakınken (Android END_TOLERANCE_MS) konum ilerlemiyorsa bitti.
const int kEndToleranceMs = 1500;

bool shouldOfferResume({
  required int savedMs,
  required String streamType,
  int durationMs = 0,
}) {
  if (streamType == 'live') return false;
  if (savedMs <= kResumeThresholdMs) return false;
  // Neredeyse bitmiş içerikte "devam" sona atlayıp hemen sonraki bölüme geçirir.
  if (durationMs > 0 && savedMs >= durationMs * 0.95) return false;
  return true;
}

/// %90+ ilerleme → izlendi (tek seferlik).
bool reachedWatchedThreshold({required int positionMs, required int durationMs}) =>
    durationMs > 0 && positionMs / durationMs >= 0.90;

/// IPTV VOD'da `completed` bazen hiç gelmiyor (sunucu gövdeyi düzgün
/// kapatmıyor) → son karede donma. 500 ms'lik tiklerle beslenir; sona
/// ≤1.5 sn kala konum 4 tik (2 sn) ilerlemezse medya bitmiş sayılır.
class EndOfMediaDetector {
  int _lastPos = -1;
  int _stalled = 0;

  bool tick({
    required int positionMs,
    required int durationMs,
    required bool playWhenReady,
  }) {
    var fired = false;
    if (durationMs > 0 && playWhenReady && positionMs >= durationMs - kEndToleranceMs) {
      if (positionMs <= _lastPos) {
        _stalled++;
      } else {
        _stalled = 0;
      }
      fired = _stalled >= 4;
    } else {
      _stalled = 0;
    }
    _lastPos = positionMs;
    return fired;
  }

  void reset() {
    _lastPos = -1;
    _stalled = 0;
  }
}

/// Android: `StreamBox/<ver> (Android ExoPlayer)` → iOS: `StreamBox/<ver> (iOS)`.
String playbackUserAgent(String version) => 'StreamBox/$version (iOS)';

const int kBufferMsMin = 2000;
const int kBufferMsMax = 8000;
const int kBufferMsDefault = 8000;

/// Ayar (Android slider 2000..8000 ms) → mpv `cache-secs`. +2 sn pay: varsayılan
/// 8000 ms önceki sabit 10 sn davranışını korur.
int cacheSecsForBufferMs(int bufferMs) =>
    bufferMs.clamp(kBufferMsMin, kBufferMsMax) ~/ 1000 + 2;

/// Göreli sarma hedefi; 0 ile süre arasında sıkıştırılır (süre bilinmiyorsa üst sınır yok).
int seekTargetMs({required int currentMs, required int deltaMs, required int durationMs}) {
  var t = currentMs + deltaMs;
  if (t < 0) t = 0;
  if (durationMs > 0 && t > durationMs) t = durationMs;
  return t;
}
