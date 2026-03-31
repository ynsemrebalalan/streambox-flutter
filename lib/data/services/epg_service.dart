import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../data/repositories/settings_repository.dart';
import 'epg_parser.dart';

final epgServiceProvider = Provider<EpgService>(
  (ref) => EpgService(ref),
);

class EpgService {
  final Ref _ref;
  EpgService(this._ref);

  Future<void> syncEpg(String playlistId) async {
    final url = await _ref
        .read(settingsRepoProvider)
        .get(SettingsKeys.epgUrl);

    if (url == null || url.isEmpty) {
      throw Exception('EPG URL ayarlanmamış. Ayarlar → EPG bölümünden giriniz.');
    }

    final repo   = _ref.read(epgRepoProvider);
    final result = await EpgParser.fetchAndParse(url, playlistId);

    // Clear old data and insert fresh
    await repo.deleteByPlaylist(playlistId);
    await repo.bulkInsertChannels(result.channels);
    await repo.bulkInsertProgrammes(result.programmes);
  }
}
