import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/utils/build_config.dart';
import 'entitlement.dart';

/// RevenueCat SDK ince wrapper'ı. Tüm UI bunu doğrudan kullanmaz;
/// `purchasesNotifierProvider` üzerinden tüketir.
///
/// Singleton — uygulama yaşam döngüsü boyunca tek instance. Init
/// `main.dart` `_bootstrapInBackground` içinde tek defa çağrılır.
class PurchasesService {
  PurchasesService._();
  static final PurchasesService instance = PurchasesService._();

  /// RevenueCat'te tanımlı entitlement adı (Dashboard ile aynı).
  static const String entitlementId = 'pro';

  bool _configured = false;
  StreamController<CustomerInfo>? _controller;

  /// `configure` çağrılmış mı? `entitlementProvider` cached false döner
  /// configure edilmediyse — initialization race'i önler.
  bool get isConfigured => _configured;

  // ── Configure ──────────────────────────────────────────────────────────────

  /// Uygulama başlangıcında bir kez çağırılır. [appUserID] anon Firebase UID
  /// olabilir; auth state değişince [logIn]/[logOut] tetiklenir.
  Future<void> configure({String? appUserID}) async {
    if (_configured) return;

    final apiKey = Platform.isIOS
        ? BuildConfig.revenueCatIosKey
        : BuildConfig.revenueCatAndroidKey;

    if (apiKey.isEmpty) {
      // RC dashboard config tamamlanmadı; SDK init'i atla. UI Entitlement.free
      // ile devam eder, paywall'a basınca "satın alma yapılandırılmadı" hatası
      // veririz.
      debugPrint('[Purchases] API key boş — RC configure atlandı.');
      return;
    }

    await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.warn : LogLevel.info);

    final config = PurchasesConfiguration(apiKey);
    if (appUserID != null && appUserID.isNotEmpty) {
      config.appUserID = appUserID;
    }
    await Purchases.configure(config);

    _controller = StreamController<CustomerInfo>.broadcast(
      onCancel: () {
        // No-op — listener removal RC SDK tarafında.
      },
    );

    Purchases.addCustomerInfoUpdateListener((info) {
      _controller?.add(info);
    });

    _configured = true;
  }

  // ── Auth bridge ────────────────────────────────────────────────────────────

  /// Firebase user değişti — RC'yi de o user'a geçir.
  /// [uid] anon olsa bile aynı UID'yi vermek RC alias'ı tutarlı tutar.
  Future<void> logIn(String uid) async {
    if (!_configured) return;
    try {
      await Purchases.logIn(uid);
    } catch (e) {
      debugPrint('[Purchases] logIn fail: $e');
    }
  }

  Future<void> logOut() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      // RC anon user'da logOut throw edebilir — kabul edilebilir.
      debugPrint('[Purchases] logOut: $e');
    }
  }

  // ── State ──────────────────────────────────────────────────────────────────

  Stream<CustomerInfo> customerInfoStream() {
    return _controller?.stream ?? const Stream.empty();
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_configured) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[Purchases] getCustomerInfo: $e');
      return null;
    }
  }

  // ── Offerings & Purchase ───────────────────────────────────────────────────

  Future<Offerings?> getOfferings() async {
    if (!_configured) return null;
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchasePackage(Package pkg) async {
    final result = await Purchases.purchase(PurchaseParams.package(pkg));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }

  // ── Entitlement parser ─────────────────────────────────────────────────────

  /// CustomerInfo → Entitlement. UI sadece Entitlement görür.
  Entitlement parseEntitlement(CustomerInfo? info) {
    if (info == null) return Entitlement.free;
    final ent = info.entitlements.active[entitlementId];
    if (ent == null) return Entitlement.free;

    final source = switch (ent.store) {
      Store.appStore => EntitlementSource.appStore,
      Store.playStore => EntitlementSource.playStore,
      Store.promotional => EntitlementSource.promotional,
      _ => EntitlementSource.unknown,
    };
    DateTime? expires;
    if (ent.expirationDate != null && ent.expirationDate!.isNotEmpty) {
      expires = DateTime.tryParse(ent.expirationDate!);
    }
    return Entitlement(
      isPro: ent.isActive,
      productId: ent.productIdentifier,
      expiresAt: expires,
      source: source,
    );
  }
}
