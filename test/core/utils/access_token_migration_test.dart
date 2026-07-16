import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/utils/access_token_migration.dart';

void main() {
  group('migrateLegacyAccessToken', () {
    test('does nothing when legacy token is null', () async {
      var writeCount = 0;
      var removeCount = 0;

      final migrated = await migrateLegacyAccessToken(
        legacyToken: null,
        readSecure: () async => null,
        writeSecure: (_) async => writeCount++,
        removeLegacy: () async => removeCount++,
      );

      expect(migrated, isFalse);
      expect(writeCount, 0);
      expect(removeCount, 0);
    });

    test('does nothing when legacy token is empty', () async {
      var writeCount = 0;
      var removeCount = 0;

      final migrated = await migrateLegacyAccessToken(
        legacyToken: '',
        readSecure: () async => null,
        writeSecure: (_) async => writeCount++,
        removeLegacy: () async => removeCount++,
      );

      expect(migrated, isFalse);
      expect(writeCount, 0);
      expect(removeCount, 0);
    });

    test('writes legacy token to secure storage and removes legacy copy',
        () async {
      String? secureValue;
      var removeCount = 0;

      final migrated = await migrateLegacyAccessToken(
        legacyToken: 'legacy-jwt-token',
        readSecure: () async => secureValue,
        writeSecure: (token) async => secureValue = token,
        removeLegacy: () async => removeCount++,
      );

      expect(migrated, isTrue);
      expect(secureValue, 'legacy-jwt-token');
      expect(removeCount, 1);
    });

    test('keeps existing secure token and still removes legacy copy', () async {
      var writeCount = 0;
      var removeCount = 0;

      final migrated = await migrateLegacyAccessToken(
        legacyToken: 'legacy-jwt-token',
        readSecure: () async => 'already-secure-token',
        writeSecure: (_) async => writeCount++,
        removeLegacy: () async => removeCount++,
      );

      expect(migrated, isTrue);
      expect(writeCount, 0);
      expect(removeCount, 1);
    });
  });
}
