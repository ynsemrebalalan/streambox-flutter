import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/settings_repository.dart';
import '../data/entitlement.dart';
import '../data/purchases_service.dart';

/// Singleton service.
final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  return PurchasesService.instance;
});

/// Reactive entitlement state — RC customerInfoStream'i izler.
///
/// ## 2026-08-29 fix
///
/// Eski hâlde `build()` şunu yapıyordu:
/// ```dart
/// final sub = svc.customerInfoStream().listen(...);   // configure'dan önce
///                                                      // Stream.empty() → ÖLÜ
/// if (!svc.isConfigured) return Entitlement.free;      // KALICI olarak free
/// ```
/// `AsyncNotifier.build()` yalnızca BİR KEZ çalışır ve hiçbir provider'ı
/// watch etmediği için tekrar tetiklenmez. RC configure `_bootstrapInBackground`
/// içinde Firebase + MediaKit + secret migration'ın ARKASINDA olduğundan
/// `build()` her zaman `isConfigured == false` iken koşuyor ve state ömür boyu
/// `free` kalıyordu. Pro yalnızca `restore()` / `setEntitlement()` state'i
/// elle değiştirince görünüyordu — bildirilen davranışın tam karşılığı.
///
/// Yeni akış:
/// 1. Stream'e HER ZAMAN subscribe ol (artık kalıcı, configure'dan bağımsız).
/// 2. Cihazdaki cache'i oku → süresi geçmemişse anında Pro göster (flicker yok).
/// 3. Arka planda `ensureConfigured()` + `refresh()` → gerçek durumu doğrula.
/// 4. Her yeni entitlement'ı cache'e yaz.
final purchasesNotifierProvider =
    AsyncNotifierProvider<PurchasesNotifier, Entitlement>(
  PurchasesNotifier.new,
);

class PurchasesNotifier extends AsyncNotifier<Entitlement> {
  static const _cacheKey = SettingsKeys.entitlementCache;

  /// `build()` tamamlandı mı? Tamamlanmadan `state` set etmek Riverpod'da
  /// geçersiz; ayrıca build'in dönüş değeri onu ezerdi. Build sürerken gelen
  /// emit'ler bu bayrakla atlanır, build sonunda `latestInfo` ile telafi
  /// edilir (son değer her zaman serviste duruyor).
  bool _ready = false;
  bool _disposed = false;

  @override
  Future<Entitlement> build() async {
    final svc = ref.read(purchasesServiceProvider);
    _ready = false;
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // 1) Kalıcı stream'e subscribe — configure sonrası gelen her güncelleme
    //    (logIn/logOut/purchase/refresh/RC push) buradan akar.
    final sub = svc.customerInfoStream().listen((info) {
      if (!_ready) return; // build sonunda latestInfo ile yakalanacak
      _apply(svc.parseEntitlement(info));
    });
    ref.onDispose(sub.cancel);

    final Entitlement initial;
    if (svc.isConfigured) {
      // 2) RC zaten hazır (hot reload / provider invalidate) → doğrudan oku.
      final info = svc.latestInfo ?? await svc.getCustomerInfo();
      initial = svc.parseEntitlement(info);
      unawaited(_writeCache(initial));
    } else {
      // 3) RC henüz hazır değil → cihaz cache'i iyimser başlangıç değeri.
      initial = await _readCache() ?? Entitlement.free;
    }

    // Arka planda gerçek durumu doğrula (configure + refresh); sonuç stream
    // üzerinden state'e düşer.
    unawaited(_verifyInBackground());

    _ready = true;
    // Build sürerken bir emit geldiyse onu şimdi uygula.
    final latest = svc.latestInfo;
    if (latest != null) {
      final ent = svc.parseEntitlement(latest);
      if (ent != initial) {
        scheduleMicrotask(() => _apply(ent));
      }
    }
    return initial;
  }

  /// RC configure edilene kadar bekler, sonra gerçek entitlement'ı çeker.
  /// Sonuç stream üzerinden state'e düşer.
  Future<void> _verifyInBackground() async {
    final svc = ref.read(purchasesServiceProvider);
    try {
      await svc.ensureConfigured();
      await svc.refresh();
    } catch (e) {
      debugPrint('[Purchases] arka plan dogrulama basarisiz: $e');
    }
  }

  /// App resume / auth değişimi sonrası entitlement'ı tazele.
  /// [force] true ise RC cihaz cache'i geçersiz kılınır (kullanıcı tetikli).
  Future<void> refresh({bool force = false}) async {
    final svc = ref.read(purchasesServiceProvider);
    try {
      await svc.ensureConfigured();
      await svc.refresh(invalidateCache: force);
    } catch (e) {
      debugPrint('[Purchases] refresh basarisiz: $e');
    }
  }

  /// UI'dan tetiklenen restore. RC throw eder → UI snackbar'a düşer.
  Future<void> restore() async {
    final svc = ref.read(purchasesServiceProvider);
    // Önceki değeri koru — restore sırasında Pro kullanıcı bir an free
    // görünmesin (`const AsyncLoading()` value'yu düşürüyordu).
    state = const AsyncLoading<Entitlement>().copyWithPrevious(state);
    try {
      await svc.ensureConfigured();
      final info = await svc.restorePurchases();
      _apply(svc.parseEntitlement(info));
    } catch (e, st) {
      debugPrint('[Purchases] restore fail: $e');
      // Hata da olsa bilinen son entitlement'ı kaybetme.
      final previous = state.valueOrNull;
      state = AsyncError<Entitlement>(e, st)
          .copyWithPrevious(AsyncData(previous ?? Entitlement.free));
    }
  }

  /// Satin alma sonrasi listener race'i bypass: RC SDK'nin DOGRUDAN dondurdugu
  /// CustomerInfo'yu parse edip state'i hemen guncelle. Paywall purchase
  /// callback'inden cagrilir, "tikledim ama Pro acilmadi" race'i engeller.
  void setEntitlement(Entitlement ent) => _apply(ent);

  void _apply(Entitlement ent) {
    if (_disposed) return;
    state = AsyncData(ent);
    unawaited(_writeCache(ent));
  }

  // ── Cihaz cache'i ──────────────────────────────────────────────────────────

  Future<Entitlement?> _readCache() async {
    try {
      final raw = await SettingsRepository().get(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final ent = Entitlement.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
      // Süresi geçmiş cache asla Pro göstermez.
      return ent.isStillValid ? ent : Entitlement.free;
    } catch (e) {
      debugPrint('[Purchases] entitlement cache okunamadi: $e');
      return null;
    }
  }

  Future<void> _writeCache(Entitlement ent) async {
    try {
      await SettingsRepository().set(_cacheKey, jsonEncode(ent.toJson()));
    } catch (e) {
      debugPrint('[Purchases] entitlement cache yazilamadi: $e');
    }
  }
}

/// Convenience: senkron Entitlement (Loading/Error → son bilinen değer, yoksa
/// free). `valueOrNull` `copyWithPrevious` sayesinde loading sırasında da
/// önceki değeri döner.
final entitlementProvider = Provider<Entitlement>((ref) {
  return ref.watch(purchasesNotifierProvider).valueOrNull ?? Entitlement.free;
});

/// Convenience: kullanıcı Pro mu?
final isProProvider = Provider<bool>((ref) {
  return ref.watch(entitlementProvider).isPro;
});
