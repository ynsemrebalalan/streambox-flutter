import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/data/repositories/channel_repository.dart';
import 'package:iptv_ai_player/features/settings/logic/feedback_logic.dart';
import 'package:iptv_ai_player/features/settings/logic/locale_label.dart';
import 'package:iptv_ai_player/features/settings/logic/review_policy.dart';
import 'package:iptv_ai_player/l10n/generated/app_localizations.dart';

void main() {
  group('shouldRequestReview (Android ReviewHelper)', () {
    const day = 24 * 3600 * 1000;
    const now = 1000 * day;
    test('5 basarili oynatmadan once istenmez', () {
      expect(shouldRequestReview(successfulPlaybacks: 4, lastShownMs: 0, nowMs: now),
          isFalse);
    });
    test('5. oynatmada ilk kez istenir', () {
      expect(shouldRequestReview(successfulPlaybacks: 5, lastShownMs: 0, nowMs: now),
          isTrue);
    });
    test('90 gun dolmadan tekrar istenmez', () {
      expect(
          shouldRequestReview(
              successfulPlaybacks: 50, lastShownMs: now - 89 * day, nowMs: now),
          isFalse);
      expect(
          shouldRequestReview(
              successfulPlaybacks: 50, lastShownMs: now - 90 * day, nowMs: now),
          isTrue);
    });
  });

  group('feedback form', () {
    test('e-posta format kontrolu', () {
      expect(isValidFeedbackEmail('a@b.co'), isTrue);
      expect(isValidFeedbackEmail(' a.b+c@mail.example.com '), isTrue);
      expect(isValidFeedbackEmail('a@b'), isFalse);
      expect(isValidFeedbackEmail('ab.com'), isFalse);
      expect(isValidFeedbackEmail(''), isFalse);
    });
    test('gonderilebilir: e-posta gecerli + mesaj dolu + gonderimde degil', () {
      expect(canSendFeedback(email: 'a@b.co', message: 'hi', sending: false), isTrue);
      expect(canSendFeedback(email: 'a@b.co', message: '  ', sending: false), isFalse);
      expect(canSendFeedback(email: 'bad', message: 'hi', sending: false), isFalse);
      expect(canSendFeedback(email: 'a@b.co', message: 'hi', sending: true), isFalse);
    });
    test('5 MB ustu gorsel atlanir', () {
      expect(isFeedbackImageAllowed(5 * 1024 * 1024), isTrue);
      expect(isFeedbackImageAllowed(5 * 1024 * 1024 + 1), isFalse);
      expect(isFeedbackImageAllowed(0), isFalse);
    });
    test('belge semasi Android ile ayni + platform ios', () {
      final doc = buildFeedbackDoc(
        name: '  ',
        email: 'a@b.co',
        message: 'msg',
        type: 'Öneri',
        imageUrls: const [],
        device: 'Apple iPhone15,2',
        osVersion: '18.1',
        appVersion: '2.0.2',
        nowMs: 42,
      );
      expect(doc['message'], 'msg');
      expect(doc['type'], 'Öneri');
      expect(doc['email'], 'a@b.co');
      expect(doc.containsKey('name'), isFalse);
      expect(doc.containsKey('imageUrls'), isFalse);
      expect(doc['device'], 'Apple iPhone15,2');
      expect(doc['androidApi'], 0);
      expect(doc['appVersion'], '2.0.2');
      expect(doc['timestamp'], 42);
      expect(doc['platform'], 'ios');
      expect(doc['osVersion'], '18.1');

      final withExtras = buildFeedbackDoc(
        name: 'Ali',
        email: 'a@b.co',
        message: 'm',
        type: 't',
        imageUrls: const ['u1'],
        device: 'd',
        osVersion: 'o',
        appVersion: 'v',
        nowMs: 1,
      );
      expect(withExtras['name'], 'Ali');
      expect(withExtras['imageUrls'], ['u1']);
    });
  });

  group('localeLabel (dil secici etiketi)', () {
    final l = lookupAppLocalizations(const Locale('en'));
    test('her desteklenen dil kendi etiketini gosterir', () {
      expect(localeLabel(l, const Locale('es')), l.languageSpanish);
      expect(localeLabel(l, const Locale('ro')), l.languageRomanian);
      expect(localeLabel(l, const Locale('tr')), l.languageTurkish);
      expect(localeLabel(l, const Locale('en')), l.languageEnglish);
      expect(localeLabel(l, const Locale('de')), l.languageGerman);
      expect(localeLabel(l, const Locale('it')), l.languageItalian);
      expect(localeLabel(l, const Locale('ar')), l.languageArabic);
    });
    test('null → sistem dili', () {
      expect(localeLabel(l, null), l.languageSystem);
    });
  });

  group('ChannelRepository.positionLocalValues', () {
    test('lastPosition + lastWatched yazilir, kisa sure duration yazmaz', () {
      final v = ChannelRepository.positionLocalValues(5000, 8000, nowMs: 99);
      expect(v, {'lastPosition': 5000, 'lastWatched': 99});
    });
    test('10 sn ustu sure duration da yazilir', () {
      final v = ChannelRepository.positionLocalValues(5000, 60000, nowMs: 99);
      expect(v['duration'], 60000);
    });
  });
}
