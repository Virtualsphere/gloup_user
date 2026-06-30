import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/network/connectivity_status.dart';

void main() {
  group('hasActiveConnectivity', () {
    test('returns false for none only', () {
      expect(
        hasActiveConnectivity([ConnectivityResult.none]),
        isFalse,
      );
    });

    test('returns false for empty list', () {
      expect(hasActiveConnectivity([]), isFalse);
    });

    test('returns true for wifi', () {
      expect(
        hasActiveConnectivity([ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('returns true when wifi and mobile are present', () {
      expect(
        hasActiveConnectivity([
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ]),
        isTrue,
      );
    });

    test('returns true when none is mixed with an active transport', () {
      expect(
        hasActiveConnectivity([
          ConnectivityResult.none,
          ConnectivityResult.mobile,
        ]),
        isTrue,
      );
    });
  });
}
