import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_ai_player/core/utils/secure_storage.dart';

void main() {
  group('BYOK OpenAI key (H4)', () {
    test('stored key without user flag is NOT an own key', () {
      // Eski surum uzak paylasilan anahtari openai_api_key'e yaziyordu.
      expect(SecureStorage.ownKeyFrom(key: 'sk-shared', userFlag: null), '');
      expect(SecureStorage.ownKeyFrom(key: 'sk-shared', userFlag: 'false'), '');
    });

    test('user-entered key (flag true) is returned', () {
      expect(SecureStorage.ownKeyFrom(key: 'sk-mine', userFlag: 'true'), 'sk-mine');
    });

    test('missing key is empty even with flag', () {
      expect(SecureStorage.ownKeyFrom(key: null, userFlag: 'true'), '');
    });

    test('migration purges a cached key only when the user flag is absent', () {
      expect(
          SecureStorage.shouldPurgeLegacyKey(
              migrationDone: false, key: 'sk-shared', userFlag: null),
          isTrue);
      expect(
          SecureStorage.shouldPurgeLegacyKey(
              migrationDone: false, key: 'sk-mine', userFlag: 'true'),
          isFalse);
      expect(
          SecureStorage.shouldPurgeLegacyKey(
              migrationDone: true, key: 'sk-shared', userFlag: null),
          isFalse);
      expect(
          SecureStorage.shouldPurgeLegacyKey(
              migrationDone: false, key: null, userFlag: null),
          isFalse);
    });
  });
}
