import 'dart:async';

import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/network/auth_session_manager.dart';
import 'package:tressy/core/services/app_version_service.dart';
import 'package:tressy/core/services/presence_heartbeat_service.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Injects `userauth`, `X-App-Version`, and `X-Platform` headers,
/// and forces logout on 401 for strictly protected routes.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only attach backend headers if request is going to our backend
    final uri = options.uri;
    final isBackend = _isGloupBackend(uri);

    if (isBackend) {
      // 1. Send app version and platform headers on every request
      options.headers['X-App-Version'] = AppVersionService.appVersion;
      options.headers['X-Platform'] = AppVersionService.platform;

      // 2. Attach userauth when logged in (including public/discovery calls)
      if (!ApiRoutes.isPublicAuthEndpoint(uri)) {
        final token = LocalStorageService.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers[Keys.userAuth] = token;
        }
      }
    }

    handler.next(options);
  }

  static bool _isGloupBackend(Uri uri) {
    final uriStr = uri.toString();
    if (uriStr.startsWith(ApiRoutes.baseUrl)) return true;
    for (final ext in ApiRoutes.externalEndpoints.values) {
      if (uriStr.startsWith(ext)) return false;
    }
    return uri.path.startsWith('/user/');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldForceLogout(err)) {
      unawaited(PresenceHeartbeatService.instance.stop(markOffline: false));
      unawaited(UserLocationSyncService.instance.stop());
      unawaited(AuthSessionManager.handleSessionExpired());
    }
    handler.next(err);
  }

  static bool _shouldForceLogout(DioException err) {
    if (!ApiRoutes.requiresAuth(err.requestOptions.uri)) return false;
    return _isUnauthorizedResponse(err.response);
  }

  static bool _isUnauthorizedResponse(Response<dynamic>? response) {
    if (response == null) return false;

    if (response.statusCode == 401) return true;

    final data = response.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['type'] == 'UnauthorizedException') {
        return true;
      }
    }
    return false;
  }
}
