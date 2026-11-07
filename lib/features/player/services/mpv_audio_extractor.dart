import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';

/// AI altyazı için istenen aralığın sesini libmpv ile 16 kHz mono WAV'a çıkarır.
///
/// Neden: önceki yöntem progressive dosyada her zaman ilk 10 MB'ı indiriyordu
/// (startSec yok sayılıyordu) ve MP4/MKV ortasından alınan bayt aralığı
/// `moov`/başlık olmadan çözülemez. mpv zaten bağımlılık (media_kit); ikinci,
/// görüntüsüz bir örnek `ao=pcm` ile sesi dosyaya yazar, `start/end` ile tam
/// istenen aralığa sarar — her kapsayıcı (MP4/MKV/TS/HLS) için çalışır.
/// Android'in MediaExtractor+MediaCodec yolunun karşılığıdır.
///
/// Sınırlar (cihazda doğrulanmalı):
/// * `ao_pcm` mpv'de "untimed" çalışır (gerçek zamandan hızlı); yapı farklıysa
///   [timeout] dolunca o ana kadar yazılan kısım kullanılır.
/// * `current-ao` pcm değilse (ör. ao seçeneği çalışma anında uygulanmadıysa)
///   çıkarım hemen iptal edilir ve çağıran HTTP yoluna düşer.
class MpvAudioExtractor {
  static const int _sampleRate = 16000;
  static const int _bytesPerSec = _sampleRate * 2; // mono s16
  static const int _minAudioSec = 3;

  /// `current-ao` yalnız açıkça `pcm` ise doğrulanmış sayılır. Boş = henüz
  /// bilinmiyor / uygulanmadı → ses hoparlörden çalıyor olabilir.
  static bool isPcmAoConfirmed(String ao) => ao == 'pcm';

  /// [isCancelled] true dönerse (altyazı kapatıldı / oynatıcı kapandı)
  /// çıkarım bırakılır, null döner. Geçici WAV her yolda silinir.
  static Future<Uint8List?> extract({
    required String url,
    required int startSec,
    int durationSec = 60,
    String? userAgent,
    Duration timeout = const Duration(seconds: 40),
    bool Function()? isCancelled,
  }) async {
    bool cancelled() => isCancelled?.call() ?? false;
    final path =
        '${Directory.systemTemp.path}/ai_audio_${DateTime.now().microsecondsSinceEpoch}.wav';
    final player = Player(
      configuration: const PlayerConfiguration(
        vo: 'null',
        title: 'ai-audio-extract',
        bufferSize: 8 * 1024 * 1024,
      ),
    );
    StreamSubscription<bool>? doneSub;
    StreamSubscription<String>? errSub;
    // true → dosya okunmaz, finally'de silinir (erken çıkış / iptal).
    var abandon = true;
    try {
      final native = player.platform;
      if (native is! NativePlayer) return null;
      final props = <String, String>{
        'ao': 'pcm',
        'ao-pcm-file': path,
        'ao-pcm-waveheader': 'yes',
        'audio-samplerate': '$_sampleRate',
        'audio-channels': 'mono',
        'audio-format': 's16',
        'vid': 'no',
        'sid': 'no',
        if (userAgent != null) 'user-agent': userAgent,
        'network-timeout': '15',
      };
      for (final e in props.entries) {
        await native.setProperty(e.key, e.value);
      }

      final done = Completer<void>();
      doneSub = player.stream.completed.listen((c) {
        if (c && !done.isCompleted) done.complete();
      });
      errSub = player.stream.error.listen((e) {
        debugPrint('[AiExtract] mpv error: $e');
      });

      await player.open(
        Media(
          url,
          start: Duration(seconds: startSec),
          end: Duration(seconds: startSec + durationSec),
        ),
        play: true,
      );

      // ao seçeneği uygulanmadıysa ses hoparlörden çalar → hemen bırak.
      // Boş `current-ao` = doğrulanmadı: kısa süre bekle, yine boşsa bırak.
      var ao = '';
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(
            Duration(milliseconds: i == 0 ? 1200 : 400));
        if (cancelled()) return null;
        ao = await native.getProperty('current-ao');
        if (ao.isNotEmpty) break;
      }
      if (!isPcmAoConfirmed(ao)) {
        debugPrint('[AiExtract] current-ao="$ao" (pcm dogrulanmadi) → iptal');
        return null;
      }

      final deadline = DateTime.now().add(timeout);
      while (!done.isCompleted) {
        if (cancelled()) return null;
        final left = deadline.difference(DateTime.now());
        if (left <= Duration.zero) {
          debugPrint('[AiExtract] timeout — kismi ses kullanilacak');
          break;
        }
        await Future.any([
          done.future,
          Future<void>.delayed(
              left < const Duration(milliseconds: 250) ? left : const Duration(milliseconds: 250)),
        ]);
      }
      abandon = false;
    } catch (e) {
      debugPrint('[AiExtract] failed: $e');
      // Kısmi ses yine denenebilir (önceki davranış) — iptal değilse.
      abandon = cancelled();
    } finally {
      await doneSub?.cancel();
      await errSub?.cancel();
      // dispose → ao uninit → WAV başlığındaki boyutlar yazılır.
      try {
        await player.dispose();
      } catch (_) {}
      if (abandon) await _deleteQuietly(path);
    }
    if (cancelled()) {
      await _deleteQuietly(path);
      return null;
    }
    return _readAndDelete(path);
  }

  static Future<void> _deleteQuietly(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<Uint8List?> _readAndDelete(String path) async {
    final f = File(path);
    try {
      if (!await f.exists()) return null;
      final bytes = await f.readAsBytes();
      if (bytes.length < 44 + _bytesPerSec * _minAudioSec) return null;
      return bytes;
    } catch (_) {
      return null;
    } finally {
      try {
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }
}
