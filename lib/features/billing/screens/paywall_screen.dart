import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/purchases_providers.dart';

/// Trigger context — analytics ve copy variant için (bu sürümde copy aynı).
class PaywallScreen extends ConsumerStatefulWidget {
  final String trigger;
  const PaywallScreen({super.key, this.trigger = 'unknown'});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final offers =
          await ref.read(purchasesServiceProvider).getOfferings();
      if (!mounted) return;
      setState(() {
        _offerings = offers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _purchase(Package pkg) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final l = AppLocalizations.of(context);
    try {
      await ref.read(purchasesServiceProvider).purchasePackage(pkg);
      // Listener AsyncNotifier'ı güncellemiş olabilir, manuel olarak da
      // restore çağırarak kesinleştir.
      if (!mounted) return;
      final isPro = ref.read(isProProvider);
      if (isPro) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.paywallPurchaseSuccess)));
        if (mounted) context.pop(true);
        return;
      }
      // Edge: listener yetişmedi → manuel customerInfo refresh.
      await ref.read(purchasesNotifierProvider.notifier).restore();
      if (!mounted) return;
      if (ref.read(isProProvider)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.paywallPurchaseSuccess)));
        if (mounted) context.pop(true);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.paywallPurchaseCancelled)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.paywallPurchaseError(e.message ?? code.name))));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.paywallPurchaseError(e.toString()))));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final l = AppLocalizations.of(context);
    try {
      await ref.read(purchasesNotifierProvider.notifier).restore();
      if (!mounted) return;
      if (ref.read(isProProvider)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.paywallPurchaseSuccess)));
        if (mounted) context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.paywallPurchaseError(e.toString()))));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.paywallTitle),
        actions: [
          TextButton(
            onPressed: _purchasing ? null : _restore,
            child: Text(l.paywallRestoreButton),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: _buildBody(l),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final svc = ref.read(purchasesServiceProvider);
    if (!svc.isConfigured || _error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64),
              const SizedBox(height: 12),
              Text(l.paywallNotConfigured, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final offering = _offerings?.current;
    if (offering == null || offering.availablePackages.isEmpty) {
      return Center(child: Text(l.paywallNoOfferings));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l.paywallSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        _BenefitsList(),
        const SizedBox(height: 24),
        ..._buildPackageCards(offering.availablePackages, l),
        const SizedBox(height: 16),
        Text(
          l.paywallTermsFooter,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: () async {
                  final uri = Uri.parse(
                      'https://iptvaiplayer.com.tr/verisilme.php');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(l.paywallPrivacyLink)),
            const Text(' • '),
            TextButton(
                onPressed: () async {
                  final uri = Uri.parse(
                      'https://iptvaiplayer.com.tr/subscription-terms.php');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(l.paywallTermsLink)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPackageCards(List<Package> pkgs, AppLocalizations l) {
    // Yıllık'ı highlight göster (sektör std).
    final widgets = <Widget>[];
    for (final pkg in pkgs) {
      final isAnnual = pkg.identifier.contains('annual') ||
          pkg.identifier == r'$rc_annual';
      final isLifetime = pkg.identifier.contains('lifetime') ||
          pkg.identifier == r'$rc_lifetime';
      widgets.add(_PackageCard(
        pkg: pkg,
        highlighted: isAnnual,
        badge: isAnnual
            ? l.paywallBadgePopular
            : (isLifetime ? l.paywallBadgeBest : null),
        onPressed: _purchasing ? null : () => _purchase(pkg),
        loading: _purchasing,
      ));
      widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }
}

class _BenefitsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (Icons.playlist_add_check,
          l.paywallBenefitUnlimitedPlaylists, l.paywallBenefitUnlimitedPlaylistsDesc),
      (Icons.subtitles,
          l.paywallBenefitAiSubtitles, l.paywallBenefitAiSubtitlesDesc),
      (Icons.cloud_sync,
          l.paywallBenefitCloudSync, l.paywallBenefitCloudSyncDesc),
      (Icons.tv,
          l.paywallBenefitTvApps, l.paywallBenefitTvAppsDesc),
    ];
    return Column(
      children: items
          .map((it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(it.$1,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.$2,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          Text(it.$3,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Package pkg;
  final bool highlighted;
  final String? badge;
  final VoidCallback? onPressed;
  final bool loading;

  const _PackageCard({
    required this.pkg,
    required this.highlighted,
    required this.badge,
    required this.onPressed,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final priceStr = pkg.storeProduct.priceString;
    final title = _humanTitle(context, pkg);

    return Material(
      color: highlighted
          ? cs.primaryContainer
          : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(badge!,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onPrimary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(priceStr,
                        style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _humanTitle(BuildContext ctx, Package pkg) {
    final l = AppLocalizations.of(ctx);
    final id = pkg.identifier.toLowerCase();
    if (id.contains('lifetime')) return l.paywallPlanLifetime;
    if (id.contains('annual') || id.contains('yearly')) {
      return l.paywallPlanYearly;
    }
    if (id.contains('monthly')) return l.paywallPlanMonthly;
    return pkg.storeProduct.title;
  }
}
