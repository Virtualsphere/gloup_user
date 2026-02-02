/// API endpoint routes
class ApiRoutes {
  ApiRoutes._();

  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'http://192.168.1.7:8080';
  static const String apiVersion = '$baseUrl/api/v1';

  // Auth Endpoints
  static const String sendOtp = '$apiVersion/auth/otp/send';
  static const String verifyOtp = '$apiVersion/auth/otp/verify';
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // User Endpoints
  static const String userMe = '$apiVersion/users/me';
  static const String profile = '$apiVersion/user/profile';
  static const String updateProfile = '$apiVersion/user/update';
  static const String changePassword = '$apiVersion/user/change-password';
  static const String deleteAccount = '$apiVersion/user/delete';

  // Example Feature Endpoints
  // Add your specific feature endpoints here
  static const String posts = '$apiVersion/posts';
  static String postById(String id) => '$posts/$id';
  
  static const String categories = '$apiVersion/categories';
  static String categoryById(String id) => '$categories/$id';

  // Upload Endpoints
  static const String uploadImage = '$apiVersion/upload/image';
  static const String uploadFile = '$apiVersion/upload/file';

  // Notification Endpoints
  static const String notifications = '$apiVersion/notifications';
  static String notificationById(String id) => '$notifications/$id';
  static const String markNotificationRead = '$apiVersion/notifications/mark-read';

  // Settings Endpoints
  static const String settings = '$apiVersion/settings';
  static const String updateSettings = '$apiVersion/settings/update';

  // Helper method to build URLs with query parameters
  static String withQueryParams(String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;
    
    final queryString = params.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
    
    return '$endpoint?$queryString';
  }

  // Helper method to build pagination URLs
  static String withPagination(String endpoint, {int page = 1, int limit = 10}) {
    return withQueryParams(endpoint, {'page': page, 'limit': limit});
  }
}
