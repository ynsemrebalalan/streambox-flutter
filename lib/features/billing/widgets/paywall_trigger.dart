import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/device_tier.dart';
import '../../../data/models/playlist_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../playlists/playlists_provider.dart';
import '../logic/playlist_limit.dart';
import '../providers/purchases_providers.dart';

/// Bir feature'a girmeden önce kullanıcının Pro olup olmadığını kontrol et.
/// Akış (Android paritesi):
///   1. Pro ise true döner (özellik açık).
///   2. Değilse RC'den ~2 sn içinde taze durum çekilir — açılışta RC geç
///      kalınca Pro kullanıcı yanlışlıkla paywall'a düşmesin. Downgrade
///      koruması [PurchasesNotifier] içinde (boş CustomerInfo + önceden Pro).
///   3. Hâlâ free ise paywall DOĞRUDAN açılır. **Login zorunlu değil:** anonim
///      Firebase UID ile satın alınır (RC App User ID = Firebase UID); kullanıcı
///      sonra giriş yaparsa anon hesap `linkWithCredential` ile aynı UID'de
///      kalıcıya dönüşür → satın alma hesapla gelir. Giriş paywall'dan
///      bağımsız olarak Ayarlar'da isteğe bağlı.
///   4. Satın alma başarılı → true; iptal → false.
///
/// ```dart
/// final ok = await requirePro(context, ref, PaywallTrigger.aiSubtitle);
/// if (ok) startAiSubtitle();
/// ```
Future<bool> requirePro(
  BuildContext context,
  WidgetRef ref,
  PaywallTrigger trigger,
) async {
  if (ref.read(isProProvider)) return true;

  final refreshed =
      await ref.read(purchasesNotifierProvider.notifier).refreshPro();
  if (refreshed || ref.read(isProProvider)) return true;
  if (!context.mounted) return false;

  final purchased = await context.push<bool>(
    AppRoutes.paywall,
    extra: <String, dynamic>{'trigger': trigger.name},
  );
  return (purchased ?? false) || ref.read(isProProvider);
}

/// İzleme listesine EKLEME Pro (Android); çıkarma her zaman serbest.
/// Player dışı giriş noktaları (kanal satırı, detay vb.) bunu çağırmalı:
/// ```dart
/// if (!isInWatchlist && !await ensureWatchlistAddAllowed(context, ref)) return;
/// ```
Future<bool> ensureWatchlistAddAllowed(BuildContext context, WidgetRef ref) =>
    requirePro(context, ref, PaywallTrigger.watchlist);

/// Playlist ekleme kapısı — Android `HomeViewModel.maxPlaylistCount`
/// (Free 1/2/5, Pro 2/5/20 cihaz RAM katmanına göre).
///   - limit altı → true
///   - free limitte ama Pro daha fazlasına izin veriyor → paywall
///   - cihaz limiti (Pro dahil) dolu → snackbar, false
Future<bool> ensurePlaylistAddAllowed(BuildContext context, WidgetRef ref) async {
  final List<PlaylistModel> existing =
      ref.read(playlistsProvider).valueOrNull ??
          await ref.read(playlistsProvider.future);
  final count = existing.length;
  var isPro = ref.read(isProProvider);
  if (!isPro && !canAddPlaylist(
      existingCount: count, isPro: false, tier: DeviceProfile.tier)) {
    isPro = await ref.read(purchasesNotifierProvider.notifier).refreshPro();
  }
  final decision = decidePlaylistAdd(
      existingCount: count, isPro: isPro, tier: DeviceProfile.tier);
  switch (decision) {
    case PlaylistAddDecision.allowed:
      return true;
    case PlaylistAddDecision.needsPro:
      if (!context.mounted) return false;
      final ok = await requirePro(context, ref, PaywallTrigger.secondPlaylist);
      if (!ok) return false;
      return canAddPlaylist(
          existingCount: count, isPro: true, tier: DeviceProfile.tier);
    case PlaylistAddDecision.deviceLimit:
      if (context.mounted) {
        final limit = playlistLimitFor(isPro: isPro, tier: DeviceProfile.tier);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context).playlistDeviceLimit(limit))));
      }
      return false;
  }
}

/// Hangi noktadan paywall açıldı? Analytics + paywall copy variant için.
enum PaywallTrigger {
  secondPlaylist,
  aiSubtitle,
  cloudSync,
  tvApp,
  settingsCta,
  parentalLock,    // Phase 1: ebeveyn kilidi
  premiumTheme,    // Phase 1: özel temalar
  watchlist,       // İzleme listesine ekleme (Android: Pro)
  epg,             // Phase 3: TV rehberi otomatik fetch
  pip,             // Phase 4: Picture-in-Picture (yalnizca Android)
  // 2026-08-29: ARTIK KULLANILMIYOR. AirPlay bu oynaticida yalnizca SES
  // yonlendirmesi yapabiliyor (media_kit texture render → AVPlayerLayer yok),
  // sistem ses cikisi ise ucretli bir ozellik degil. Enum degeri gecmis
  // analytics kayitlariyla uyum icin birakildi; yeni kullanim EKLEME.
  airplay,
  multiProfile,    // Phase 6: çoklu profil
  // 2026-08-29: ARTIK KULLANILMIYOR. AdMob uygulamadan cikarildi, reklam
  // diye bir sey kalmadigi icin "reklamsiz" bir Pro faydasi da yok.
  // Enum degeri gecmis analytics kayitlariyla uyum icin birakildi.
  noAds,
}
