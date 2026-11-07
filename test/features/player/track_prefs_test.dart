import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/models/channel_model.dart';
import 'package:iptv_ai_player/features/player/logic/track_prefs.dart';

ChannelModel ch({String type = 'series', String url = 'http://x/1.mkv', String series = 'Show'}) =>
    ChannelModel(
      id: 'id',
      playlistId: 'pl',
      name: 'n',
      streamUrl: url,
      streamType: type,
      seriesName: series,
    );

void main() {
  group('keys', () {
    test('stable hash (not Object.hashCode) and deterministic', () {
      expect(stableHash('abc'), stableHash('abc'));
      expect(stableHash('abc'), isNot(stableHash('abd')));
      // FNV-1a 32 bit of "abc" = 0x1a47e90b
      expect(stableHash('abc'), '1a47e90b');
    });
    test('episode key depends on playlist + url; null for live', () {
      expect(episodeTrackKey(ch()), 'pl_${stableHash('http://x/1.mkv')}');
      expect(episodeTrackKey(ch(type: 'live')), isNull);
      expect(episodeTrackKey(ch(url: '')), isNull);
    });
    test('series key only for series with a name', () {
      expect(seriesTrackKey(ch()), 'pl_series_${stableHash('Show')}');
      expect(seriesTrackKey(ch(type: 'movie')), isNull);
      expect(seriesTrackKey(ch(series: '')), isNull);
    });
  });

  group('resolveTrackPrefs', () {
    test('episode audio wins, series audio as fallback', () {
      final store = {
        TrackPrefKeys.audio('ep'): 'eng',
        TrackPrefKeys.audio('se'): 'tur',
      };
      expect(resolveTrackPrefs(store, episodeKey: 'ep', seriesKey: 'se').audioLang, 'eng');
      expect(resolveTrackPrefs({TrackPrefKeys.audio('se'): 'tur'},
              episodeKey: 'ep', seriesKey: 'se')
          .audioLang, 'tur');
    });

    test('episode subtitle decision wins when it exists', () {
      final store = {
        TrackPrefKeys.subOn('ep'): 'false',
        TrackPrefKeys.subOn('se'): 'true',
        TrackPrefKeys.subLang('se'): 'tur',
      };
      final p = resolveTrackPrefs(store, episodeKey: 'ep', seriesKey: 'se');
      expect(p.subtitleEnabled, isFalse);
    });

    test('series subtitle is carried to new episode', () {
      final store = {
        TrackPrefKeys.subOn('se'): 'true',
        TrackPrefKeys.subLang('se'): 'tur',
      };
      final p = resolveTrackPrefs(store, episodeKey: 'ep2', seriesKey: 'se');
      expect(p.subtitleEnabled, isTrue);
      expect(p.subtitleLang, 'tur');
    });

    test('nothing saved → null decision', () {
      final p = resolveTrackPrefs({}, episodeKey: 'ep', seriesKey: null);
      expect(p.audioLang, isNull);
      expect(p.subtitleEnabled, isNull);
    });
  });

  group('pickByLanguage', () {
    test('case-insensitive match, null when absent', () {
      final langs = ['eng', 'TUR', null];
      expect(pickByLanguage<String?>(langs, (s) => s, 'tur'), 'TUR');
      expect(pickByLanguage<String?>(langs, (s) => s, 'ger'), isNull);
      expect(pickByLanguage<String?>(langs, (s) => s, ''), isNull);
    });
  });
}
