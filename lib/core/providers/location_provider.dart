import 'package:flutter/foundation.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Global Location Provider
/// Manages user's current location across the app with persistence
class LocationProvider extends ChangeNotifier {
  // Storage keys
  static const String _keyLatitude = 'user_latitude';
  static const String _keyLongitude = 'user_longitude';
  static const String _keyCity = 'user_city';
  static const String _keyArea = 'user_area';

  // Default coordinates (Chennai)
  static const double _defaultLatitude = 13.0827;
  static const double _defaultLongitude = 80.2707;
  static const String _defaultCity = 'Chennai';
  static const String _defaultArea = '';

  // Private state
  double _latitude = _defaultLatitude;
  double _longitude = _defaultLongitude;
  String _city = _defaultCity;
  String _area = _defaultArea;
  bool _isLoading = false;
  
  // Track if location was just updated (for showing toast)
  bool _locationJustUpdated = false;
  String? _lastUpdateMessage;

  /// Constructor - loads saved location from SharedPreferences
  LocationProvider() {
    _loadFromStorage();
  }

  // Getters
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get city => _city;
  String get area => _area;
  bool get isLoading => _isLoading;
  bool get locationJustUpdated => _locationJustUpdated;
  String? get lastUpdateMessage => _lastUpdateMessage;
  
  /// Full address string
  String get fullAddress {
    if (_area.isNotEmpty && _city.isNotEmpty) {
      return '$_area, $_city';
    } else if (_city.isNotEmpty) {
      return _city;
    }
    return 'Select location';
  }

  /// Check if user has set a custom location
  bool get hasCustomLocation {
    return _latitude != _defaultLatitude || _longitude != _defaultLongitude;
  }

  /// Load location from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      _latitude = LocalStorageService.getDouble(_keyLatitude) ?? _defaultLatitude;
      _longitude = LocalStorageService.getDouble(_keyLongitude) ?? _defaultLongitude;
      _city = LocalStorageService.getString(_keyCity) ?? _defaultCity;
      _area = LocalStorageService.getString(_keyArea) ?? _defaultArea;

      debugPrint('LocationProvider: Loaded from storage - $_city, $_area ($_latitude, $_longitude)');
    } catch (e) {
      debugPrint('LocationProvider: Error loading from storage: $e');
      // Keep default values on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update location and save to SharedPreferences
  /// This will notify all listeners and trigger UI rebuilds
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? city,
    String? area,
    bool silent = false, // If true, don't show toast notification
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if location actually changed
      final locationChanged = _latitude != latitude || _longitude != longitude;
      final cityChanged = city != null && _city != city;

      // Update state
      _latitude = latitude;
      _longitude = longitude;
      if (city != null) _city = city;
      if (area != null) _area = area;

      // Save to SharedPreferences
      await LocalStorageService.setDouble(_keyLatitude, latitude);
      await LocalStorageService.setDouble(_keyLongitude, longitude);
      if (city != null) {
        await LocalStorageService.setString(_keyCity, city);
      }
      if (area != null) {
        await LocalStorageService.setString(_keyArea, area);
      }

      // Set flag for toast notification
      if (!silent && (locationChanged || cityChanged)) {
        _locationJustUpdated = true;
        _lastUpdateMessage = 'Location updated to $_city';
      }

      debugPrint('LocationProvider: Updated location - $_city, $_area ($_latitude, $_longitude)');
    } catch (e) {
      debugPrint('LocationProvider: Error updating location: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Triggers UI rebuild in all listening widgets
    }
  }
  
  /// Clear the location update flag (call after showing toast)
  void clearUpdateFlag() {
    _locationJustUpdated = false;
    _lastUpdateMessage = null;
  }

  /// Reset to default location
  Future<void> resetToDefault() async {
    await updateLocation(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      city: _defaultCity,
      area: _defaultArea,
    );
  }

  /// Clear location data from storage
  Future<void> clearLocation() async {
    try {
      await LocalStorageService.remove(_keyLatitude);
      await LocalStorageService.remove(_keyLongitude);
      await LocalStorageService.remove(_keyCity);
      await LocalStorageService.remove(_keyArea);

      _latitude = _defaultLatitude;
      _longitude = _defaultLongitude;
      _city = _defaultCity;
      _area = _defaultArea;

      notifyListeners();
      debugPrint('LocationProvider: Cleared location data');
    } catch (e) {
      debugPrint('LocationProvider: Error clearing location: $e');
    }
  }

  /// Update only city and area (keeps same coordinates)
  Future<void> updateAddress({
    required String city,
    required String area,
  }) async {
    _city = city;
    _area = area;

    await LocalStorageService.setString(_keyCity, city);
    await LocalStorageService.setString(_keyArea, area);

    notifyListeners();
    debugPrint('LocationProvider: Updated address - $city, $area');
  }

  @override
  String toString() {
    return 'LocationProvider(lat: $_latitude, lng: $_longitude, city: $_city, area: $_area)';
  }
}
