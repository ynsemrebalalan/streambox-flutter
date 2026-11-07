import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/features/player/logic/ai_error.dart';
import 'package:iptv_ai_player/features/player/logic/ai_error_messages.dart';
import 'package:iptv_ai_player/l10n/generated/app_localizations.dart';

void main() {
  group('mapAiHttpError (proxy)', () {
    test('403 PRO_REQUIRED → proRequired, not transient', () {
      final e = mapAiHttpError(
          status: 403, body: '{"error":"PRO_REQUIRED","trialEndsAt":1}', viaProxy: true);
      expect(e.code, AiErrorCode.proRequired);
      expect(e.transient, isFalse);
    });

    test('403 other → rejected', () {
      final e = mapAiHttpError(status: 403, body: 'forbidden', viaProxy: true);
      expect(e.code, AiErrorCode.rejected);
    });

    test('401 TOKEN_INVALID → unauthorized, transient (token refresh)', () {
      final e = mapAiHttpError(
          status: 401, body: '{"error":"TOKEN_INVALID"}', viaProxy: true);
      expect(e.code, AiErrorCode.unauthorized);
      expect(e.transient, isTrue);
    });

    test('429 quota → quota, not transient', () {
      final e = mapAiHttpError(status: 429, body: 'Daily QUOTA exceeded', viaProxy: true);
      expect(e.code, AiErrorCode.quota);
      expect(e.transient, isFalse);
    });

    test('429 without quota → busy, transient', () {
      final e = mapAiHttpError(status: 429, body: 'rate limited', viaProxy: true);
      expect(e.code, AiErrorCode.busy);
      expect(e.transient, isTrue);
    });

    test('5xx → server, transient', () {
      for (final s in [500, 502, 503, 504]) {
        final e = mapAiHttpError(status: s, body: '', viaProxy: true);
        expect(e.code, AiErrorCode.server, reason: '$s');
        expect(e.transient, isTrue);
      }
    });

    test('other 4xx → rejected', () {
      expect(mapAiHttpError(status: 400, body: '', viaProxy: true).code,
          AiErrorCode.rejected);
    });
  });

  group('mapAiHttpError (own OpenAI key)', () {
    test('401 → invalidKey, not transient', () {
      final e = mapAiHttpError(status: 401, body: '', viaProxy: false);
      expect(e.code, AiErrorCode.invalidKey);
      expect(e.transient, isFalse);
    });
  });

  group('mapDioException', () {
    final ro = RequestOptions(path: '/x');
    test('connection timeout → timeout transient', () {
      final e = mapDioException(
          DioException(requestOptions: ro, type: DioExceptionType.connectionTimeout),
          viaProxy: true);
      expect(e.code, AiErrorCode.timeout);
      expect(e.transient, isTrue);
    });
    test('receive timeout → timeout', () {
      expect(
          mapDioException(
                  DioException(requestOptions: ro, type: DioExceptionType.receiveTimeout),
                  viaProxy: true)
              .code,
          AiErrorCode.timeout);
    });
    test('connection error → network', () {
      final e = mapDioException(
          DioException(requestOptions: ro, type: DioExceptionType.connectionError),
          viaProxy: true);
      expect(e.code, AiErrorCode.network);
      expect(e.transient, isTrue);
    });
    test('bad response delegates to HTTP mapping', () {
      final e = mapDioException(
          DioException(
              requestOptions: ro,
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                  requestOptions: ro, statusCode: 403, data: '{"error":"PRO_REQUIRED"}')),
          viaProxy: true);
      expect(e.code, AiErrorCode.proRequired);
    });
  });

  group('retryOnceIfTransient', () {
    test('retries exactly once on transient error and returns second result', () async {
      var calls = 0;
      final r = await retryOnceIfTransient<int>(() async {
        calls++;
        if (calls == 1) throw const AiError(AiErrorCode.network, transient: true);
        return 42;
      }, delay: Duration.zero);
      expect(r, 42);
      expect(calls, 2);
    });

    test('does not retry permanent error', () async {
      var calls = 0;
      await expectLater(
        retryOnceIfTransient<int>(() async {
          calls++;
          throw const AiError(AiErrorCode.proRequired);
        }, delay: Duration.zero),
        throwsA(isA<AiError>()),
      );
      expect(calls, 1);
    });

    test('second transient failure is rethrown', () async {
      var calls = 0;
      await expectLater(
        retryOnceIfTransient<int>(() async {
          calls++;
          throw const AiError(AiErrorCode.busy, transient: true);
        }, delay: Duration.zero),
        throwsA(isA<AiError>()),
      );
      expect(calls, 2);
    });
  });

  group('aiErrorMessage', () {
    test('every code has a non-empty localized message in all locales', () async {
      for (final loc in AppLocalizations.supportedLocales) {
        final l = await AppLocalizations.delegate.load(loc);
        for (final c in AiErrorCode.values) {
          expect(aiErrorMessage(l, c), isNotEmpty, reason: '$loc $c');
        }
      }
    });
    test('english pro_required text matches Android wording', () async {
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      expect(aiErrorMessage(l, AiErrorCode.proRequired), contains('Pro'));
    });
  });
}
