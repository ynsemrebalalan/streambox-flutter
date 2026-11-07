/// Paywall paket siralama / vurgu / periyot / deneme hesaplari (saf, testli).
/// Android PaywallScreen paritesi.
library;

/// Android sirasi: lifetime → annual → monthly → digerleri.
int packageSortRank(String identifier) {
  final id = identifier.toLowerCase();
  if (id.contains('lifetime')) return 0;
  if (id.contains('annual') || id.contains('yearly')) return 1;
  if (id.contains('monthly')) return 2;
  return 3;
}

/// Android: lifetime varsa o, yoksa yillik vurgulanir.
bool isHighlightedPackage(String identifier, {required bool hasLifetime}) {
  final rank = packageSortRank(identifier);
  return rank == 0 || (rank == 1 && !hasLifetime);
}

/// [multiMonth]: P3M / P6M gibi coklu ay — "/ ay" DEGIL, "/ N ay"
/// (ay sayisi: [planMonthCount]).
enum PlanPeriod { week, month, multiMonth, year, lifetime, unknown }

final _monthsRe = RegExp(r'^P(\d+)M$');

/// `PnM` → n (P1M → 1). Diger bicimler → null.
int? planMonthCount(String? subscriptionPeriod) {
  final m = _monthsRe.firstMatch(subscriptionPeriod?.toUpperCase() ?? '');
  return m == null ? null : int.tryParse(m.group(1)!);
}

/// ISO 8601 `subscriptionPeriod` (P1W/P1M/P1Y) oncelikli; yoksa identifier.
PlanPeriod planPeriodOf({required String identifier, String? subscriptionPeriod}) {
  final p = subscriptionPeriod?.toUpperCase() ?? '';
  if (p.isNotEmpty) {
    if (p.endsWith('Y') || p == 'P12M') return PlanPeriod.year;
    final months = planMonthCount(p);
    if (months == 1) return PlanPeriod.month;
    if (months != null && months > 1) return PlanPeriod.multiMonth;
    if (p.endsWith('W') || p == 'P7D') return PlanPeriod.week;
  }
  return switch (packageSortRank(identifier)) {
    0 => PlanPeriod.lifetime,
    1 => PlanPeriod.year,
    2 => PlanPeriod.month,
    _ => identifier.toLowerCase().contains('weekly')
        ? PlanPeriod.week
        : PlanPeriod.unknown,
  };
}

enum TrialUnit { day, week, month, year, unknown }

/// Ucretsiz deneme suresi (gun). Tanitim fiyati ucretliyse / birim bilinmiyorsa null.
int? freeTrialDays({
  required double price,
  required TrialUnit unit,
  required int units,
  required int cycles,
}) {
  if (price > 0) return null;
  final perUnit = switch (unit) {
    TrialUnit.day => 1,
    TrialUnit.week => 7,
    TrialUnit.month => 30,
    TrialUnit.year => 365,
    TrialUnit.unknown => 0,
  };
  final days = perUnit * units * (cycles < 1 ? 1 : cycles);
  return days > 0 ? days : null;
}

enum IntroOfferKind { none, freeTrial, paidIntro }

/// Tanitim teklifi gosterimi. [eligible]: RC
/// `checkTrialOrIntroductoryPriceEligibility` sonucu (null = bilinmiyor →
/// gosterilir; false = kullanici daha once denedi → "N gun ucretsiz" YOK).
IntroOfferKind introOfferKind({
  required bool hasIntro,
  required double introPrice,
  required int? trialDays,
  required bool? eligible,
}) {
  if (!hasIntro || eligible == false) return IntroOfferKind.none;
  if (trialDays != null) return IntroOfferKind.freeTrial;
  if (introPrice > 0) return IntroOfferKind.paidIntro;
  return IntroOfferKind.none;
}
