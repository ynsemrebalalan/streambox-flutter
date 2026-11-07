import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/models/channel_model.dart';
import '../../../data/repositories/settings_repository.dart';
import '../logic/playback_policy.dart';
import '../logic/subtitle_style.dart';
import '../logic/track_prefs.dart';

/// Oynatıcı açılırken tek seferde okunan ayarlar.
class PlayerPrefs {
  final SubtitleStyleSettings subtitleStyle;
  final bool subtitleDefaultOn;
  final String aiTargetPref; // '' = cihaz dili
  final bool aiBannerEnabled;
  final String aiProvider; // 'groq' | 'openai'
  final int bufferMs;
  final String userAgent;

  const PlayerPrefs({
    this.subtitleStyle = const SubtitleStyleSettings(),
    this.subtitleDefaultOn = false,
    this.aiTargetPref = '',
    this.aiBannerEnabled = true,
    this.aiProvider = 'groq',
    this.bufferMs = kBufferMsDefault,
    this.userAgent = 'StreamBox/1.0 (iOS)',
  });

  static Future<PlayerPrefs> load() async {
    final all = await SettingsRepository().getAll();
    var version = '1.0';
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return PlayerPrefs(
      subtitleStyle: SubtitleStyleSettings.fromRaw(
        fontSize: all[SettingsKeys.subtitleFontSize],
        textColor: all[SettingsKeys.subtitleTextColor],
        bgColor: all[SettingsKeys.subtitleBgColor],
      ),
      subtitleDefaultOn: all[SettingsKeys.subtitleDefaultOn] == 'true',
      aiTargetPref: all[SettingsKeys.aiTargetLang] ?? '',
      aiBannerEnabled: all[SettingsKeys.aiBannerEnabled] != 'false',
      aiProvider: all[SettingsKeys.aiProvider] ?? 'groq',
      bufferMs: int.tryParse(all[SettingsKeys.playerBufferMs] ?? '') ?? kBufferMsDefault,
      userAgent: playbackUserAgent(version),
    );
  }
}

/// Ses/altyazı dil tercihlerini settings tablosunda saklar (bölüm + dizi anahtarı).
class TrackPrefStore {
  final SettingsRepository _repo;
  TrackPrefStore([SettingsRepository? repo]) : _repo = repo ?? SettingsRepository();

  Future<TrackPrefs?> load(ChannelModel ch) async {
    final ep = episodeTrackKey(ch);
    if (ep == null) return null;
    final series = seriesTrackKey(ch);
    final store = <String, String>{};
    for (final k in [ep, if (series != null) series]) {
      for (final key in [TrackPrefKeys.audio(k), TrackPrefKeys.subLang(k), TrackPrefKeys.subOn(k)]) {
        final v = await _repo.get(key);
        if (v != null) store[key] = v;
      }
    }
    return resolveTrackPrefs(store, episodeKey: ep, seriesKey: series);
  }

  Future<void> saveAudio(ChannelModel ch, String? lang) async {
    if (lang == null || lang.isEmpty) return;
    for (final k in _keys(ch)) {
      await _repo.set(TrackPrefKeys.audio(k), lang);
    }
  }

  Future<void> saveSubtitle(ChannelModel ch, {required bool enabled, String? lang}) async {
    for (final k in _keys(ch)) {
      await _repo.set(TrackPrefKeys.subOn(k), enabled ? 'true' : 'false');
      if (enabled && lang != null && lang.isNotEmpty) {
        await _repo.set(TrackPrefKeys.subLang(k), lang);
      }
    }
  }

  List<String> _keys(ChannelModel ch) => [
        for (final k in [episodeTrackKey(ch), seriesTrackKey(ch)])
          if (k != null) k,
      ];
}
