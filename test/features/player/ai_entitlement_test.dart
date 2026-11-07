import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/ai_entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3, 12);
  int unix(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

  group('AiEntitlementStatus.tryParse', () {
    test('parses full server payload', () {
      final ends = now.add(const Duration(days: 7));
      final s = AiEntitlementStatus.tryParse(
          '{"pro":false,"trialActive":true,"trialEndsAt":${unix(ends)},"allowed":true}');
      expect(s, isNotNull);
      expect(s!.pro, isFalse);
      expect(s.trialActive, isTrue);
      expect(s.allowed, isTrue);
      expect(s.trialEndsAt, ends);
    });

    test('null trialEndsAt is accepted', () {
      final s = AiEntitlementStatus.tryParse(
          '{"pro":true,"trialActive":false,"trialEndsAt":null,"allowed":true}');
      expect(s!.pro, isTrue);
      expect(s.trialEndsAt, isNull);
    });

    test('garbage / empty / non-object body returns null', () {
      expect(AiEntitlementStatus.tryParse(null), isNull);
      expect(AiEntitlementStatus.tryParse(''), isNull);
      expect(AiEntitlementStatus.tryParse('<html>'), isNull);
      expect(AiEntitlementStatus.tryParse('[1,2]'), isNull);
    });

    test('missing allowed field is treated as not allowed', () {
      final s = AiEntitlementStatus.tryParse('{"pro":false}');
      expect(s!.allowed, isFalse);
    });

    test('trialEndsAt given as string is parsed', () {
      final ends = now.add(const Duration(days: 2));
      final s = AiEntitlementStatus.tryParse(
          '{"allowed":true,"trialActive":true,"trialEndsAt":"${unix(ends)}"}');
      expect(s!.trialEndsAt, ends);
    });
  });

  group('trialDaysLeft', () {
    test('rounds up partial days and clamps to 1..7', () {
      expect(trialDaysLeft(now.add(const Duration(days: 7)), now), 7);
      expect(trialDaysLeft(now.add(const Duration(days: 6, hours: 1)), now), 7);
      expect(trialDaysLeft(now.add(const Duration(hours: 3)), now), 1);
      expect(trialDaysLeft(now.add(const Duration(days: 30)), now), 7);
    });
    test('expired or null returns 0', () {
      expect(trialDaysLeft(now.subtract(const Duration(hours: 1)), now), 0);
      expect(trialDaysLeft(null, now), 0);
    });
  });

  group('decideAiGate', () {
    test('Pro goes without server call result', () {
      final r = decideAiGate(isPro: true, hasOwnKey: false, server: null, now: now);
      expect(r, isA<AiGateAllowed>());
      expect((r as AiGateAllowed).reason, AiGateReason.pro);
    });

    test('own OpenAI key bypasses trial', () {
      final r = decideAiGate(isPro: false, hasOwnKey: true, server: null, now: now);
      expect((r as AiGateAllowed).reason, AiGateReason.ownKey);
    });

    test('server unreachable fails open', () {
      final r = decideAiGate(isPro: false, hasOwnKey: false, server: null, now: now);
      expect((r as AiGateAllowed).reason, AiGateReason.failOpen);
    });

    test('server says pro', () {
      const s = AiEntitlementStatus(pro: true, trialActive: false, allowed: true);
      final r = decideAiGate(isPro: false, hasOwnKey: false, server: s, now: now);
      expect((r as AiGateAllowed).reason, AiGateReason.pro);
    });

    test('fresh trial reports justStarted with 7 days', () {
      final s = AiEntitlementStatus(
          pro: false,
          trialActive: true,
          allowed: true,
          trialEndsAt: now.add(const Duration(days: 7)));
      final r = decideAiGate(isPro: false, hasOwnKey: false, server: s, now: now)
          as AiGateAllowed;
      expect(r.reason, AiGateReason.trial);
      expect(r.justStarted, isTrue);
      expect(r.daysLeft, 7);
    });

    test('ongoing trial reports days left, not justStarted', () {
      final s = AiEntitlementStatus(
          pro: false,
          trialActive: true,
          allowed: true,
          trialEndsAt: now.add(const Duration(days: 3, hours: 2)));
      final r = decideAiGate(isPro: false, hasOwnKey: false, server: s, now: now)
          as AiGateAllowed;
      expect(r.justStarted, isFalse);
      expect(r.daysLeft, 4);
    });

    test('not allowed → denied', () {
      final s = AiEntitlementStatus(
          pro: false,
          trialActive: false,
          allowed: false,
          trialEndsAt: now.subtract(const Duration(days: 1)));
      final r = decideAiGate(isPro: false, hasOwnKey: false, server: s, now: now);
      expect(r, isA<AiGateDenied>());
    });
  });
}
