import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/utils/secure_storage.dart';
import '../../features/player/logic/ai_error.dart';
import '../../features/player/logic/audio_segment.dart';
import '../../features/player/logic/cancel_epoch.dart';
import '../../features/player/logic/supported_ai_languages.dart';
import '../../features/player/logic/translated_cues.dart';
import '../../features/player/services/mpv_audio_extractor.dart';
import '../models/subtitle_cue.dart';
import '../repositories/settings_repository.dart';
import 'ai_proxy_client.dart';
import 'vtt_parser.dart';

/// Başarılı AI altyazı üretimi.
class WhisperResult {
  final List<SubtitleCue> cues;
  final String provider; // 'groq' | 'openai' | 'cache'
  const WhisperResult(this.cues, this.provider);
}

class _AudioClip {
  final Uint8List bytes;
  final String filename;
  final int startSec; // klibin gerçek başlangıcı (cue offset'i)
  const _AudioClip(this.bytes, this.filename, this.startSec);
}

/// Whisper (Groq proxy veya kullanıcının kendi OpenAI anahtarı) + çeviri
/// ile AI altyazı. Android `WhisperRepository` akışı: ses çıkar → transkript
/// → hedef dile çevir → 60 sn'lik segment cache.
///
/// Hatalar [AiError] olarak fırlatılır (kod + transient); kullanıcı metni
/// UI'da l10n ile üretilir. Konuşmasız segment hata DEĞİL → boş liste.
class WhisperService {
  static const _maxFileSize = 20 * 1024 * 1024; // proxy upload sınırı altında
  static const _cacheTable = 'subtitle_cache';
  static const _maxCacheRows = 500;
  static const _cueSeparator = '\n<<CUE>>\n';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ));

  /// Süren işin iptali (altyazı kapatıldı / player kapandı): ağ istekleri
  /// [_cancel] ile kesilir, mpv çıkarımı [_epoch] ile bırakılır.
  CancelToken _cancel = CancelToken();
  final CancelEpoch _epoch = CancelEpoch();

  void cancelInFlight() {
    _epoch.bump();
    _cancel.cancel('subtitle stopped');
    _cancel = CancelToken();
  }

  static const _cancelledError =
      AiError(AiErrorCode.generic, detail: 'cancelled');

  /// [startSec] pozisyonunu içeren 60 sn'lik segment için altyazı.
  /// Dönen cue'lar MUTLAK zamanlıdır (ms, medyanın başından).
  Future<WhisperResult> transcribe({
    required String streamUrl,
    required String channelId,
    required int startSec,
    required String targetLang,
    String? userAgent,
    int mediaDurationMs = 0,
  }) async {
    final cancelled = _epoch.capture();
    final segmentSec = alignSegmentSec(startSec);
    final cacheId = whisperCacheId(channelId, segmentSec, targetLang);
    final cached = await _getFromCache(cacheId);
    if (cached != null) return WhisperResult(cached, 'cache');

    final settings = SettingsRepository();
    final provider = await settings.get(SettingsKeys.aiProvider) ?? 'groq';
    final openAiKey = await SecureStorage.getOpenAiKey();
    final useOpenAi = provider == 'openai' && openAiKey.isNotEmpty;
    final proxy = await AiProxyConfig.resolve();
    if (!useOpenAi && !proxy.isConfigured) {
      throw const AiError(AiErrorCode.notConfigured);
    }

    final clip = await _extractAudio(
      streamUrl,
      segmentSec,
      userAgent: userAgent,
      mediaDurationMs: mediaDurationMs,
      isCancelled: cancelled,
    );
    if (cancelled()) throw _cancelledError;
    if (clip == null) throw const AiError(AiErrorCode.extract);

    // OpenAI + hedef İngilizce → Whisper task=translate doğrudan İngilizce
    // üretir (Android beta68). Groq proxy `task` parametresini desteklemiyor.
    final whisperTranslates = useOpenAi && targetLang == 'en';
    final raw = await retryOnceIfTransient(() => useOpenAi
        ? _transcribeOpenAi(clip, openAiKey, translate: whisperTranslates)
        : _transcribeProxy(clip, proxy));
    if (cancelled()) throw _cancelledError;
    if (raw.isEmpty) return WhisperResult(const [], useOpenAi ? 'openai' : 'groq');

    var cues = raw;
    var translatedOk = true;
    if (!whisperTranslates && targetLang.isNotEmpty) {
      final t = await _translate(raw, targetLang,
          proxy: useOpenAi ? null : proxy, openAiKey: useOpenAi ? openAiKey : null);
      // Parça sayısı uyuşmazsa (tek birleşik cue) gösterilir ama cache'lenmez.
      translatedOk = t != null && t.aligned;
      cues = t?.cues ?? raw; // çeviri başarısız → kaynak dil (en azından altyazı görünür)
    }

    final offsetMs = clip.startSec * 1000;
    final adjusted = [
      for (final c in cues)
        SubtitleCue(startMs: c.startMs + offsetMs, endMs: c.endMs + offsetMs, text: c.text),
    ];
    if (cancelled()) throw _cancelledError;
    final providerLabel = useOpenAi ? 'openai' : 'groq';
    // Çevrilmemiş sonuç cache'lenmez → sonraki denemede tekrar çevrilir.
    if (translatedOk) {
      await _saveToCache(cacheId, channelId, segmentSec, adjusted, providerLabel);
    }
    return WhisperResult(adjusted, providerLabel);
  }

  // ── Ses çıkarımı ───────────────────────────────────────────────────────────

  Future<_AudioClip?> _extractAudio(
    String url,
    int segmentSec, {
    String? userAgent,
    int mediaDurationMs = 0,
    bool Function()? isCancelled,
  }) async {
    // 1) mpv: her kapsayıcıda tam istenen aralık, 16 kHz mono WAV (~1.9 MB).
    final wav = await MpvAudioExtractor.extract(
        url: url,
        startSec: segmentSec,
        userAgent: userAgent,
        isCancelled: isCancelled);
    if (wav != null) return _AudioClip(wav, 'audio.wav', segmentSec);
    if (isCancelled?.call() ?? false) return null;

    // 2) HTTP yedekleri.
    final headers = {'User-Agent': userAgent ?? 'StreamBox/1.0 (iOS)'};
    try {
      if (url.toLowerCase().contains('.m3u8')) {
        return await _downloadHls(url, segmentSec, headers);
      }
      return await _downloadProgressive(url, segmentSec, mediaDurationMs, headers);
    } catch (e) {
      debugPrint('[Whisper] download failed: $e');
      return null;
    }
  }

  Future<_AudioClip?> _downloadHls(
      String m3u8Url, int segmentSec, Map<String, String> headers) async {
    var playlistUrl = m3u8Url;
    var playlist = await _getText(playlistUrl, headers);
    if (playlist == null) return null;
    final variant = pickHlsVariant(playlist, Uri.parse(playlistUrl));
    if (variant != null) {
      playlistUrl = variant;
      playlist = await _getText(playlistUrl, headers);
      if (playlist == null) return null;
    }
    final segments =
        selectHlsSegments(playlist, Uri.parse(playlistUrl), startSec: segmentSec);
    if (segments.isEmpty) return null;
    final buffer = BytesBuilder(copy: false);
    for (final s in segments) {
      final resp = await _dio.get<List<int>>(s.url,
          cancelToken: _cancel,
          options: Options(responseType: ResponseType.bytes, headers: headers));
      if (resp.data != null) buffer.add(resp.data!);
      if (buffer.length > _maxFileSize) break;
    }
    if (buffer.isEmpty) return null;
    return _AudioClip(buffer.toBytes(), 'audio.ts', segments.first.startSec.floor());
  }

  /// Progressive yedek: yalnızca kendiliğinden senkronlanan MPEG-TS ortasından
  /// bayt aralığı çözülebilir; diğer kapsayıcılarda sadece dosya başı (segment 0).
  /// Bit hızı ortalamadan tahmin edildiği için zamanlama yaklaşıktır.
  Future<_AudioClip?> _downloadProgressive(String url, int segmentSec,
      int mediaDurationMs, Map<String, String> headers) async {
    final isTs = Uri.tryParse(url)?.path.toLowerCase().endsWith('.ts') ?? false;
    ByteRange range = const ByteRange(0, _maxFileSize - 1);
    if (segmentSec > 0) {
      if (!isTs || mediaDurationMs <= 0) return null;
      final total = await _probeContentLength(url, headers);
      final r = total == null
          ? null
          : progressiveByteRange(
              contentLength: total,
              durationSec: mediaDurationMs / 1000,
              startSec: segmentSec,
              maxBytes: _maxFileSize);
      if (r == null) return null;
      range = r;
    }
    final resp = await _dio.get<List<int>>(url,
        cancelToken: _cancel,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {...headers, 'Range': range.header},
        ));
    final data = resp.data;
    if (data == null || data.isEmpty) return null;
    final bytes = Uint8List.fromList(data);
    return _AudioClip(
      bytes.length > _maxFileSize ? bytes.sublist(0, _maxFileSize) : bytes,
      isTs ? 'audio.ts' : 'audio.mp4',
      segmentSec,
    );
  }

  Future<int?> _probeContentLength(String url, Map<String, String> headers) async {
    try {
      final resp = await _dio.get<List<int>>(url,
          cancelToken: _cancel,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {...headers, 'Range': 'bytes=0-0'},
          ));
      final cr = resp.headers.value('content-range'); // bytes 0-0/12345
      final total = cr == null ? null : int.tryParse(cr.split('/').last.trim());
      return total ?? int.tryParse(resp.headers.value('content-length') ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<String?> _getText(String url, Map<String, String> headers) async {
    final resp = await _dio.get<String>(url,
        cancelToken: _cancel,
        options: Options(responseType: ResponseType.plain, headers: headers));
    return resp.data;
  }

  // ── Transkripsiyon ─────────────────────────────────────────────────────────

  Future<List<SubtitleCue>> _transcribeProxy(_AudioClip clip, AiProxyConfig proxy) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(clip.bytes, filename: clip.filename),
        'model': 'whisper-large-v3',
        // Groq vtt desteklemiyor (json/verbose_json/text) — Android ile aynı.
        'response_format': 'verbose_json',
      });
      final resp = await _dio.post<String>(proxy.url,
          data: form,
          cancelToken: _cancel,
          options: Options(headers: await proxy.headers(), responseType: ResponseType.plain));
      return _parseTranscript(resp.data);
    } on DioException catch (e) {
      throw mapDioException(e, viaProxy: true);
    }
  }

  Future<List<SubtitleCue>> _transcribeOpenAi(_AudioClip clip, String apiKey,
      {required bool translate}) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(clip.bytes, filename: clip.filename),
        'model': 'whisper-1',
        'response_format': 'vtt',
      });
      final endpoint = translate ? 'translations' : 'transcriptions';
      final resp = await _dio.post<String>('https://api.openai.com/v1/audio/$endpoint',
          data: form,
          cancelToken: _cancel,
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            responseType: ResponseType.plain,
          ));
      return _parseTranscript(resp.data);
    } on DioException catch (e) {
      throw mapDioException(e, viaProxy: false);
    }
  }

  /// VTT veya (verbose_)json. Boş gövde → emptyResponse; konuşma yok → [].
  List<SubtitleCue> _parseTranscript(String? body) {
    if (body == null || body.trim().isEmpty) {
      throw const AiError(AiErrorCode.emptyResponse, transient: true);
    }
    if (body.contains('WEBVTT') || body.contains('-->')) {
      return VttParser.parse(body);
    }
    try {
      var json = jsonDecode(body);
      if (json is Map && json['data'] is Map) json = json['data'];
      if (json is Map && json['result'] is Map) json = json['result'];
      if (json is Map && json['segments'] is List) {
        return [
          for (final s in json['segments'] as List)
            if (s is Map && (s['text'] as String? ?? '').trim().isNotEmpty)
              SubtitleCue(
                startMs: ((s['start'] as num) * 1000).round(),
                endMs: ((s['end'] as num) * 1000).round(),
                text: (s['text'] as String).trim(),
              ),
        ];
      }
      if (json is Map && json['text'] is String) {
        final text = (json['text'] as String).trim();
        return text.isEmpty ? [] : [SubtitleCue(startMs: 0, endMs: 30000, text: text)];
      }
    } catch (_) {}
    throw const AiError(AiErrorCode.generic, transient: true, detail: 'unparseable');
  }

  // ── Çeviri ─────────────────────────────────────────────────────────────────

  /// Android translateCues: `<<CUE>>` ayraçlı tek istek, 2 deneme / 800 ms.
  /// Başarısızsa null.
  Future<TranslatedCues?> _translate(List<SubtitleCue> cues, String targetLang,
      {AiProxyConfig? proxy, String? openAiKey}) async {
    final combined = cues.map((c) => c.text).join(_cueSeparator);
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final text = proxy != null
            ? await _translateViaProxy(combined, targetLang, proxy)
            : await _translateViaOpenAi(combined, targetLang, openAiKey!);
        final split = splitTranslatedCues(cues, text);
        if (split != null) return split;
      } catch (e) {
        debugPrint('[Whisper] translate attempt ${attempt + 1} failed: $e');
      }
      if (attempt == 0) await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    return null;
  }

  Future<String?> _translateViaProxy(String text, String lang, AiProxyConfig proxy) async {
    final resp = await _dio.post<String>(
      proxy.endpoint('translate'),
      data: FormData.fromMap({'text': text, 'target_lang': lang}),
      options: Options(headers: await proxy.headers(), responseType: ResponseType.plain),
    );
    return _chatContent(resp.data);
  }

  Future<String?> _translateViaOpenAi(String text, String lang, String apiKey) async {
    final name = SupportedAiLanguages.displayName(lang);
    final sys = 'You are a professional subtitle translator. Translate the given text to '
        '$name ($lang). The text contains subtitle lines separated by <<CUE>> markers. '
        'Return ONLY the translation, preserve the <<CUE>> markers, no explanation.';
    final resp = await _dio.post<String>(
      'https://api.openai.com/v1/chat/completions',
      data: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': sys},
          {'role': 'user', 'content': text},
        ],
        'max_tokens': 2000,
        'temperature': 0.1,
      }),
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        responseType: ResponseType.plain,
      ),
    );
    return _chatContent(resp.data);
  }

  String? _chatContent(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final json = jsonDecode(body);
      final content = json['choices']?[0]?['message']?['content'];
      return content is String ? content.trim() : null;
    } catch (_) {
      return null;
    }
  }

  // ── Cache ──────────────────────────────────────────────────────────────────

  Future<List<SubtitleCue>?> _getFromCache(String id) async {
    try {
      final db = await AppDatabase.instance;
      final rows = await db.query(_cacheTable, where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) return null;
      final json = jsonDecode(rows.first['cuesJson'] as String) as List;
      final cues = json.map((j) => SubtitleCue.fromJson(j as Map<String, dynamic>)).toList();
      return cues.isEmpty ? null : cues;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(String id, String channelId, int segmentSec,
      List<SubtitleCue> cues, String provider) async {
    if (cues.isEmpty) return;
    try {
      final db = await AppDatabase.instance;
      await db.insert(
        _cacheTable,
        {
          'id': id,
          'channelId': channelId,
          'segmentSec': segmentSec,
          'cuesJson': jsonEncode(cues.map((c) => c.toJson()).toList()),
          'provider': provider,
          'cachedAt': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.execute('''
        DELETE FROM $_cacheTable WHERE id NOT IN
        (SELECT id FROM $_cacheTable ORDER BY cachedAt DESC LIMIT $_maxCacheRows)
      ''');
    } catch (e) {
      debugPrint('[Whisper] cache save failed: $e');
    }
  }
}
