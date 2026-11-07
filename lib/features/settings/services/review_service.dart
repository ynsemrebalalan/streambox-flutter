import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../core/analytics/analytics.dart';
import '../../../data/repositories/settings_repository.dart';
import '../logic/review_policy.dart';

/// App Store kaydi (in_app_review `openStoreListing` icin zorunlu).
/// Kaynak: Site/src/data/apps.ts → apps.apple.com/us/app/iptv-ai-player/id6761446401
const appStoreId = '6761446401';

/// Basarili oynatma sayaci + ilk oynatma analytics + Android `ReviewHelper`
/// esikleriyle (5 oynatma, 90 gun) App Store degerlendirme istegi.
abstract final class PlaybackMilestones {
  static const _countKey = 'successful_playback_count';
  static const _firstPlaybackKey = 'first_playback_logged';
  static const _reviewShownKey = 'review_last_shown_ms';

  /// Oynatici gercekten oynatmaya basladiginda (ilk ilerleme) bir kez cagrilir.
  static Future<void> onPlaybackStarted({required String streamType}) async {
    try {
      final repo = SettingsRepository();
      final count = int.tryParse(await repo.get(_countKey) ?? '') ?? 0;
      await repo.set(_countKey, '${count + 1}');
      if (await repo.get(_firstPlaybackKey) != 'true') {
        await repo.set(_firstPlaybackKey, 'true');
        Analytics.firstPlayback(streamType: streamType);
      }
    } catch (e) {
      debugPrint('[Review] playback milestone failed: $e');
    }
  }

  /// Oynaticidan cikista cagrilir — izleme sirasinda dialog acmayiz.
  /// Apple kota uygular (yilda en fazla 3); biz de 90 gunde bir deneriz.
  static Future<void> maybeRequestReview() async {
    try {
      final repo = SettingsRepository();
      final count = int.tryParse(await repo.get(_countKey) ?? '') ?? 0;
      final last = int.tryParse(await repo.get(_reviewShownKey) ?? '') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (!shouldRequestReview(
          successfulPlaybacks: count, lastShownMs: last, nowMs: now)) {
        return;
      }
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      // Gosterilip gosterilmedigini Apple bildirmiyor — her durumda damgala.
      await repo.set(_reviewShownKey, '$now');
      await review.requestReview();
    } catch (e) {
      debugPrint('[Review] request failed: $e');
    }
  }

  /// Ayarlar > "Uygulamayi degerlendir": App Store sayfasini ac.
  static Future<void> openStoreListing() async {
    try {
      await InAppReview.instance.openStoreListing(appStoreId: appStoreId);
    } catch (e) {
      debugPrint('[Review] openStoreListing failed: $e');
    }
  }
}
