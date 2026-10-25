import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';

/// App Analytics service for queuing and batching events to `POST /user/app/v2/events`.
///
/// Follows Gloup App Tracking Spec:
/// - Batches up to 200 events per request
/// - Flushes every ~30s and when the app goes into the background
/// - Durable queue persisted across app restarts
/// - Completely silent on failure (never alters app flow or displays errors)
class AppAnalyticsService with WidgetsBindingObserver {
  AppAnalyticsService._();

  static final AppAnalyticsService instance = AppAnalyticsService._();

  static const String _storageKey = 'queued_analytics_events';
  static const int _maxBatchSize = 200;
  static const int _maxQueueSize = 1000;
  static const Duration _flushInterval = Duration(seconds: 30);
  static const Duration _maxEventAge = Duration(days: 7);

  Timer? _timer;
  bool _isFlushing = false;
  final List<Map<String, dynamic>> _queue = [];

  // Current screen tracking
  String _currentScreen = 'home';
  DateTime _currentScreenStartTime = DateTime.now();

  String get currentScreen => _currentScreen;

  /// Initialize observer, restore queue, and start timer.
  static Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(instance);
    await instance._loadQueue();
    instance._startTimer();
    if (LocalStorageService.isLoggedIn) {
      unawaited(instance.flush());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_flushInterval, (_) {
      unawaited(flush());
    });
  }

  Future<void> _loadQueue() async {
    try {
      final jsonStr = LocalStorageService.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          final now = DateTime.now();
          _queue.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              // Discard events older than 7 days
              final atStr = item['at']?.toString();
              if (atStr != null) {
                final at = DateTime.tryParse(atStr);
                if (at != null && now.difference(at) > _maxEventAge) {
                  continue;
                }
              }
              _queue.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AppAnalytics] Error loading queue: $e');
    }
  }

  Future<void> _persistQueue() async {
    try {
      if (_queue.isEmpty) {
        await LocalStorageService.remove(_storageKey);
      } else {
        final encoded = jsonEncode(_queue);
        await LocalStorageService.setString(_storageKey, encoded);
      }
    } catch (e) {
      debugPrint('[AppAnalytics] Error saving queue: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _currentScreenStartTime = DateTime.now();
        _startTimer();
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Record screen_view duration before going to background
        final durationMs =
            DateTime.now().difference(_currentScreenStartTime).inMilliseconds;
        if (durationMs > 200) {
          trackScreenView(_currentScreen, durationMs);
        }
        _timer?.cancel();
        _timer = null;
        unawaited(flush());
    }
  }

  /// Change active screen and log `screen_view` event for the previous screen.
  void setCurrentScreen(String newScreen) {
    final sanitized = _cleanText(newScreen, 40) ?? 'home';
    if (_currentScreen == sanitized) return;

    final now = DateTime.now();
    final durationMs = now.difference(_currentScreenStartTime).inMilliseconds;
    if (durationMs > 200) {
      trackScreenView(_currentScreen, durationMs);
    }

    _currentScreen = sanitized;
    _currentScreenStartTime = now;
  }

  int get msSinceScreenOpen =>
      DateTime.now().difference(_currentScreenStartTime).inMilliseconds;

  // ─────────────────── Event Tracking APIs ───────────────────

  /// Track a screen view duration in ms (sent when user leaves the screen).
  void trackScreenView(String screen, int durationMs) {
    _enqueue({
      'type': 'screen_view',
      'screen': _cleanText(screen, 40) ?? _currentScreen,
      'duration_ms': durationMs < 0 ? 0 : durationMs,
      'at': DateTime.now().toIso8601String(),
    });
  }

  /// Track a tap on an element with screen coordinates (share of width/height).
  void trackTap(
    String element, {
    String? screen,
    double? x,
    double? y,
    int? msSinceScreenOpen,
  }) {
    final payload = <String, dynamic>{
      'type': 'tap',
      'screen': _cleanText(screen ?? _currentScreen, 40),
      'element': _cleanText(element, 80),
      'ms_since_screen_open': msSinceScreenOpen ?? this.msSinceScreenOpen,
      'at': DateTime.now().toIso8601String(),
    };
    if (x != null && x >= 0.0 && x <= 1.0) {
      payload['x'] = double.parse(x.toStringAsFixed(4));
    }
    if (y != null && y >= 0.0 && y <= 1.0) {
      payload['y'] = double.parse(y.toStringAsFixed(4));
    }
    _enqueue(payload);
  }

  /// Track rage taps (3+ taps on the same element within 1 second).
  void trackRageTap(String element, {String? screen, required int taps}) {
    _enqueue({
      'type': 'rage_tap',
      'screen': _cleanText(screen ?? _currentScreen, 40),
      'element': _cleanText(element, 80),
      'taps': taps < 3 ? 3 : taps,
      'at': DateTime.now().toIso8601String(),
    });
  }

  /// Track a gesture (long_press, swipe, pull_to_refresh, pinch_zoom, back_swipe).
  void trackGesture(String gesture, {String? screen}) {
    _enqueue({
      'type': 'gesture',
      'screen': _cleanText(screen ?? _currentScreen, 40),
      'gesture': _cleanText(gesture, 80),
      'at': DateTime.now().toIso8601String(),
    });
  }

  /// Track search query and result count.
  void trackSearch(String query, int results, {String screen = 'search'}) {
    _enqueue({
      'type': 'search',
      'screen': _cleanText(screen, 40),
      'query': _cleanText(query, 80),
      'results': results < 0 ? 0 : results,
      'at': DateTime.now().toIso8601String(),
    });
  }

  /// Track filter changes (sort, min_price, max_price, min_rating, category).
  void trackFilter({
    String screen = 'salon_list',
    String? sort,
    num? minPrice,
    num? maxPrice,
    num? minRating,
    String? category,
  }) {
    final payload = <String, dynamic>{
      'type': 'filter',
      'screen': _cleanText(screen, 40),
      'at': DateTime.now().toIso8601String(),
    };
    if (sort != null && sort.isNotEmpty) {
      payload['sort'] = _cleanText(sort, 80);
    }
    if (minPrice != null) payload['min_price'] = minPrice;
    if (maxPrice != null) payload['max_price'] = maxPrice;
    if (minRating != null) payload['min_rating'] = minRating;
    if (category != null && category.isNotEmpty) {
      payload['category'] = _cleanText(category, 40);
    }
    _enqueue(payload);
  }

  /// Track cart changes (action: 'add' or 'remove').
  void trackCart({
    String? screen,
    required String action,
    required int storeId,
    dynamic serviceId,
  }) {
    final payload = <String, dynamic>{
      'type': 'cart',
      'screen': _cleanText(screen ?? _currentScreen, 40),
      'action': action == 'remove' ? 'remove' : 'add',
      'store_id': storeId,
      'at': DateTime.now().toIso8601String(),
    };
    if (serviceId != null) {
      payload['service_id'] = serviceId;
    }
    _enqueue(payload);
  }

  /// Track checkout steps (select_slot, enter_details, apply_coupon, payment_page).
  void trackCheckoutStep(String step, {String screen = 'checkout'}) {
    _enqueue({
      'type': 'checkout_step',
      'screen': _cleanText(screen, 40),
      'step': _cleanText(step, 80),
      'at': DateTime.now().toIso8601String(),
    });
  }

  // ─────────────────── Internal Queuing & Flushing ───────────────────

  void _enqueue(Map<String, dynamic> event) {
    if (_queue.length >= _maxQueueSize) {
      _queue.removeAt(0); // Drop oldest to avoid unlimited growth
    }
    _queue.add(event);
    unawaited(_persistQueue());
  }

  /// Send queued events to the backend in batches of up to 200.
  Future<void> flush() async {
    if (_isFlushing || _queue.isEmpty) return;
    if (!LocalStorageService.isLoggedIn) return;

    _isFlushing = true;
    try {
      while (_queue.isNotEmpty && LocalStorageService.isLoggedIn) {
        final batch = _queue.take(_maxBatchSize).toList();
        final response = await sl<DioClient>().post(
          ApiRoutes.appEvents,
          data: {'events': batch},
        );

        if (response.statusCode == 200) {
          // Remove successfully processed events
          _queue.removeRange(0, batch.length);
          await _persistQueue();
        } else {
          // Stop this flush cycle on unexpected non-200; keep queue for next time
          break;
        }
      }
    } catch (e) {
      debugPrint('[AppAnalytics] Flush failed (silently keeping queue): $e');
    } finally {
      _isFlushing = false;
    }
  }

  static String? _cleanText(String? value, int maxLen) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxLen ? trimmed.substring(0, maxLen) : trimmed;
  }
}

