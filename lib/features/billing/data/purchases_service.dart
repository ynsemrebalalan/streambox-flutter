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
///
/// ## 2026-08-29 — "Pro kullanıcı her açılışta free görünüyor" fix
///
/// Üç ayrı race birleşince Pro kullanıcı her cold start'ta free görünüyor,
/// ancak "satın alımları geri yükle"den sonra düzeliyordu:
///
/// 1. `_controller` SADECE `configure()` içinde oluşturuluyordu. Provider
///    configure'dan önce (ki her zaman öyle — configure Firebase + MediaKit
///    + secret migration'ın arkasında) `customerInfoStream()` çağırınca
///    `const Stream.empty()` alıyordu → ÖLÜ subscription; RC hazır olunca
///    gelen entitlement'ı kimse duymuyordu.
/// 2. `logIn(uid)` / `logOut()` `!_configured` iken SESSİZCE düşüyordu.
///    Firebase auth RC'den önce hazır olduğu için kullanıcı kimliği RC'ye
///    hiç bildirilmiyor, SDK anonim user'da kalıyordu.
/// 3. `main.dart` auth listener'ı `AuthLoading` (uid == null) emit'inde
///    `logOut()` çağırıyordu → RC entitlement'lı user'ı bırakıp YENİ anonim
///    ID üretiyordu → Pro kayboluyordu.
///
/// Çözüm: stream configure'dan bağımsız ve kalıcı; kimlik işlemleri
/// configure'a kadar kuyruklanır; son `CustomerInfo` bellekte tutulur.
class PurchasesService {
  PurchasesService._();
  static final PurchasesService instance = PurchasesService._();

  /// RevenueCat'te tanımlı entitlement adı (Dashboard ile aynı).
  static const String entitlementId = 'pro';

  bool _configured = false;

  /// Devam eden configure future'i — lazy retry'lar ayni future'i bekler.
  Future<void>? _configureInFlight;

  /// Kalıcı broadcast kanalı. **configure'dan ÖNCE** oluşturulur; dinleyici
  /// RC hazır olmadan subscribe olsa bile sonraki emit'leri alır.
  final StreamController<CustomerInfo> _controller =
      StreamController<CustomerInfo>.broadcast();

  /// RC'den gelen en son CustomerInfo. Geç subscribe olan dinleyici bunu
  /// senkron okuyabilir (stream replay yerine — replay'de subscribe/emit
  /// arası mikro-görev boşluğu event kaybettirebiliyor).
  CustomerInfo? _latestInfo;
  CustomerInfo? get latestInfo => _latestInfo;

  /// configure tamamlanmadan gelen kimlik işlemleri burada bekler.
  String? _pendingAppUserId;
  bool _pendingLogOut = false;

  /// `configure` çağrılmış mı? `entitlementProvider` cached false döner
  /// configure edilmediyse — initialization race'i önler.
  bool get isConfigured => _configured;

  /// Paywall acildigi anda cagrilir — RC SDK init olmamissa veya basarisiz
  /// olmussa yeniden dener. Apple review cihazlarinda main.dart init 30sn
  /// timeout'a girerse, kullanici paywall'a basinca burdan retry alir.
  ///
  /// Apple Reject 3 (2026-05-25) fix.
  Future<void> ensureConfigured({String? appUserID}) => configure(
        appUserID: appUserID,
      );

  // ── Configure ──────────────────────────────────────────────────────────────

  /// Uygulama başlangıcında bir kez çağırılır. [appUserID] anon Firebase UID
  /// olabilir; auth state değişince [logIn]/[logOut] tetiklenir.
  ///
  /// [appUserID] VERİLMEZSE RC SDK cihazda cache'lediği son app user ID'yi
  /// (önceki oturumun Firebase UID'si veya anonim ID) geri yükler. Bu
  /// bilinçli: mevcut kurulumlarda satın alma anonim ID'de duruyor olabilir;
  /// sonradan gelen [logIn] RC identity alias'ı ile onu Firebase UID'ye
  /// taşır. Doğrudan `configure(appUserID: uid)` deseydik o alias hiç
  /// oluşmaz, eski satın alma "restore" yapılana kadar görünmezdi.
  ///
  /// Tekrar tekrar çağrılabilir: aynı anda birden fazla çağrı gelirse hepsi
  /// TEK `_configureInFlight` future'ını bekler (main.dart bootstrap ile
  /// provider'ın lazy retry'ı çakışıp `Purchases.configure`'u iki kez
  /// çağırmasın diye).
  Future<void> configure({String? appUserID}) {
    if (_configured) return Future.value();
    final inFlight = _configureInFlight;
    if (inFlight != null) return inFlight;
    final f = _configure(appUserID: appUserID).whenComplete(() {
      _configureInFlight = null;
    });
    _configureInFlight = f;
    return f;
  }

  Future<void> _configure({String? appUserID}) async {
    if (_configured) return;

    final apiKey = Platform.isIOS
        ? BuildConfig.revenueCatIosKey
        : BuildConfig.revenueCatAndroidKey;

    if (apiKey.isEmpty) {
      // RC dashboard config tamamlanmadı; SDK init'i atla. UI Entitlement.free
      // ile devam eder, paywall'a basınca "satın alma yapılandırılmadı" hatası
      // veririz.
      debugPrint('[Purchases] API key bos — RC configure atlandi.');
      return;
    }

    await Purchases.setLogLevel(
        kReleaseMode ? LogLevel.warn : LogLevel.info);

    // Listener'ı configure'dan ÖNCE bağla: SDK ilk CustomerInfo'yu configure
    // sırasında yayınlıyor; sonradan bağlanınca o ilk emit kaçıyordu.
    // (`addCustomerInfoUpdateListener` native'e dokunmaz; Dart tarafında
    // listener listesine ekler ve varsa son bilinen info'yu hemen verir.)
    Purchases.addCustomerInfoUpdateListener(_emit);

    final config = PurchasesConfiguration(apiKey);
    if (appUserID != null && appUserID.isNotEmpty) {
      config.appUserID = appUserID;
    }
    await Purchases.configure(config);

    _configured = true;

    // configure beklerken biriken logIn/logOut'u şimdi uygula.
    await _flushPendingIdentity();

    // Cache'lenmiş CustomerInfo'yu hemen çek — listener emit etmemiş olabilir.
    await refresh();
  }

  // ── Auth bridge ────────────────────────────────────────────────────────────

  /// Firebase user değişti — RC'yi de o user'a geçir.
  /// [uid] anon olsa bile aynı UID'yi vermek RC alias'ı tutarlı tutar.
  ///
  /// RC henüz configure edilmediyse istek KUYRUĞA alınır (eskiden sessizce
  /// düşüyordu — Pro kullanıcının anonim RC user'da kalmasının ana sebebi).
  Future<void> logIn(String uid) async {
    if (uid.isEmpty) return;
    if (!_configured) {
      _pendingAppUserId = uid;
      _pendingLogOut = false;
      debugPrint('[Purchases] logIn kuyruga alindi (RC henuz configure degil)');
      return;
    }
    try {
      final result = await Purchases.logIn(uid);
      _emit(result.customerInfo);
    } catch (e) {
      debugPrint('[Purchases] logIn fail: $e');
    }
  }

  /// SADECE kullanıcı gerçekten hesabından çıktığında çağır. Auth stream'inin
  /// geçici `Loading` / `Error` emit'lerinde ÇAĞIRMA — RC logOut yeni bir
  /// anonim ID üretir ve entitlement görünürlüğünü sıfırlar.
  Future<void> logOut() async {
    if (!_configured) {
      _pendingLogOut = true;
      _pendingAppUserId = null;
      return;
    }
    try {
      final info = await Purchases.logOut();
      _emit(info);
    } catch (e) {
      // RC anon user'da logOut throw edebilir — kabul edilebilir.
      debugPrint('[Purchases] logOut: $e');
    }
  }

  Future<void> _flushPendingIdentity() async {
    final uid = _pendingAppUserId;
    final wantsLogOut = _pendingLogOut;
    _pendingAppUserId = null;
    _pendingLogOut = false;
    if (uid != null && uid.isNotEmpty) {
      await logIn(uid);
    } else if (wantsLogOut) {
      await logOut();
    }
  }

  // ── State ──────────────────────────────────────────────────────────────────

  /// Kalıcı stream — configure'dan önce de subscribe edilebilir.
  Stream<CustomerInfo> customerInfoStream() => _controller.stream;

  void _emit(CustomerInfo info) {
    _latestInfo = info;
    if (!_controller.isClosed) _controller.add(info);
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

  /// RC'den güncel CustomerInfo çekip stream'e basar; dinleyen tüm
  /// provider'lar güncellenir. configure sonrası + app resume'da çağrılır.
  ///
  /// [invalidateCache] true ise RC'nin cihazdaki cache'i geçersiz kılınır
  /// (sunucudan taze veri). Sadece kullanıcı tetiklediğinde kullan — her
  /// resume'da çağırmak gereksiz network trafiği yaratır.
  Future<Entitlement?> refresh({bool invalidateCache = false}) async {
    if (!_configured) return null;
    try {
      if (invalidateCache) {
        await Purchases.invalidateCustomerInfoCache();
      }
      final info = await Purchases.getCustomerInfo();
      _emit(info);
      return parseEntitlement(info);
    } catch (e) {
      debugPrint('[Purchases] refresh: $e');
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
    _emit(result.customerInfo);
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    _emit(info);
    return info;
  }

  // ── Entitlement parser ─────────────────────────────────────────────────────

  /// CustomerInfo → Entitlement. UI sadece Entitlement görür.
  ///
  /// Apple Reject 3 (2026-05-25) fix: RC dashboard'unda entitlement identifier
  /// "İPTV Ai Player Pro" olarak ayarlanmis (Turkce karakter + bosluk), kod
  /// `'pro'` ariyor → key mismatch → satin alma sonrasi Pro aktivelenmiyor.
  ///
  /// Defansif fallback: kesin 'pro' bulunamazsa, herhangi bir aktif
  /// entitlement varsa onu kullan. Tek entitlement varsayimi gecerli
  /// (RC dashboard'unda tek "Pro" entitlement, 3 product bagli).
  Entitlement parseEntitlement(CustomerInfo? info) {
    if (info == null) return Entitlement.free;
    var ent = info.entitlements.active[entitlementId];
    ent ??= info.entitlements.active.values.isNotEmpty
        ? info.entitlements.active.values.first
        : null;
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
