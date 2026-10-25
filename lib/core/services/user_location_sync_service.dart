import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Posts [ApiRoutes.userLocation] so the backend can keep the user's latest
/// point (and attach it to bookings). Does not change order payloads.
class UserLocationSyncService with WidgetsBindingObserver {
  UserLocationSyncService._();

  static final UserLocationSyncService instance = UserLocationSyncService._();

  static const double _minLiveMoveMeters = 500;
  static const Duration _minLiveInterval = Duration(minutes: 15);

  StreamSubscription<Position>? _liveSub;
  DateTime? _lastLiveSentAt;
  double? _lastLiveLat;
  double? _lastLiveLng;
  bool _started = false;

  static Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(instance);
    if (LocalStorageService.isLoggedIn) {
      await instance.start();
    }
  }

  static Future<void> onUserLogin() => instance.start();

  static Future<void> onUserLogout() => instance.stop();

  Future<void> start() async {
    if (!LocalStorageService.isLoggedIn) return;
    _started = true;
    await reportOpenOrLogin();
    _startLiveTracking();
  }

  Future<void> stop() async {
    _started = false;
    await _liveSub?.cancel();
    _liveSub = null;
  }

  /// (1) App open or right after login.
  Future<void> reportOpenOrLogin() async {
    if (!_canPost()) return;

    final gps = await _readGpsIfAllowed();
    if (gps != null) {
      await _post(
        lat: gps.latitude,
        lng: gps.longitude,
        source: 'live',
        recordAsLive: true,
      );
      return;
    }

    final stored = _storedCoordinates();
    if (stored != null) {
      await _post(
        lat: stored.$1,
        lng: stored.$2,
        source: 'live',
      );
    }
  }

  /// (2) User picked or changed their location themselves.
  Future<void> reportManual({
    required double lat,
    required double lng,
  }) async {
    if (!_canPost()) return;
    await _post(lat: lat, lng: lng, source: 'manual');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!LocalStorageService.isLoggedIn && !_started) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (LocalStorageService.isLoggedIn) {
          _started = true;
          unawaited(reportOpenOrLogin());
          _startLiveTracking();
        }
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_liveSub?.cancel());
        _liveSub = null;
    }
  }

  void _startLiveTracking() {
    if (!_started || !LocalStorageService.isLoggedIn) return;
    if (_liveSub != null) return;

    unawaited(_attachLiveStream());
  }

  Future<void> _attachLiveStream() async {
    if (!await _hasLocationPermission()) return;

    await _liveSub?.cancel();
    _liveSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 500,
      ),
    ).listen(
      (position) => unawaited(_onLiveMove(position)),
      onError: (Object e) {
        debugPrint('[LocationSync] live stream error: $e');
      },
    );
  }

  Future<void> _onLiveMove(Position position) async {
    if (!_canPost() || !_started) return;

    final now = DateTime.now();
    if (_lastLiveSentAt != null &&
        now.difference(_lastLiveSentAt!) < _minLiveInterval) {
      return;
    }

    if (_lastLiveLat != null && _lastLiveLng != null) {
      final moved = Geolocator.distanceBetween(
        _lastLiveLat!,
        _lastLiveLng!,
        position.latitude,
        position.longitude,
      );
      if (moved < _minLiveMoveMeters) return;
    }

    await _post(
      lat: position.latitude,
      lng: position.longitude,
      source: 'live',
      recordAsLive: true,
    );
  }

  Future<void> _post({
    required double lat,
    required double lng,
    required String source,
    bool recordAsLive = false,
  }) async {
    if (!_canPost()) return;

    try {
      await sl<DioClient>().post(
        ApiRoutes.userLocation,
        data: {
          'lat': lat,
          'lng': lng,
          'source': source,
        },
      );
      if (recordAsLive) {
        _lastLiveSentAt = DateTime.now();
        _lastLiveLat = lat;
        _lastLiveLng = lng;
      }
    } catch (e) {
      debugPrint('[LocationSync] failed ($source): $e');
    }
  }

  bool _canPost() {
    final token = LocalStorageService.accessToken;
    return LocalStorageService.isLoggedIn &&
        token != null &&
        token.isNotEmpty;
  }

  Future<bool> _hasLocationPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> _readGpsIfAllowed() async {
    try {
      if (!await _hasLocationPermission()) return null;
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('[LocationSync] GPS read failed: $e');
      return null;
    }
  }

  (double, double)? _storedCoordinates() {
    final lat = LocalStorageService.getDouble('user_latitude');
    final lng = LocalStorageService.getDouble('user_longitude');
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }
}
