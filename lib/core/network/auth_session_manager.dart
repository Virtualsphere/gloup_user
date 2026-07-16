import 'package:tressy/core/utils/local_storage_service.dart';

typedef SessionExpiredCallback = Future<void> Function();

/// Coordinates forced logout when the API returns 401 on protected routes.
class AuthSessionManager {
  AuthSessionManager._();

  static SessionExpiredCallback? onSessionExpired;
  static bool _handling = false;

  static Future<void> handleSessionExpired() async {
    if (_handling) return;
    _handling = true;
    try {
      await LocalStorageService.clearTokens();
      await LocalStorageService.setLoggedIn(false);
      final callback = onSessionExpired;
      if (callback != null) {
        await callback();
      }
    } finally {
      _handling = false;
    }
  }
}
