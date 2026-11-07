import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../logic/paywall_logic.dart';

/// Yasal URL'ler — Android SettingsScreen ile ayni domain.
/// (Eski `?gizlilik` adresi ana sayfaya dusuyordu; gizlilik.php dogru sayfa.)
abstract final class LegalUrls {
  static const privacy = 'https://iptvaiplayer.com.tr/gizlilik.php';
  /// Kullanici Sozlesmesi (Android "legal_user_agreement").
  static const terms = 'https://iptvaiplayer.com.tr/sozlesme.php';
  /// Abonelik sartlari (paywall EULA linki).
  static const subscriptionTerms =
      'https://iptvaiplayer.com.tr/subscription-terms.php';
  static const dataDeletion = 'https://iptvaiplayer.com.tr/verisilme.php';
}

Future<void> openExternalUrl(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('[Legal] launch failed: $e');
  }
}

/// Apple 3.1.2(c): Privacy + Terms linkleri her durumda gorunur.
class PaywallLegalLinksBar extends StatelessWidget {
  const PaywallLegalLinksBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    const linkStyle = TextStyle(fontSize: 13);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: () => openExternalUrl(LegalUrls.privacy),
              child: Text(l.paywallPrivacyLink, style: linkStyle),
            ),
            Text('•', style: TextStyle(color: cs.onSurfaceVariant)),
            TextButton(
              onPressed: () => openExternalUrl(LegalUrls.subscriptionTerms),
              child: Text(l.paywallTermsLink, style: linkStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Android BenefitsList — "reklamsiz" ve iOS'ta desteklenmeyen PiP haric.
class PaywallBenefitsList extends StatelessWidget {
  /// Bu cihazda Pro ile izin verilen playlist sayisi (RAM katmani).
  final int playlistLimit;
  const PaywallBenefitsList({super.key, required this.playlistLimit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = <(IconData, String)>[
      (Icons.playlist_add_check, l.paywallBenefitPlaylistsUpTo(playlistLimit)),
      (Icons.subtitles_outlined, l.paywallBenefitAiWhisper),
      (Icons.cloud_sync_outlined, l.paywallBenefitCloudSyncDevices),
      (Icons.palette_outlined, l.paywallBenefitThemes),
      (Icons.bookmark_outline, l.paywallBenefitWatchlist),
      (Icons.event_repeat_outlined, l.paywallBenefitEpgAuto),
    ];
    return Column(
      children: [
        for (final (icon, text) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(icon, color: cs.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: tt.bodyLarge)),
                Icon(Icons.check, color: cs.primary, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class PaywallSkeletonCard extends StatelessWidget {
  const PaywallSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(110, 16),
          const SizedBox(height: 12),
          bar(160, 22),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: bar(96, 36)),
        ],
      ),
    );
  }
}

class PaywallErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const PaywallErrorState(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 40, color: cs.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l.retry),
          ),
        ],
      ),
    );
  }
}

/// Tek paket karti. Vurgulu: surfaceContainerHigh + 2px primary kenar (r16);
/// digerleri 1px outlineVariant.
class PaywallPackageCard extends StatelessWidget {
  final Package pkg;
  final bool highlighted;
  final bool busy;
  final VoidCallback onPurchase;

  const PaywallPackageCard({
    super.key,
    required this.pkg,
    required this.highlighted,
    required this.busy,
    required this.onPurchase,
    this.introEligible,
  });

  /// RC uygunluk sonucu (null = bilinmiyor).
  final bool? introEligible;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final product = pkg.storeProduct;
    final period = planPeriodOf(
        identifier: pkg.identifier,
        subscriptionPeriod: product.subscriptionPeriod);
    final months = planMonthCount(product.subscriptionPeriod) ?? 0;
    final priceLine =
        _priceWithPeriod(l, period, product.priceString, months: months);
    final rank = packageSortRank(pkg.identifier);
    final badge = switch (rank) {
      0 => l.paywallBadgeBest,
      1 => l.paywallBadgePopular,
      _ => null,
    };
    final monthlyEq = period == PlanPeriod.year
        ? product.pricePerMonthString
        : null;
    final intro = product.introductoryPrice;
    final trialDays = _trialDays(intro);
    final introKind = introOfferKind(
      hasIntro: intro != null,
      introPrice: intro?.price ?? 0,
      trialDays: trialDays,
      eligible: introEligible,
    );

    return Material(
      color: highlighted ? cs.surfaceContainerHigh : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted ? cs.primary : cs.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onPurchase,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                        _title(l, period, product.title, months: months),
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(badge,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(priceLine,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              if (monthlyEq != null && monthlyEq.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(l.paywallMonthlyEquivalent(monthlyEq),
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
              if (introKind == IntroOfferKind.freeTrial && trialDays != null) ...[
                const SizedBox(height: 6),
                Text(l.paywallTrialThen(trialDays, priceLine),
                    style: tt.bodyMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w600)),
              ],
              if (introKind == IntroOfferKind.paidIntro && intro != null) ...[
                const SizedBox(height: 6),
                Text(l.paywallIntroPriceThen(intro.priceString, priceLine),
                    style: tt.bodyMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w600)),
              ],
              if (period == PlanPeriod.lifetime) ...[
                const SizedBox(height: 6),
                Text(l.paywallLifetimeHint,
                    style: tt.bodyMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: highlighted
                    ? FilledButton(
                        onPressed: busy ? null : onPurchase,
                        child: _ctaChild(l),
                      )
                    : FilledButton.tonal(
                        onPressed: busy ? null : onPurchase,
                        child: _ctaChild(l),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ctaChild(AppLocalizations l) => busy
      ? const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2))
      : Text(l.paywallPurchase, style: const TextStyle(fontSize: 16));

  static String _priceWithPeriod(
          AppLocalizations l, PlanPeriod period, String price,
          {int months = 0}) =>
      switch (period) {
        PlanPeriod.year => l.paywallPricePerYear(price),
        PlanPeriod.month => l.paywallPricePerMonth(price),
        PlanPeriod.multiMonth => l.paywallPricePerMonths(price, months),
        PlanPeriod.week => l.paywallPricePerWeek(price),
        PlanPeriod.lifetime => l.paywallPriceOneTime(price),
        PlanPeriod.unknown => price,
      };

  static String _title(AppLocalizations l, PlanPeriod period, String fallback,
          {int months = 0}) =>
      switch (period) {
        PlanPeriod.year => l.paywallPlanYearly,
        PlanPeriod.month => l.paywallPlanMonthly,
        PlanPeriod.multiMonth => l.paywallPlanMonths(months),
        PlanPeriod.lifetime => l.paywallPlanLifetime,
        _ => fallback.replaceAll('(StreamBox)', '').trim(),
      };

  static int? _trialDays(IntroductoryPrice? intro) {
    if (intro == null) return null;
    final unit = switch (intro.periodUnit) {
      PeriodUnit.day => TrialUnit.day,
      PeriodUnit.week => TrialUnit.week,
      PeriodUnit.month => TrialUnit.month,
      PeriodUnit.year => TrialUnit.year,
      _ => TrialUnit.unknown,
    };
    return freeTrialDays(
      price: intro.price,
      unit: unit,
      units: intro.periodNumberOfUnits,
      cycles: intro.cycles,
    );
  }
}
