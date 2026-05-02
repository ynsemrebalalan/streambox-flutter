import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/entitlement.dart';
import '../data/purchases_service.dart';

/// Singleton service.
final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  return PurchasesService.instance;
});

/// Reactive entitlement state — RC customerInfoStream'i izler.
/// İlk değer cache'den (getCustomerInfo) alınır; sonrası listener emit'leri.
final purchasesNotifierProvider =
    AsyncNotifierProvider<PurchasesNotifier, Entitlement>(
  PurchasesNotifier.new,
);

class PurchasesNotifier extends AsyncNotifier<Entitlement> {
  @override
  Future<Entitlement> build() async {
    final svc = ref.read(purchasesServiceProvider);

    // Listener'ı subscribe et — entitlement güncellemelerini state'e yansıt.
    final sub = svc.customerInfoStream().listen((info) {
      final ent = svc.parseEntitlement(info);
      state = AsyncData(ent);
    });
    ref.onDispose(sub.cancel);

    // İlk değer: cached customerInfo.
    if (!svc.isConfigured) return Entitlement.free;
    final info = await svc.getCustomerInfo();
    return svc.parseEntitlement(info);
  }

  /// UI'dan tetiklenen restore. RC throw eder → UI snackbar'a düşer.
  Future<void> restore() async {
    final svc = ref.read(purchasesServiceProvider);
    state = const AsyncLoading();
    try {
      final info = await svc.restorePurchases();
      state = AsyncData(svc.parseEntitlement(info));
    } catch (e, st) {
      debugPrint('[Purchases] restore fail: $e');
      state = AsyncError(e, st);
    }
  }
}

/// Convenience: senkron Entitlement (Loading/Error → free).
final entitlementProvider = Provider<Entitlement>((ref) {
  return ref.watch(purchasesNotifierProvider).valueOrNull ?? Entitlement.free;
});

/// Convenience: kullanıcı Pro mu?
final isProProvider = Provider<bool>((ref) {
  return ref.watch(entitlementProvider).isPro;
});
