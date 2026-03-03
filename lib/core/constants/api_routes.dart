class ApiRoutes {
  ApiRoutes._();

  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'http://192.168.1.2:5678';
  
  // Image Base URL - For appending to image paths from API
  static const String imageBaseUrl = 'https://v1.gloup.in/images';
  static const String imageProfileUrl = 'https://v1.gloup.in/profilepic';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/user/auth/sendOTP';
  static const String verifyOtp = '$baseUrl/user/auth/verifyOTP';
  
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
  static const String getUserProfile = '$baseUrl/user/app/getuserprofile';

  // Coupons
  static const String getActiveCoupons = '$baseUrl/user/app/v2/get/activecoupons';

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
