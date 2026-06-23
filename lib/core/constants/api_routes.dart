import 'package:flutter/foundation.dart';
import 'package:tressy/core/utils/app_logger.dart';

class ApiRoutes {
  ApiRoutes._();

  static const String _logTag = 'API';

  // Base URL - Update this with your actual API base URL
  static const String baseUrl = 'https://api.v1.gloup.in';
  // static const String baseUrl = 'http://10.118.63.79:5678';

  // Image Base URL - For appending to image paths from API
  static const String imageBaseUrl =
      'https://storage.googleapis.com/gloup-images';
  static const String bannerImageBaseUrl =
      'https://storage.googleapis.com/gloup-images';
  static const String categoryImageBaseUrl =
      'https://storage.googleapis.com/gloup-images';
  static const String imageProfileUrl =
      'https://storage.googleapis.com/gloup-images';

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
  static const String getTopCategories =
      '$baseUrl/user/app/v2/services/top-categories';
  static const String getStoresByCategory =
      '$baseUrl/user/app/v2/stores/by-category';

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
  static const String getAllAppointments =
      '$baseUrl/user/app/getallapointments';

  // Order
  static const String createOrder = '$baseUrl/user/app/v2/createorder';
  static const String paymentSuccess = '$baseUrl/user/app/v2/paymentsuccess';

  // Razorpay
  static const String razorpayKey = 'rzp_live_T01AE9lLGbNxLd';

  // Coupons
  static const String getActiveCoupons =
      '$baseUrl/user/app/v2/get/activecoupons';

  // Map Markers (Clustered)
  static const String mapMarkersClustered =
      '$baseUrl/user/app/v2/salons/map-markers-clustered';

  /// Human-readable name → full URL for every Gloup backend endpoint.
  static const Map<String, String> registeredEndpoints = {
    // Auth
    'sendOtp': sendOtp,
    'verifyOtp': verifyOtp,
    'deviceId': deviceId,
    'googleLogin': googleLogin,
    'appleLogin': appleLogin,
    'logout': logout,
    // Home & discovery
    'getBanners': getBanners,
    'getCategories': getCategories,
    'getNearbyStores': getNearbyStores,
    'getAllStores': getAllStores,
    'getTopSalons': getTopSalons,
    'getTopCategories': getTopCategories,
    'getStoresByCategory': getStoresByCategory,
    // Favorites
    'toggleFavorite': toggleFavorite,
    'getFavorites': getFavorites,
    // Salon
    'getStoreDetails': getStoreDetails,
    'mapMarkersClustered': mapMarkersClustered,
    // Booking
    'getSlotStatus': getSlotStatus,
    'getAllGuests': getAllGuests,
    'addGuest': addGuest,
    'updateGuest': updateGuest,
    'createOrder': createOrder,
    'paymentSuccess': paymentSuccess,
    // Profile
    'getUserProfile': getUserProfile,
    'deleteProfile': deleteProfile,
    // Appointments & coupons
    'getAllAppointments': getAllAppointments,
    'getActiveCoupons': getActiveCoupons,
  };

  /// External APIs used outside Dio (e.g. Google Places).
  static const Map<String, String> externalEndpoints = {
    'googlePlacesNearbySearch':
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
    'googlePlacesAutocomplete':
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
    'googlePlacesDetails':
        'https://maps.googleapis.com/maps/api/place/details/json',
  };

  /// Resolves a friendly endpoint name from a request URL (ignores query string).
  static String? nameForUrl(String url) {
    final pathOnly = url.split('?').first;
    for (final entry in registeredEndpoints.entries) {
      if (pathOnly == entry.value) return entry.key;
    }
    for (final entry in externalEndpoints.entries) {
      if (pathOnly.startsWith(entry.value)) return entry.key;
    }
    return null;
  }

  /// Prints the full API catalog once at startup (debug builds only).
  static void logRegisteredEndpoints() {
    if (!kDebugMode) return;

    AppLogger.info(
      '══════════ Gloup API catalog (${registeredEndpoints.length} backend) ══════════',
      tag: _logTag,
    );
    registeredEndpoints.forEach((name, url) {
      AppLogger.info('  $name → $url', tag: _logTag);
    });

    AppLogger.info(
      '────────── External APIs (${externalEndpoints.length}) ──────────',
      tag: _logTag,
    );
    externalEndpoints.forEach((name, url) {
      AppLogger.info('  $name → $url', tag: _logTag);
    });
    AppLogger.info('══════════════════════════════════════════════════════',
        tag: _logTag);
  }

  // Helper method to build URLs with query parameters
  static String withQueryParams(String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;

    final queryString = params.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return '$endpoint?$queryString';
  }

  // Helper method to build pagination URLs
  static String withPagination(String endpoint,
      {int page = 1, int limit = 10}) {
    return withQueryParams(endpoint, {'page': page, 'limit': limit});
  }
}
