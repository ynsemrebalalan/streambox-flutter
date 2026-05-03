import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob servis singleton.
///
/// Free tier kullanicilarina HomeScreen + Settings altinda 1 banner reklam
/// gosterilir. Pro user'da hicbir reklam yuklenmez (AdsBanner widget'i
/// SizedBox.shrink() doner).
///
/// Test ID'ler: https://developers.google.com/admob/android/test-ads
/// Production'a gecisten once `BuildConfig.admobBannerId` ile override edilir.
///
/// Init:
///   - main.dart'ta runApp sonrasi background'da MobileAds.instance.initialize()
///   - Pro user'da bile init yapilir (kullanici Pro'dan dusebilir, instant
///     reklam gostermesi gerekebilir; init agirsa tekrar init istemez).
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;
  bool _initFailed = false;

  /// Test banner ad unit IDs.
  /// - Android: ca-app-pub-3940256099942544/6300978111
  /// - iOS:     ca-app-pub-3940256099942544/2934735716
  ///
  /// Production'da BuildConfig'ten override edilir (build_config.dart).
  String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  Future<void> ensureInitialized() async {
    if (_initialized || _initFailed) return;
    if (kIsWeb) {
      _initFailed = true;
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('[Ads] AdMob initialized.');
    } catch (e) {
      _initFailed = true;
      debugPrint('[Ads] init failed: $e');
    }
  }

  bool get isReady => _initialized;
}
