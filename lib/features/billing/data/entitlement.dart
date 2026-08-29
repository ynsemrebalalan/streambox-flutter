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

  /// Cihazda cache'lenmiş entitlement hâlâ geçerli mi? RC yanıt verene kadar
  /// açılışta iyimser (optimistic) Pro göstermek için kullanılır; süresi
  /// geçmişse asla Pro gösterme.
  bool get isStillValid {
    if (!isPro) return false;
    final exp = expiresAt;
    if (exp == null) return true; // lifetime
    return exp.isAfter(DateTime.now());
  }

  // ── Local cache serialization ──────────────────────────────────────────────
  //
  // RC SDK'nin kendi cache'i var ama SADECE configure tamamlandıktan sonra
  // okunabiliyor; configure ise Firebase + MediaKit init'inin arkasında,
  // yani ilk saniyelerde UI "free" görüyordu. Bu cache o pencereyi kapatır.

  Map<String, dynamic> toJson() => {
        'isPro': isPro,
        'expiresAt': expiresAt?.toIso8601String(),
        'productId': productId,
        'source': source.name,
      };

  static Entitlement fromJson(Map<String, dynamic> json) {
    final rawExpires = json['expiresAt'] as String?;
    return Entitlement(
      isPro: json['isPro'] == true,
      expiresAt:
          rawExpires == null ? null : DateTime.tryParse(rawExpires),
      productId: json['productId'] as String?,
      source: EntitlementSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => EntitlementSource.unknown,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Entitlement &&
      other.isPro == isPro &&
      other.expiresAt == expiresAt &&
      other.productId == productId &&
      other.source == source;

  @override
  int get hashCode => Object.hash(isPro, expiresAt, productId, source);

  @override
  String toString() =>
      'Entitlement(isPro: $isPro, productId: $productId, '
      'expiresAt: $expiresAt, source: ${source.name})';
}

enum EntitlementSource { appStore, playStore, promotional, unknown }
