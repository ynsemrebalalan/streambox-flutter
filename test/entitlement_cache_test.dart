import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/billing/data/entitlement.dart';

/// Cihazda cache'lenen Pro durumunun guvenlik sinirlari.
///
/// Cache'in tek amaci: RevenueCat configure olana kadarki ilk saniyelerde
/// Pro kullaniciya "free" gostermemek. Bu yuzden SURESI GECMIS bir cache
/// asla Pro dondurmemeli — aksi halde iptal/expire olmus abonelik cihazda
/// suresiz Pro gibi davranirdi.
void main() {
  group('Entitlement cache', () {
    test('roundtrip: JSON serialize/deserialize alanlari korur', () {
      final ent = Entitlement(
        isPro: true,
        expiresAt: DateTime.utc(2030, 1, 1),
        productId: 'com.streambox.app.pro.yearly',
        source: EntitlementSource.appStore,
      );

      final decoded = Entitlement.fromJson(
        jsonDecode(jsonEncode(ent.toJson())) as Map<String, dynamic>,
      );

      expect(decoded, ent);
      expect(decoded.isPro, isTrue);
      expect(decoded.productId, 'com.streambox.app.pro.yearly');
      expect(decoded.source, EntitlementSource.appStore);
    });

    test('suresi gecmis abonelik gecerli SAYILMAZ', () {
      final expired = Entitlement(
        isPro: true,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        productId: 'com.streambox.app.pro.monthly',
      );
      expect(expired.isStillValid, isFalse);
    });

    test('gelecek tarihli abonelik gecerli', () {
      final active = Entitlement(
        isPro: true,
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        productId: 'com.streambox.app.pro.monthly',
      );
      expect(active.isStillValid, isTrue);
    });

    test('lifetime (expiresAt null) gecerli kalir', () {
      const lifetime = Entitlement(
        isPro: true,
        productId: 'com.streambox.app.pro.lifetime',
      );
      expect(lifetime.isStillValid, isTrue);
      expect(lifetime.isLifetime, isTrue);
    });

    test('free entitlement asla gecerli degil', () {
      expect(Entitlement.free.isStillValid, isFalse);
    });

    test('bozuk/eksik JSON free\'e duser, exception atmaz', () {
      final ent = Entitlement.fromJson(<String, dynamic>{});
      expect(ent.isPro, isFalse);
      expect(ent.source, EntitlementSource.unknown);
      expect(ent.isStillValid, isFalse);
    });

    test('gecersiz tarih string\'i null expiresAt olur (lifetime sayilmaz '
        'diye isPro false ile birlikte kontrol edilir)', () {
      final ent = Entitlement.fromJson(<String, dynamic>{
        'isPro': false,
        'expiresAt': 'bu-bir-tarih-degil',
      });
      expect(ent.expiresAt, isNull);
      expect(ent.isStillValid, isFalse);
    });
  });
}
