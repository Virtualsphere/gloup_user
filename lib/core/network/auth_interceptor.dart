import 'package:dio/dio.dart';
import '../constants/api_routes.dart';
import '../utils/local_storage_service.dart';

/// Interceptor to add Authorization header and handle token refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add access token to header if available
    final accessToken = LocalStorageService.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = LocalStorageService.refreshToken;
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Call refresh token API
          final response = await _dio.post(
            ApiRoutes.refreshToken,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Authorization': null}, // Don't add old token
            ),
          );

          if (response.statusCode == 200) {
            // Save new tokens
            final newAccessToken = response.data['accessToken'] as String?;
            final newRefreshToken = response.data['refreshToken'] as String?;
            
            if (newAccessToken != null) {
              await LocalStorageService.setAccessToken(newAccessToken);
            }
            if (newRefreshToken != null) {
              await LocalStorageService.setRefreshToken(newRefreshToken);
            }

            // Retry the original request with new token
            final opts = Options(
              method: err.requestOptions.method,
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $newAccessToken',
              },
            );

            final cloneReq = await _dio.request(
              err.requestOptions.path,
              options: opts,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh token failed - logout user
          await _handleLogout();
        }
      } else {
        // No refresh token - logout user
        await _handleLogout();
      }
    }

    super.onError(err, handler);
  }

  Future<void> _handleLogout() async {
    // Clear all stored data
    await LocalStorageService.clearAll();
    // Navigation to login should be handled by the app
    // You might want to use a global navigation key or event bus
  }
}
