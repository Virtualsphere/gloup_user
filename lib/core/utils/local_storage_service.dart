import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tressy/core/utils/access_token_migration.dart';

/// Service for managing local storage.
///
/// Non-sensitive flags use [SharedPreferences]. The auth access token uses
/// [FlutterSecureStorage] (Keychain / EncryptedSharedPreferences).
class LocalStorageService {
  LocalStorageService._();

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _legacyAccessTokenKey = 'access_token';
  static const String _secureAccessTokenKey = 'access_token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static SharedPreferences? _preferences;
  static String? _cachedAccessToken;
  static bool _accessTokenCacheReady = false;

  /// Initialize preferences, migrate any legacy token, and warm the token cache.
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await _migrateLegacyAccessTokenIfNeeded();
    await _refreshAccessTokenCache();
  }

  /// Check if preferences are initialized.
  static SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception(
        'LocalStorageService not initialized. Call init() first.',
      );
    }
    return _preferences!;
  }

  // Onboarding
  static bool get hasCompletedOnboarding =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingCompleted, value);
  }

  // Authentication
  static bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  // Token management (secure storage + in-memory cache for sync reads)
  static String? get accessToken {
    if (!_accessTokenCacheReady) return null;
    return _cachedAccessToken;
  }

  static Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: _secureAccessTokenKey, value: token);
    _cachedAccessToken = token;
    _accessTokenCacheReady = true;
    await _prefs.remove(_legacyAccessTokenKey);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _secureAccessTokenKey);
    _cachedAccessToken = null;
    _accessTokenCacheReady = true;
    await _prefs.remove(_legacyAccessTokenKey);
  }

  /// Clear all data (logout).
  static Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.delete(key: _secureAccessTokenKey);
    _cachedAccessToken = null;
    _accessTokenCacheReady = true;
  }

  // Generic methods (SharedPreferences only)
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

  static Future<void> _migrateLegacyAccessTokenIfNeeded() async {
    await migrateLegacyAccessToken(
      legacyToken: _prefs.getString(_legacyAccessTokenKey),
      readSecure: () => _secureStorage.read(key: _secureAccessTokenKey),
      writeSecure: (token) =>
          _secureStorage.write(key: _secureAccessTokenKey, value: token),
      removeLegacy: () => _prefs.remove(_legacyAccessTokenKey),
    );
  }

  static Future<void> _refreshAccessTokenCache() async {
    _cachedAccessToken = await _secureStorage.read(key: _secureAccessTokenKey);
    _accessTokenCacheReady = true;
  }
}
