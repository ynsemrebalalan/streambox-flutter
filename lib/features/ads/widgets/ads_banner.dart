import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../billing/providers/purchases_providers.dart';
import '../ads_service.dart';

/// Reusable AdMob banner. Pro user'da SizedBox.shrink() (hicbir reklam
/// yuklenmez, network/ram tuketmez).
///
/// Kullanim:
///   ```dart
///   const AdsBanner()
///   ```
/// Genelde HomeScreen'in alt safe area icine, Scaffold.bottomNavigationBar
/// gibi bir slot'a yerlestirilir.
class AdsBanner extends ConsumerStatefulWidget {
  const AdsBanner({super.key});

  @override
  ConsumerState<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends ConsumerState<AdsBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    // Web'de kapali, kIsWeb early-return.
    if (kIsWeb) return;
    // Pro check — initState anindaki snapshot. Pro/Free toggle olunca widget
    // rebuild olmasa bile reklam yuklenmis olabilir; build() guncel kontrol
    // yapar ve gostermez. Pro user'a gercekten dusen Pro'luk yine reklam
    // yuklenmesini onler.
    final isPro = ref.read(isProProvider);
    if (isPro) return;

    await AdsService.instance.ensureInitialized();
    if (!AdsService.instance.isReady || !mounted) return;

    final ad = BannerAd(
      adUnitId: AdsService.instance.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('[Ads] banner load failed: $err');
          ad.dispose();
        },
      ),
    );
    await ad.load();
    if (mounted) {
      _ad = ad;
    } else {
      ad.dispose();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pro user'a hic gostermez (her rebuild'de en son durum).
    final isPro = ref.watch(isProProvider);
    if (isPro) return const SizedBox.shrink();
    if (!_loaded || _ad == null) {
      // Yuklenirken alanı koru — UI'in zıplamamasi icin sabit yukseklik.
      return const SizedBox(height: 50);
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
