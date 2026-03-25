class ApiRoutes {
  ApiRoutes._();

  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'https://api.v1.gloup.in';
  // static const String baseUrl = 'http://192.168.1.14:5678';
  
  // Image Base URL - For appending to image paths from API
  static const String imageBaseUrl = 'https://cdn.gloup.in/uploads/common/store';
  static const String bannerImageBaseUrl = 'https://cdn.gloup.in/uploads/common/banner';
  static const String categoryImageBaseUrl = 'https://cdn.gloup.in/uploads/common/category';
  static const String imageProfileUrl = 'https://cdn.gloup.in/uploads/common/profile-pictures';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/user/auth/sendOTP';
  static const String verifyOtp = '$baseUrl/user/auth/verifyOTP';
  static const String deviceId = '$baseUrl/user/auth/deviceId';
  static const String googleLogin = '$baseUrl/user/auth/googlelogin';
  static const String appleLogin = '$baseUrl/user/auth/appleLogin';
  static const String logout = '$baseUrl/user/auth/logout';
  
  // Home Endpoints
  static const String getBanners = '$baseUrl/user/app/v2/getbanner';
  static const String getCategories = '$baseUrl/user/app/v2/getallcategory';
  static const String getNearbyStores = '$baseUrl/user/app/v2/store/nearby';
  static const String getAllStores = '$baseUrl/user/app/v2/get-all-stores';
  static const String getTopSalons = '$baseUrl/user/app/v2/salons/top';
  
  // Favorites Endpoints
  static const String toggleFavorite = '$baseUrl/user/app/v2/favourites';
  static const String getFavorites = '$baseUrl/user/app/v2/favourites';

  // Salon Details Endpoints
  static const String getStoreDetails = '$baseUrl/user/app/v2/store/details';

  // Slot Booking Endpoints
  static const String getSlotStatus = '$baseUrl/user/app/v2/getslotstatus';

  // Guest Endpoints
  static const String getAllGuests = '$baseUrl/user/app/v2/guest/all';
  static const String addGuest = '$baseUrl/user/app/v2/guest/add';
  static const String updateGuest = '$baseUrl/user/app/v2/guest/update';
  //profile
  static const String getUserProfile = '$baseUrl/user/app/v2/profile';
  static const String deleteProfile = '$baseUrl/user/app/v2/profile';

  // Appointments
  static const String getAllAppointments = '$baseUrl/user/app/getallapointments';

  // Order
  static const String createOrder = '$baseUrl/user/app/v2/createorder';
  static const String paymentSuccess = '$baseUrl/user/app/v2/paymentsuccess';

  // Razorpay
  static const String razorpayKey = 'rzp_live_T01AE9lLGbNxLd';

  // Coupons
  static const String getActiveCoupons = '$baseUrl/user/app/v2/get/activecoupons';

  // Map Markers (Clustered)
  static const String mapMarkersClustered = '$baseUrl/user/app/v2/salons/map-markers-clustered';

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
