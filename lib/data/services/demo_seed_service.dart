import 'package:flutter/foundation.dart';
import '../models/channel_model.dart';
import '../models/playlist_model.dart';
import '../repositories/channel_repository.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/settings_repository.dart';

/// Ilk launch'ta bundled CC/public-domain demo streamlerini seed eder.
///
/// Apple App Review icin 4.2.2 Minimum Functionality guvencesi:
/// Kullanici kendi playlist'ini eklemeden once uygulama "calisir durumda"
/// gorunur. Tum streamler Creative Commons veya public domain lisansli.
///
/// Kaynaklar:
/// - Big Buck Bunny, Sintel, Tears of Steel: Blender Foundation (CC-BY)
/// - Mux test streams: developer documentation content
/// - NASA TV: ABD federal hukumetine ait icerik (public domain)
class DemoSeedService {
  static const String demoPlaylistId = 'demo_playlist_builtin';
  static const String _seededKey = 'demo_seeded_v1';

  static final List<ChannelModel> _demoChannels = [
    // ── Canli (public feeds / CC) ──────────────────────────────────────────
    ChannelModel(
      id: 'demo_live_mux_low',
      playlistId: demoPlaylistId,
      name: 'Mux Test — Low Latency HLS',
      streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
      category: 'Demo - Canli',
      streamType: 'live',
      logoUrl: '',
      sortOrder: 1,
    ),
    ChannelModel(
      id: 'demo_live_mux_basic',
      playlistId: demoPlaylistId,
      name: 'Mux Test — Adaptive Bitrate',
      streamUrl: 'https://test-streams.mux.dev/test_001/stream.m3u8',
      category: 'Demo - Canli',
      streamType: 'live',
      sortOrder: 2,
    ),

    // ── Film (CC-BY / public domain) ───────────────────────────────────────
    ChannelModel(
      id: 'demo_movie_bbb',
      playlistId: demoPlaylistId,
      name: 'Big Buck Bunny (CC-BY)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      logoUrl:
          'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217',
      category: 'Demo - Film',
      streamType: 'movie',
      sortOrder: 10,
    ),
    ChannelModel(
      id: 'demo_movie_sintel',
      playlistId: demoPlaylistId,
      name: 'Sintel (CC-BY)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      logoUrl: 'https://durian.blender.org/wp-content/uploads/2010/06/05.1.lq_.jpg',
      category: 'Demo - Film',
      streamType: 'movie',
      sortOrder: 11,
    ),
    ChannelModel(
      id: 'demo_movie_tears',
      playlistId: demoPlaylistId,
      name: 'Tears of Steel (CC-BY)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      logoUrl:
          'https://mango.blender.org/wp-content/uploads/2013/05/Celia-1024x4501.jpg',
      category: 'Demo - Film',
      streamType: 'movie',
      sortOrder: 12,
    ),
    ChannelModel(
      id: 'demo_movie_elephant',
      playlistId: demoPlaylistId,
      name: 'Elephants Dream (CC-BY)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      category: 'Demo - Film',
      streamType: 'movie',
      sortOrder: 13,
    ),

    // ── Dizi (CC short films) ──────────────────────────────────────────────
    ChannelModel(
      id: 'demo_series_s1e1',
      playlistId: demoPlaylistId,
      name: 'Demo Series — S01E01 (For Bigger Blazes)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      category: 'Demo - Dizi',
      streamType: 'series',
      seriesName: 'Demo Series',
      seasonNumber: 1,
      episodeNumber: 1,
      sortOrder: 20,
    ),
    ChannelModel(
      id: 'demo_series_s1e2',
      playlistId: demoPlaylistId,
      name: 'Demo Series — S01E02 (For Bigger Escape)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      category: 'Demo - Dizi',
      streamType: 'series',
      seriesName: 'Demo Series',
      seasonNumber: 1,
      episodeNumber: 2,
      sortOrder: 21,
    ),
    ChannelModel(
      id: 'demo_series_s1e3',
      playlistId: demoPlaylistId,
      name: 'Demo Series — S01E03 (For Bigger Joyrides)',
      streamUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      category: 'Demo - Dizi',
      streamType: 'series',
      seriesName: 'Demo Series',
      seasonNumber: 1,
      episodeNumber: 3,
      sortOrder: 22,
    ),
  ];

  /// Seed'i idempotent şekilde çalıştır.
  /// - [forceReseed] true ise varolan demo playlist'i silip tekrar yazar.
  /// - Zaten seed edildiyse NO-OP.
  static Future<void> seedIfNeeded({bool forceReseed = false}) async {
    try {
      final settings = SettingsRepository();
      final already = await settings.get(_seededKey);
      if (already == 'true' && !forceReseed) return;

      final playlistRepo = PlaylistRepository();
      final channelRepo = ChannelRepository();

      // Demo playlist entry
      final existing = await playlistRepo.getById(demoPlaylistId);
      if (existing == null || forceReseed) {
        await playlistRepo.insert(PlaylistModel(
          id: demoPlaylistId,
          name: 'Demo Content (CC-Lisansli)',
          type: 'm3u',
          url: 'builtin://demo',
          addedAt: DateTime.now().millisecondsSinceEpoch,
          allowedTypes: 'live,movie,series',
        ));
      }

      await channelRepo.replaceAllForPlaylist(demoPlaylistId, _demoChannels);
      await settings.set(_seededKey, 'true');

      // Aktif playlist henuz yoksa demo'yu aktive et
      final activeId = await settings.get(SettingsKeys.activePlaylistId);
      if (activeId == null || activeId.isEmpty) {
        await settings.set(SettingsKeys.activePlaylistId, demoPlaylistId);
      }
    } catch (e) {
      debugPrint('[DemoSeed] seed failed: $e');
    }
  }
}
