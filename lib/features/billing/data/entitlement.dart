/// Tek elden feature gating: `entitlementProvider` bunu döner; `isPro` true ise
/// premium feature açıktır. Ücretsiz kullanıcılar için `Entitlement.free` kullan.
class Entitlement {
  /// `pro` entitlement aktif mi? Ücretsiz/expired ise false.
  final bool isPro;

  /// Aboneliğin sona erme zamanı. Lifetime için null (kalıcı).
  final DateTime? expiresAt;

  /// Hangi product (RevenueCat productIdentifier — `com.streambox.app.pro.*`).
  final String? productId;

  /// Hangi store'dan satın alındı.
  final EntitlementSource source;

  const Entitlement({
    required this.isPro,
    this.expiresAt,
    this.productId,
    this.source = EntitlementSource.unknown,
  });

  static const Entitlement free = Entitlement(isPro: false);

  bool get isLifetime =>
      productId?.contains('lifetime') == true || expiresAt == null;
}

enum EntitlementSource { appStore, playStore, promotional, unknown }
