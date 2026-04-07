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

  /// EPG senkronizasyonu.
  ///
  /// Fetch/parse basarisiz olursa ESKI EPG verisi korunur. Bu sayede
  /// provider yoğun oldugunda kullanici hala (eski de olsa) program
  /// bilgisi gorur; UI bos kalmaz.
  Future<void> syncEpg(String playlistId) async {
    final url = await _ref
        .read(settingsRepoProvider)
        .get(SettingsKeys.epgUrl);

    if (url == null || url.isEmpty) {
      throw Exception('EPG URL ayarlanmamış. Ayarlar → EPG bölümünden giriniz.');
    }

    final repo = _ref.read(epgRepoProvider);

    // Once fetch+parse yap. Bu adim fail olursa DB'ye dokunma.
    final result = await EpgParser.fetchAndParse(url, playlistId);

    // Fetch basarili → eski veriyi sil, yenisini yaz.
    await repo.deleteByPlaylist(playlistId);
    await repo.bulkInsertChannels(result.channels);
    await repo.bulkInsertProgrammes(result.programmes);
  }
}
