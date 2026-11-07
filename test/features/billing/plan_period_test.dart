import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/billing/logic/paywall_logic.dart';

void main() {
  group('planPeriodOf multi-month (M7)', () {
    test('only P1M is monthly', () {
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P1M'),
          PlanPeriod.month);
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P3M'),
          PlanPeriod.multiMonth);
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P6M'),
          PlanPeriod.multiMonth);
      expect(planPeriodOf(identifier: 'x', subscriptionPeriod: 'P12M'),
          PlanPeriod.year);
    });
    test('planMonthCount parses PnM', () {
      expect(planMonthCount('P3M'), 3);
      expect(planMonthCount('p6m'), 6);
      expect(planMonthCount('P1M'), 1);
      expect(planMonthCount('P1Y'), isNull);
      expect(planMonthCount(null), isNull);
    });
  });
}
