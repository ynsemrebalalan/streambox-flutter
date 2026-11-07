import '../data/entitlement.dart';

/// Satin alma sonrasi RC receipt dogrulamasi gecikirse Pro'nun korundugu sure
/// (Android PurchasesService: 5 dk).
const purchaseGraceWindow = Duration(minutes: 5);

/// Bos (authoritative olmayan) CustomerInfo geldiginde onceki Pro'nun en fazla
/// ne kadar korunacagi. Android sinirsiz koruyordu; iOS'ta "kisa sure" —
/// RC lag'i kapatmaya yeter, baska kullanicinin Pro'sunu tasimaz.
const downgradeProtectionWindow = Duration(minutes: 5);

/// Android `PurchasesService.applyCustomerInfo` paritesi (saf, testli).
///
/// 1. [parsed] Pro → uygula.
/// 2. Son [purchaseGraceWindow] icinde satin alma yapildi → Pro goster.
/// 3. Info bos (aktif/inaktif hic entitlement yok), onceden Pro, suresi
///    gecmemis, kimlik sifirlanmamis ([identityReset] = logOut) ve koruma
///    [downgradeProtectionWindow]'u asmamis → onceki Pro korunur.
/// 4. Aksi halde [parsed].
///
/// [proKeptSince]: korumanin ilk uygulandigi an (null = simdi basliyor).
Entitlement resolveEntitlement({
  required Entitlement parsed,
  required Entitlement current,
  required bool infoIsAuthoritative,
  required DateTime now,
  String? lastPurchasedProductId,
  DateTime? lastPurchaseAt,
  DateTime? proKeptSince,
  bool identityReset = false,
}) {
  if (parsed.isPro) return parsed;
  final inGrace = lastPurchasedProductId != null &&
      lastPurchaseAt != null &&
      now.difference(lastPurchaseAt) < purchaseGraceWindow;
  if (inGrace) {
    return Entitlement(
      isPro: true,
      productId: lastPurchasedProductId,
      source: EntitlementSource.appStore,
    );
  }
  final exp = current.expiresAt;
  final currentValid = current.isPro && (exp == null || exp.isAfter(now));
  final withinWindow = proKeptSince == null ||
      now.difference(proKeptSince) < downgradeProtectionWindow;
  if (!infoIsAuthoritative && !identityReset && currentValid && withinWindow) {
    return current;
  }
  return parsed;
}
