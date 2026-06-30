import 'dart:async';

import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/network/auth_session_manager.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Injects the `userauth` header and forces logout on 401 for protected routes.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!ApiRoutes.isPublicAuthEndpoint(options.uri)) {
      final token = LocalStorageService.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers[Keys.userAuth] = token;
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldForceLogout(err)) {
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
