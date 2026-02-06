class ApiRoutes {
  ApiRoutes._();

  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'https://api.gloup.in';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/user/auth/sendOTP';
  static const String verifyOtp = '$baseUrl/user/auth/verifyOTP';


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
