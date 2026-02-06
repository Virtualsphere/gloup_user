import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences
class LocalStorageService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAccessToken = 'access_token';

  static SharedPreferences? _preferences;

  /// Initialize the service
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Check if preferences are initialized
  static SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // Onboarding
  static bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboardingCompleted) ?? false;
  
  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingCompleted, value);
  }

  // Authentication
  static bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  // Token Management
  static String? get accessToken => _prefs.getString(_keyAccessToken);
  
  static Future<void> setAccessToken(String token) async {
    await _prefs.setString(_keyAccessToken, token);
  }


  static Future<void> clearTokens() async {
    await _prefs.remove(_keyAccessToken);
  }


  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Generic methods
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
