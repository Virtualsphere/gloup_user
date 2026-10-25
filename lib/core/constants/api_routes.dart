import 'package:flutter/foundation.dart';
import 'package:tressy/core/utils/app_logger.dart';

class ApiRoutes {
  ApiRoutes._();

  static const String _logTag = 'API';

  /// Override at build/run time: `--dart-define=API_BASE_URL=https://your-api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode ? 'http://169.58.105.116:5678' : 'https://api.v1.gloup.in',
  );

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

  /// Presence ping for admin live active-user counts
  static const String heartbeat = '$baseUrl/user/app/v2/heartbeat';

  /// Latest user location for admin analytics (booking attach is server-side)
  static const String userLocation = '$baseUrl/user/app/v2/location';

  /// Batch app events (screens, taps, rage taps, gestures, searches, filters, cart, checkout)
  static const String appEvents = '$baseUrl/user/app/v2/events';

  /// Install source attribution (Play Install Referrer / UTM link)
  static const String attribution = '$baseUrl/user/app/v2/attribution';

  /// Reason prompts (checkout exit, cancel booking, feedback)
  static const String feedback = '$baseUrl/user/app/v2/feedback';

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
  static const String storeHolidays = '$baseUrl/user/app/v2/store/holidays';

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
  static const String cancelPendingOrder =
      '$baseUrl/user/app/v2/cancel-pending-order';

  // Razorpay
  static const String razorpayKey = 'rzp_live_T01AE9lLGbNxLd';

  // Coupons
  static const String getActiveCoupons =
      '$baseUrl/user/app/v2/get/activecoupons';
  static const String validateCoupon = '$baseUrl/user/app/validatecoupon';

  // Reviews
  static const String addReview = '$baseUrl/user/app/addreview';
  static const String pendingReviews = '$baseUrl/user/app/v2/pending-reviews';
  static const String getReviewsV2 = '$baseUrl/user/app/v2/reviews';

  static String reviewV2ById(int reviewId) =>
      '$baseUrl/user/app/v2/reviews?id=$reviewId';

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
    'heartbeat': heartbeat,
    'userLocation': userLocation,
    'appEvents': appEvents,
    'attribution': attribution,
    'feedback': feedback,
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
    'storeHolidays': storeHolidays,
    'getAllGuests': getAllGuests,
    'addGuest': addGuest,
    'updateGuest': updateGuest,
    'createOrder': createOrder,
    'paymentSuccess': paymentSuccess,
    'cancelPendingOrder': cancelPendingOrder,
    // Profile
    'getUserProfile': getUserProfile,
    'deleteProfile': deleteProfile,
    // Appointments & coupons
    'getAllAppointments': getAllAppointments,
    'getActiveCoupons': getActiveCoupons,
    'validateCoupon': validateCoupon,
    'addReview': addReview,
    'pendingReviews': pendingReviews,
    'getReviewsV2': getReviewsV2,
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

  /// Paths that must not receive the `userauth` header (login / OTP only).
  static const List<String> _publicAuthPathSuffixes = [
    '/user/auth/sendOTP',
    '/user/auth/verifyOTP',
    '/user/auth/googlelogin',
    '/user/auth/appleLogin',
  ];

  /// Tracking paths: never force logout, never block or show errors.
  static const List<String> _trackingPathSuffixes = [
    '/user/app/v2/heartbeat',
    '/user/app/v2/location',
    '/user/app/v2/events',
    '/user/app/v2/attribution',
    '/user/app/v2/feedback',
  ];

  /// Paths that also work logged out (backend reads userauth if present).
  /// A 401 on these must never force user logout.
  static const List<String> _publicDiscoveryPathSuffixes = [
    '/user/app/v2/getbanner',
    '/user/app/v2/getallcategory',
    '/user/app/v2/store/nearby',
    '/user/app/v2/get-all-stores',
    '/user/app/v2/salons/top',
    '/user/app/v2/services/top-categories',
    '/user/app/v2/stores/by-category',
    '/user/app/v2/store/details',
    '/user/app/v2/getslotstatus',
    '/user/app/v2/store/holidays',
    '/user/app/v2/salons/map-markers-clustered',
    '/user/app/v2/get/activecoupons',
    '/user/app/validatecoupon',
  ];

  /// Whether [uri] is a public auth endpoint (no token header).
  static bool isPublicAuthEndpoint(Uri uri) {
    final path = uri.path;
    return _publicAuthPathSuffixes.any(path.endsWith);
  }

  /// Whether [uri] is an analytics/tracking endpoint.
  static bool isTrackingEndpoint(Uri uri) {
    final path = uri.path;
    return _trackingPathSuffixes.any(path.endsWith);
  }

  /// Whether [uri] is a public discovery endpoint (works logged out).
  static bool isPublicDiscoveryEndpoint(Uri uri) {
    final path = uri.path;
    return _publicDiscoveryPathSuffixes.any(path.endsWith);
  }

  /// Whether [uri] strictly requires auth and should trigger session expiry on 401.
  static bool requiresAuth(Uri uri) {
    if (isPublicAuthEndpoint(uri)) return false;
    if (isTrackingEndpoint(uri)) return false;
    if (isPublicDiscoveryEndpoint(uri)) return false;
    return true;
  }

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
