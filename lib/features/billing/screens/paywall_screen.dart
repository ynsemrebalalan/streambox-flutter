import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/utils/device_tier.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../logic/paywall_logic.dart';
import '../logic/playlist_limit.dart';
import '../providers/purchases_providers.dart';
import '../widgets/paywall_widgets.dart';

/// Pro satin alma ekrani — alttan acilan modal (router: fullscreenDialog).
/// Apple 3.1.2: fiyat + periyot belirgin, deneme/yenileme kosullari, Restore,
/// Gizlilik + Kullanim Sartlari linkleri her durumda gorunur.
class PaywallScreen extends ConsumerStatefulWidget {
  final String trigger;
  const PaywallScreen({super.key, this.trigger = 'unknown'});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offerings? _offerings;
  Map<String, bool?> _introEligible = const {};
  bool _loading = true;
  bool _purchasing = false;
  bool _failed = false;
  bool _closed = false;
  late final bool _initiallyPro = ref.read(isProProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _close(bool purchased) {
    if (_closed || !mounted) return;
    _closed = true;
    context.pop(purchased);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final svc = ref.read(purchasesServiceProvider);
      // Apple Reject 3 fix: RC init main.dart'ta timeout'a girmis olabilir
      // (Apple review cihaz network gecikmesi). Paywall acilinca lazy retry.
      if (!svc.isConfigured) {
        await svc.ensureConfigured();
      }
      final offers = await svc.getOfferings();
      // Deneme/tanıtım uygunluğu — daha önce deneyen kullanıcıya
      // "N gün ücretsiz" gösterilmesin.
      final ids = [
        for (final p in [...?offers?.current?.availablePackages])
          if (p.storeProduct.introductoryPrice != null) p.storeProduct.identifier,
      ];
      final eligible = await svc
          .introEligibility(ids)
          .timeout(const Duration(seconds: 5), onTimeout: () => const {});
      if (!mounted) return;
      setState(() {
        _offerings = offers;
        _introEligible = eligible;
        _loading = false;
        _failed = !svc.isConfigured;
      });
    } catch (e) {
      debugPrint('[Paywall] offerings load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _snack(String msg, {SnackBarAction? action, Duration? duration}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      action: action,
      duration: duration ?? const Duration(seconds: 4),
    ));
  }

  Future<void> _purchase(Package pkg) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final l = AppLocalizations.of(context);
    try {
      final svc = ref.read(purchasesServiceProvider);
      final info = await svc.purchasePackage(pkg);
      // RC SDK'nin dondurdugu CustomerInfo'yu DOGRUDAN parse et — listener +
      // provider chain race'i bypass et.
      final ent = svc.parseEntitlement(info);
      if (!mounted) return;
      if (ent.isPro) {
        ref.read(purchasesNotifierProvider.notifier).setEntitlement(ent);
        _snack(l.paywallPurchaseSuccess);
        _close(true);
        return;
      }

      // Listener'in tetiklenmesini bekle (max 3 sn polling)
      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        if (ref.read(isProProvider)) {
          _snack(l.paywallPurchaseSuccess);
          _close(true);
          return;
        }
      }

      // Hala pro degil → RC backend'inden customerInfo yenile.
      await ref.read(purchasesNotifierProvider.notifier).refresh(force: true);
      if (!mounted) return;
      if (ref.read(isProProvider)) {
        _snack(l.paywallPurchaseSuccess);
        _close(true);
        return;
      }

      // Satin alma tamamlandi ama entitlement aktif degil (RC dashboard
      // urun-entitlement eslesmesi). Teshis YALNIZ log'a; kullaniciya
      // yerellestirilmis mesaj + Restore aksiyonu.
      final fresh = await svc.getCustomerInfo();
      debugPrint('[Paywall] WARN: purchase ok but entitlement inactive. '
          'product=${pkg.storeProduct.identifier} '
          'active=${fresh?.entitlements.active.keys.toList()} '
          'all=${fresh?.entitlements.all.keys.toList()}');
      if (!mounted) return;
      _snack(
        l.paywallActivationPending,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
            label: l.paywallRestoreButton, onPressed: _restore),
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('[Paywall] purchase error: ${code.name} ${e.message}');
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        _snack(l.paywallPurchaseCancelled);
      } else {
        _snack(l.paywallPurchaseError(e.message ?? code.name));
      }
    } catch (e) {
      _snack(l.paywallPurchaseError('$e'));
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
        _snack(l.paywallPurchaseSuccess);
        _close(true);
      } else {
        final err = ref.read(purchasesNotifierProvider).error;
        _snack(err != null ? l.paywallPurchaseError('$err') : l.paywallRestoreNothing);
      }
    } catch (e) {
      _snack(l.paywallPurchaseError('$e'));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Android: yalniz satin alma sonrasi (false → true) otomatik kapan.
    ref.listen<bool>(isProProvider, (prev, next) {
      if (next && !_initiallyPro) _close(true);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(l.paywallTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => _close(false),
        ),
        actions: [
          TextButton(
            onPressed: _purchasing ? null : _restore,
            child: Text(l.paywallRestoreButton),
          ),
        ],
      ),
      // Apple 3.1.2(c): Privacy + Terms her durumda (loading/error dahil) gorunur.
      bottomNavigationBar: const SafeArea(top: false, child: PaywallLegalLinksBar()),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: Responsive.formMaxWidth(context),
          child: _buildBody(l),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final packages = [...?_offerings?.current?.availablePackages]
      ..sort((a, b) => packageSortRank(a.identifier)
          .compareTo(packageSortRank(b.identifier)));
    final hasLifetime = packages.any((p) => packageSortRank(p.identifier) == 0);
    final hasSubscription =
        packages.any((p) => packageSortRank(p.identifier) != 0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (widget.trigger == 'aiSubtitle') ...[
          Text(l.paywallAiTrialEnded,
              textAlign: TextAlign.center,
              style: tt.titleSmall?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        Text(l.paywallSubtitle,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        PaywallBenefitsList(
          playlistLimit: playlistLimitFor(isPro: true, tier: DeviceProfile.tier),
        ),
        const SizedBox(height: 20),
        if (_loading)
          ...List.generate(3, (_) => const PaywallSkeletonCard())
        else if (_failed || packages.isEmpty) ...[
          PaywallErrorState(
            message: _failed ? l.paywallLoadError : l.paywallNoOfferings,
            onRetry: _load,
          ),
          ...List.generate(3, (_) => const PaywallSkeletonCard()),
        ] else
          for (final pkg in packages)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PaywallPackageCard(
                pkg: pkg,
                highlighted:
                    isHighlightedPackage(pkg.identifier, hasLifetime: hasLifetime),
                busy: _purchasing,
                introEligible: _introEligible[pkg.storeProduct.identifier],
                onPurchase: () => _purchase(pkg),
              ),
            ),
        const SizedBox(height: 4),
        OutlinedButton(
          onPressed: _purchasing ? null : _restore,
          child: Text(l.paywallRestoreButton),
        ),
        if (hasSubscription || _loading || _failed) ...[
          const SizedBox(height: 16),
          Text(
            l.paywallTermsFooterApple,
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
                fontSize: 13, color: cs.onSurfaceVariant, height: 1.35),
          ),
        ],
      ],
    );
  }
}
