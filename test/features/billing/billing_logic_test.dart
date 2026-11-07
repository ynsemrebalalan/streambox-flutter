import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/utils/device_tier.dart';
import 'package:iptv_ai_player/features/billing/data/entitlement.dart';
import 'package:iptv_ai_player/features/billing/logic/entitlement_resolver.dart';
import 'package:iptv_ai_player/features/billing/logic/paywall_logic.dart';
import 'package:iptv_ai_player/features/billing/logic/playlist_limit.dart';

void main() {
  group('playlistLimitFor (Android HomeViewModel.maxPlaylistCount)', () {
    test('free: low 1, mid 2, high 5', () {
      expect(playlistLimitFor(isPro: false, tier: DeviceTier.low), 1);
      expect(playlistLimitFor(isPro: false, tier: DeviceTier.mid), 2);
      expect(playlistLimitFor(isPro: false, tier: DeviceTier.high), 5);
    });
    test('pro: low 2, mid 5, high 20', () {
      expect(playlistLimitFor(isPro: true, tier: DeviceTier.low), 2);
      expect(playlistLimitFor(isPro: true, tier: DeviceTier.mid), 5);
      expect(playlistLimitFor(isPro: true, tier: DeviceTier.high), 20);
    });
  });

  group('decidePlaylistAdd', () {
    test('limit altinda izin verilir', () {
      expect(
          decidePlaylistAdd(existingCount: 4, isPro: false, tier: DeviceTier.high),
          PlaylistAddDecision.allowed);
      expect(canAddPlaylist(existingCount: 4, isPro: false, tier: DeviceTier.high),
          isTrue);
    });
    test('free limitte + Pro daha fazlasini acar → needsPro', () {
      expect(
          decidePlaylistAdd(existingCount: 5, isPro: false, tier: DeviceTier.high),
          PlaylistAddDecision.needsPro);
      expect(
          decidePlaylistAdd(existingCount: 1, isPro: false, tier: DeviceTier.low),
          PlaylistAddDecision.needsPro);
    });
    test('pro limitte → deviceLimit', () {
      expect(
          decidePlaylistAdd(existingCount: 20, isPro: true, tier: DeviceTier.high),
          PlaylistAddDecision.deviceLimit);
      expect(canAddPlaylist(existingCount: 20, isPro: true, tier: DeviceTier.high),
          isFalse);
    });
    test('free, pro limitinin de ustunde → deviceLimit (paywall anlamsiz)', () {
      expect(
          decidePlaylistAdd(existingCount: 25, isPro: false, tier: DeviceTier.high),
          PlaylistAddDecision.deviceLimit);
    });
  });

  group('resolveEntitlement (Android applyCustomerInfo downgrade korumasi)', () {
    const pro = Entitlement(isPro: true, productId: 'p.annual');
    final now = DateTime(2026, 11, 4, 12);

    test('kesin Pro her zaman uygulanir', () {
      expect(
          resolveEntitlement(
              parsed: pro,
              current: Entitlement.free,
              infoIsAuthoritative: true,
              now: now),
          pro);
    });
    test('bos (authoritative olmayan) info + onceden Pro → Pro korunur', () {
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: pro,
              infoIsAuthoritative: false,
              now: now),
          pro);
    });
    test('koruma kisa sureli: pencere dolunca downgrade', () {
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: pro,
              infoIsAuthoritative: false,
              proKeptSince: now.subtract(const Duration(minutes: 4)),
              now: now),
          pro);
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: pro,
              infoIsAuthoritative: false,
              proKeptSince: now.subtract(downgradeProtectionWindow),
              now: now),
          Entitlement.free);
    });
    test('suresi gecmis Pro korunmaz', () {
      final expired = Entitlement(
          isPro: true,
          productId: 'p.monthly',
          expiresAt: now.subtract(const Duration(days: 1)));
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: expired,
              infoIsAuthoritative: false,
              now: now),
          Entitlement.free);
    });
    test('kimlik sifirlandi (logOut) → koruma yok', () {
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: pro,
              infoIsAuthoritative: false,
              identityReset: true,
              now: now),
          Entitlement.free);
    });
    test('authoritative info free diyorsa downgrade edilir', () {
      expect(
          resolveEntitlement(
              parsed: Entitlement.free,
              current: pro,
              infoIsAuthoritative: true,
              now: now),
          Entitlement.free);
    });
    test('son 5 dk satin alma → Pro (grace)', () {
      final r = resolveEntitlement(
          parsed: Entitlement.free,
          current: Entitlement.free,
          infoIsAuthoritative: true,
          lastPurchasedProductId: 'p.monthly',
          lastPurchaseAt: now.subtract(const Duration(minutes: 2)),
          now: now);
      expect(r.isPro, isTrue);
      expect(r.productId, 'p.monthly');
    });
    test('grace 5 dk sonra biter', () {
      final r = resolveEntitlement(
          parsed: Entitlement.free,
          current: Entitlement.free,
          infoIsAuthoritative: true,
          lastPurchasedProductId: 'p.monthly',
          lastPurchaseAt: now.subtract(const Duration(minutes: 6)),
          now: now);
      expect(r.isPro, isFalse);
    });
  });

  group('paywall paket sirasi / vurgu', () {
    test('lifetime < annual < monthly < diger', () {
      final ids = ['\$rc_monthly', 'custom', '\$rc_annual', '\$rc_lifetime'];
      final sorted = [...ids]..sort((a, b) =>
          packageSortRank(a).compareTo(packageSortRank(b)));
      expect(sorted, ['\$rc_lifetime', '\$rc_annual', '\$rc_monthly', 'custom']);
    });
    test('lifetime varsa o vurgulanir, yoksa yillik', () {
      expect(isHighlightedPackage('\$rc_lifetime', hasLifetime: true), isTrue);
      expect(isHighlightedPackage('\$rc_annual', hasLifetime: true), isFalse);
      expect(isHighlightedPackage('\$rc_annual', hasLifetime: false), isTrue);
      expect(isHighlightedPackage('\$rc_monthly', hasLifetime: false), isFalse);
    });
    test('periyot tespiti: ISO period oncelikli, yoksa identifier', () {
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P1Y'),
          PlanPeriod.year);
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P1M'),
          PlanPeriod.month);
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P1W'),
          PlanPeriod.week);
      expect(planPeriodOf(identifier: '\$rc_annual'), PlanPeriod.year);
      expect(planPeriodOf(identifier: 'pro_monthly'), PlanPeriod.month);
      expect(planPeriodOf(identifier: '\$rc_lifetime'), PlanPeriod.lifetime);
      expect(planPeriodOf(identifier: 'weird'), PlanPeriod.unknown);
    });
    test('ucretsiz deneme gun sayisi', () {
      expect(freeTrialDays(price: 0, unit: TrialUnit.day, units: 3, cycles: 1), 3);
      expect(freeTrialDays(price: 0, unit: TrialUnit.week, units: 1, cycles: 1), 7);
      expect(freeTrialDays(price: 0, unit: TrialUnit.month, units: 1, cycles: 1), 30);
      // Ucretli tanitim fiyati deneme degildir.
      expect(freeTrialDays(price: 9.99, unit: TrialUnit.week, units: 1, cycles: 1),
          isNull);
      expect(freeTrialDays(price: 0, unit: TrialUnit.unknown, units: 1, cycles: 1),
          isNull);
    });
  });
}
