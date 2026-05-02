import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/epg_service.dart';
import '../billing/providers/purchases_providers.dart';

/// Pro: EPG'yi seçilen aralıkta (6/12/24 saat) arka planda otomatik
/// yeniler. App foreground'a döndüğünde son fetch + interval kontrolü
/// yapılır, gerekiyorsa fetch tetiklenir.
///
/// Free user: setting ekranında "Pro gerekli" badge ile görünür,
/// devre dışı.
class EpgAutoRefreshController extends Notifier<int> {
  /// State: kayıtlı interval saat. 0 = kapalı.
  @override
  int build() => 0;

  Future<void> loadFromDb() async {
    final raw = await ref
        .read(settingsRepoProvider)
        .get(SettingsKeys.epgAutoRefreshHours);
    state = int.tryParse(raw ?? '0') ?? 0;
  }

  Future<void> setInterval(int hours) async {
    state = hours;
    await ref
        .read(settingsRepoProvider)
        .set(SettingsKeys.epgAutoRefreshHours, hours.toString());
  }

  /// App foreground'a döndüğünde çağrılır. Pro değilse no-op.
  /// Interval = 0 → no-op. Son fetch'ten beri interval geçmediyse no-op.
  Future<void> maybeRefresh() async {
    final isPro = ref.read(isProProvider);
    if (!isPro) return;
    if (state == 0) return;

    final activeId = ref.read(activePlaylistProvider);
    if (activeId.isEmpty) return;

    final settings = ref.read(settingsRepoProvider);
    final lastRaw  = await settings.get(SettingsKeys.epgLastAutoFetchMs);
    final lastMs   = int.tryParse(lastRaw ?? '0') ?? 0;
    final nowMs    = DateTime.now().millisecondsSinceEpoch;
    final intervalMs = state * 3600 * 1000;
    if (nowMs - lastMs < intervalMs) return; // Henüz interval dolmadı.

    try {
      await ref.read(epgServiceProvider).syncEpg(activeId);
      await settings.set(
          SettingsKeys.epgLastAutoFetchMs, nowMs.toString());
    } catch (e) {
      debugPrint('[EpgAutoRefresh] failed: $e');
    }
  }
}

final epgAutoRefreshProvider =
    NotifierProvider<EpgAutoRefreshController, int>(
  EpgAutoRefreshController.new,
);
