import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/billing/logic/paywall_logic.dart';

void main() {
  group('introOfferKind (M6)', () {
    test('ineligible user sees no trial / intro', () {
      expect(
          introOfferKind(
              hasIntro: true, introPrice: 0, trialDays: 7, eligible: false),
          IntroOfferKind.none);
    });
    test('eligible or unknown with free trial shows trial', () {
      expect(
          introOfferKind(
              hasIntro: true, introPrice: 0, trialDays: 7, eligible: true),
          IntroOfferKind.freeTrial);
      expect(
          introOfferKind(
              hasIntro: true, introPrice: 0, trialDays: 3, eligible: null),
          IntroOfferKind.freeTrial);
    });
    test('paid intro price is shown as paid intro', () {
      expect(
          introOfferKind(
              hasIntro: true, introPrice: 0.99, trialDays: null, eligible: true),
          IntroOfferKind.paidIntro);
    });
    test('no intro → none', () {
      expect(
          introOfferKind(
              hasIntro: false, introPrice: 0, trialDays: null, eligible: true),
          IntroOfferKind.none);
    });
  });
}
