import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/secure_storage.dart';
import '../models/subtitle_cue.dart';
import 'vtt_parser.dart';

/// Whisper API (Groq proxy + OpenAI fallback) ile AI altyazi servisi.
/// 60 saniyelik segment boundary ile cache.
class WhisperService {
  static const _segmentSec = 60;
  static const _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const _cacheTable = 'subtitle_cache';
  static const _maxCacheRows = 500;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    sendTimeout: const Duration(seconds: 60),
  ));

  /// Verilen stream pozisyonu icin altyazi uret veya cache'den getir.
  Future<List<SubtitleCue>> transcribe({
    required String streamUrl,
    required String channelId,
    required int startSec,
    String language = '',
  }) async {
    // 60-saniyelik segment boundary'ye hizala.
    final segmentSec = (startSec ~/ _segmentSec) * _segmentSec;

    // Cache kontrol
    final cached = await _getFromCache(channelId, segmentSec);
    if (cached != null) return cached;

    // Stream'den segment indir
    final audioBytes = await _downloadSegment(streamUrl, segmentSec);
    if (audioBytes == null || audioBytes.isEmpty) return [];

    // Groq proxy → OpenAI fallback
    List<SubtitleCue>? cues;
    String provider = 'groq';

    final proxyUrl = await SecureStorage.getProxyUrl();
    final proxySecret = await SecureStorage.getProxySecret();

    if (proxyUrl.isNotEmpty && proxySecret.isNotEmpty) {
      cues = await _transcribeViaProxy(
          audioBytes, proxyUrl, proxySecret, language);
    }

    if (cues == null) {
      final openAiKey = await SecureStorage.getOpenAiKey();
      if (openAiKey.isNotEmpty) {
        provider = 'openai';
        cues = await _transcribeViaOpenAi(audioBytes, openAiKey, language);
      }
    }

    if (cues == null || cues.isEmpty) return [];

    // Timestamp offset: segment baslangicina gore kaydır
    final offsetMs = segmentSec * 1000;
    final adjusted = cues
        .map((c) => SubtitleCue(
              startMs: c.startMs + offsetMs,
              endMs: c.endMs + offsetMs,
              text: c.text,
            ))
        .toList();

    // Cache'e kaydet
    await _saveToCache(channelId, segmentSec, adjusted, provider);

    return adjusted;
  }

  /// Stream URL'den belirli bir segment indir.
  /// HLS (.m3u8) icin segment URL'lerini parse eder.
  /// Direkt stream icin Range header ile indir.
  Future<Uint8List?> _downloadSegment(String url, int startSec) async {
    try {
      if (url.contains('.m3u8')) {
        return await _downloadHlsSegment(url, startSec);
      }
      // Direkt stream: ilk N saniyeyi indir (basit yaklasim)
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'IPTVAIPlayer/1.0',
            'Range': 'bytes=0-$_maxFileSize',
          },
        ),
      );
      if (response.data == null) return null;
      final bytes = Uint8List.fromList(response.data!);
      // 10MB'dan buyukse kes
      return bytes.length > _maxFileSize
          ? bytes.sublist(0, _maxFileSize)
          : bytes;
    } catch (e) {
      debugPrint('[Whisper] download failed: $e');
      return null;
    }
  }

  /// HLS playlist'ten segment indir.
  Future<Uint8List?> _downloadHlsSegment(String m3u8Url, int startSec) async {
    try {
      // m3u8 indir
      final playlistResp = await _dio.get<String>(m3u8Url);
      final playlist = playlistResp.data;
      if (playlist == null) return null;

      // Segment URL'lerini parse et
      final lines = playlist.split('\n');
      final segments = <String>[];
      double accDuration = 0;
      double? segDuration;

      for (final line in lines) {
        if (line.startsWith('#EXTINF:')) {
          segDuration =
              double.tryParse(line.split(':')[1].split(',')[0].trim());
        } else if (!line.startsWith('#') && line.trim().isNotEmpty) {
          if (segDuration != null) {
            accDuration += segDuration;
            // startSec civarindaki segment'leri topla (~30 saniyelik)
            if (accDuration >= startSec && accDuration <= startSec + 30) {
              final segUrl = line.trim().startsWith('http')
                  ? line.trim()
                  : Uri.parse(m3u8Url).resolve(line.trim()).toString();
              segments.add(segUrl);
            }
            segDuration = null;
          }
        }
      }

      if (segments.isEmpty) {
        // Baslangiç segment'leri yoksa ilk 2 segment'i al
        double? sd2;
        for (final line in lines) {
          if (line.startsWith('#EXTINF:')) {
            sd2 = double.tryParse(line.split(':')[1].split(',')[0].trim());
          } else if (!line.startsWith('#') && line.trim().isNotEmpty) {
            if (sd2 != null) {
              final segUrl = line.trim().startsWith('http')
                  ? line.trim()
                  : Uri.parse(m3u8Url).resolve(line.trim()).toString();
              segments.add(segUrl);
              if (segments.length >= 3) break;
              sd2 = null;
            }
          }
        }
      }

      if (segments.isEmpty) return null;

      // Segment'leri indir ve birlestir
      final buffer = BytesBuilder(copy: false);
      for (final segUrl in segments) {
        final resp = await _dio.get<List<int>>(
          segUrl,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'User-Agent': 'IPTVAIPlayer/1.0'},
          ),
        );
        if (resp.data != null) buffer.add(resp.data!);
        if (buffer.length > _maxFileSize) break;
      }
      return buffer.toBytes();
    } catch (e) {
      debugPrint('[Whisper] HLS segment download failed: $e');
      return null;
    }
  }

  /// Groq proxy uzerinden transkripsiyon.
  Future<List<SubtitleCue>?> _transcribeViaProxy(
    Uint8List audioBytes,
    String proxyUrl,
    String secret,
    String language,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(audioBytes, filename: 'audio.ts'),
        'model': 'whisper-large-v3',
        'response_format': 'vtt',
        if (language.isNotEmpty) 'language': language,
      });

      final resp = await _dio.post<String>(
        proxyUrl,
        data: formData,
        options: Options(headers: {'X-Proxy-Secret': secret}),
      );

      return _parseResponse(resp.data);
    } catch (e) {
      debugPrint('[Whisper] proxy failed: $e');
      return null;
    }
  }

  /// OpenAI API dogrudan transkripsiyon.
  Future<List<SubtitleCue>?> _transcribeViaOpenAi(
    Uint8List audioBytes,
    String apiKey,
    String language,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(audioBytes, filename: 'audio.ts'),
        'model': 'whisper-1',
        'response_format': 'vtt',
        if (language.isNotEmpty) 'language': language,
      });

      final resp = await _dio.post<String>(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      return _parseResponse(resp.data);
    } catch (e) {
      debugPrint('[Whisper] OpenAI failed: $e');
      return null;
    }
  }

  /// VTT veya JSON response'u parse et.
  List<SubtitleCue>? _parseResponse(String? body) {
    if (body == null || body.isEmpty) return null;

    // VTT format
    if (body.contains('WEBVTT') || body.contains('-->')) {
      final cues = VttParser.parse(body);
      return cues.isEmpty ? null : cues;
    }

    // JSON format (verbose_json veya proxy wrapper)
    try {
      var json = jsonDecode(body);
      // Proxy wrapper: {"data": {...}} veya {"result": {...}}
      if (json is Map) {
        if (json.containsKey('data')) json = json['data'];
        if (json.containsKey('result')) json = json['result'];
        if (json is Map && json.containsKey('segments')) {
          final segments = json['segments'] as List;
          return segments
              .map((s) => SubtitleCue(
                    startMs: ((s['start'] as num) * 1000).round(),
                    endMs: ((s['end'] as num) * 1000).round(),
                    text: (s['text'] as String).trim(),
                  ))
              .where((c) => c.text.isNotEmpty)
              .toList();
        }
        // Plain text fallback
        if (json is Map && json.containsKey('text')) {
          final text = json['text'] as String;
          if (text.isNotEmpty) {
            return [SubtitleCue(startMs: 0, endMs: 30000, text: text.trim())];
          }
        }
      }
    } catch (_) {}

    return null;
  }

  // ── Cache ──────────────────────────────────────────────────────────────────

  Future<List<SubtitleCue>?> _getFromCache(
      String channelId, int segmentSec) async {
    try {
      final db = await AppDatabase.instance;
      final rows = await db.query(
        _cacheTable,
        where: 'channelId = ? AND segmentSec = ?',
        whereArgs: [channelId, segmentSec],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final json = jsonDecode(rows.first['cuesJson'] as String) as List;
      return json
          .map((j) => SubtitleCue.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(
    String channelId,
    int segmentSec,
    List<SubtitleCue> cues,
    String provider,
  ) async {
    try {
      final db = await AppDatabase.instance;
      await db.insert(
        _cacheTable,
        {
          'id': '${channelId}_$segmentSec',
          'channelId': channelId,
          'segmentSec': segmentSec,
          'cuesJson': jsonEncode(cues.map((c) => c.toJson()).toList()),
          'provider': provider,
          'cachedAt': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Eski kayitlari temizle (max 500)
      await db.execute('''
        DELETE FROM $_cacheTable WHERE id NOT IN
        (SELECT id FROM $_cacheTable ORDER BY cachedAt DESC LIMIT $_maxCacheRows)
      ''');
    } catch (e) {
      debugPrint('[Whisper] cache save failed: $e');
    }
  }
}
