import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/constants/api_routes.dart';

void main() {
  group('ApiRoutes auth path helpers', () {
    test('public auth endpoints do not require auth', () {
      expect(
        ApiRoutes.isPublicAuthEndpoint(Uri.parse(ApiRoutes.sendOtp)),
        isTrue,
      );
      expect(
        ApiRoutes.isPublicAuthEndpoint(Uri.parse(ApiRoutes.verifyOtp)),
        isTrue,
      );
      expect(
        ApiRoutes.isPublicAuthEndpoint(Uri.parse(ApiRoutes.googleLogin)),
        isTrue,
      );
      expect(
        ApiRoutes.isPublicAuthEndpoint(Uri.parse(ApiRoutes.appleLogin)),
        isTrue,
      );
    });

    test('protected endpoints require auth', () {
      expect(
        ApiRoutes.requiresAuth(Uri.parse(ApiRoutes.getUserProfile)),
        isTrue,
      );
      expect(
        ApiRoutes.requiresAuth(Uri.parse(ApiRoutes.getBanners)),
        isTrue,
      );
      expect(
        ApiRoutes.requiresAuth(Uri.parse(ApiRoutes.deviceId)),
        isTrue,
      );
      expect(
        ApiRoutes.requiresAuth(Uri.parse(ApiRoutes.logout)),
        isTrue,
      );
    });
  });
}
