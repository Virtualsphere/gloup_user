import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// Pings [ApiRoutes.heartbeat] so admin live stats can count this user as active
/// while the app is in the foreground.
///
/// Backend Redis presence TTL is ~90s; interval stays under that with margin.
class PresenceHeartbeatService with WidgetsBindingObserver {
  PresenceHeartbeatService._();

  static final PresenceHeartbeatService instance = PresenceHeartbeatService._();

  static const Duration _interval = Duration(seconds: 25);

  Timer? _timer;
  bool _started = false;

  /// Register lifecycle observer and start if already logged in.
  static Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(instance);
    if (LocalStorageService.isLoggedIn) {
      await instance.start();
    }
  }

  /// Call right after a successful login (token saved).
  static Future<void> onUserLogin() => instance.start();

  /// Call before clearing the session on logout.
  static Future<void> onUserLogout() => instance.stop(markOffline: true);

  Future<void> start() async {
    if (!LocalStorageService.isLoggedIn) return;
    _started = true;
    await _setOnline(true);
    _restartTimer();
  }

  Future<void> stop({bool markOffline = true}) async {
    _started = false;
    _timer?.cancel();
    _timer = null;
    if (markOffline) {
      await _setOnline(false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started && !LocalStorageService.isLoggedIn) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (LocalStorageService.isLoggedIn) {
          _started = true;
          unawaited(_setOnline(true));
          _restartTimer();
        }
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _timer = null;
        unawaited(_setOnline(false));
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (_started && LocalStorageService.isLoggedIn) {
        unawaited(_setOnline(true));
      }
    });
  }

  Future<void> _setOnline(bool online) async {
    final accessToken = LocalStorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await sl<DioClient>().post(
        ApiRoutes.heartbeat,
        data: {'online': online},
      );
    } catch (e) {
      debugPrint('[Presence] Heartbeat failed (online=$online): $e');
    }
  }
}
