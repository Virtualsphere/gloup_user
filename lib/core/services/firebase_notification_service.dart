import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/router/app_router.dart';
import 'package:tressy/core/router/notification_routes.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/firebase_options.dart';

/// Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Must be a top-level function annotated with @pragma
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await handleRemoteMessage(message, isBackground: true);
}

/// Handles FCM without duplicating notifications the OS already displayed.
Future<void> handleRemoteMessage(
  RemoteMessage message, {
  required bool isBackground,
}) async {
  if (message.notification != null) {
    // Background/killed: Android and iOS already show notification payloads.
    if (isBackground) {
      return;
    }
    // Foreground: iOS presents via [setForegroundNotificationPresentationOptions].
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }
    // Foreground Android: system does not display notification payloads.
    await _showLocalNotification(
      title: message.notification!.title,
      body: message.notification!.body,
      payload: _encodeNotificationPayload(message.data),
      id: message.hashCode,
    );
    return;
  }

  // Data-only message: app must show the notification.
  final title = message.data['title'] ?? message.data['notification_title'];
  final body = message.data['body'] ??
      message.data['message'] ??
      message.data['notification_body'];
  if (title == null && body == null) return;

  await _showLocalNotification(
    title: title,
    body: body,
    payload: _encodeNotificationPayload(message.data),
    id: message.hashCode,
  );
}

/// Shows a local notification from a [RemoteMessage] (legacy entry point).
Future<void> showLocalNotification(RemoteMessage message) async {
  await handleRemoteMessage(message, isBackground: false);
}

String? _encodeNotificationPayload(Map<String, dynamic> data) {
  if (data.isEmpty) return null;
  return jsonEncode(data);
}

Map<String, dynamic> decodeNotificationPayload(String? payload) {
  if (payload == null || payload.isEmpty) return {};

  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {
    // Ignore legacy non-JSON payloads.
  }
  return {};
}

void _scheduleNotificationNavigation(Map<String, dynamic> data) {
  if (data.isEmpty) return;

  SchedulerBinding.instance.scheduleFrameCallback((_) {
    NotificationRoutes.navigateFromData(AppRouter.router, data);
  });
}

/// Test-only counter for [_showLocalNotification] invocations.
@visibleForTesting
int localNotificationShowCallCount = 0;

/// Optional override used by tests to avoid platform notification plugins.
@visibleForTesting
Future<void> Function({
  required String? title,
  required String? body,
  required String? payload,
  required int id,
})? showLocalNotificationOverride;

/// Resets [localNotificationShowCallCount] between tests.
@visibleForTesting
void resetLocalNotificationShowCallCount() {
  localNotificationShowCallCount = 0;
  showLocalNotificationOverride = null;
}

Future<void> _showLocalNotification({
  required String? title,
  required String? body,
  required String? payload,
  required int id,
}) async {
  localNotificationShowCallCount++;
  if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
    return;
  }

  if (showLocalNotificationOverride != null) {
    await showLocalNotificationOverride!(
      title: title,
      body: body,
      payload: payload,
      id: id,
    );
    return;
  }

  const androidDetails = AndroidNotificationDetails(
    'gloup_default_channel',
    'General Notifications',
    channelDescription: 'For showing app notifications',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const darwinDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: darwinDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformDetails,
    payload: payload,
  );
}

/// Initializes Flutter Local Notifications (call before [FirebaseNotificationService.initialize])
Future<void> initializeLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: darwinSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      _scheduleNotificationNavigation(
        decodeNotificationPayload(response.payload),
      );
    },
  );
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final _messaging = FirebaseMessaging.instance;
  static RemoteMessage? _pendingLaunchMessage;

  /// Notification that opened the app from a terminated state (if any).
  static RemoteMessage? takePendingLaunchMessage() {
    final message = _pendingLaunchMessage;
    _pendingLaunchMessage = null;
    return message;
  }

  static void clearPendingLaunchMessage() {
    _pendingLaunchMessage = null;
  }

  static Future<void> initialize() async {
    // Request notification permission
    await requestPermission();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      handleRemoteMessage(message, isBackground: false);
    });

    // Notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _scheduleNotificationNavigation(message.data);
    });

    // iOS: show notifications while app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Cold start from notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingLaunchMessage = initialMessage;
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) async {
      await LocalStorageService.setString(Keys.fcmToken, token);
      await _registerDeviceToken();
    });

    // Fetch FCM token with retry logic
    await _fetchFCMTokenWithRetry();
  }

  /// Saves the FCM token and registers device with backend.
  /// Called after login or when token refreshes.
  static Future<void> _fetchFCMTokenWithRetry() async {
    const maxRetries = 5;
    const retryDelays = [1, 2, 5, 10, 30]; // seconds

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await LocalStorageService.setString(Keys.fcmToken, token);
          await _registerDeviceToken();
          return;
        }
      } catch (_) {
        // Retry on error
      }

      if (attempt < maxRetries - 1) {
        await Future.delayed(Duration(seconds: retryDelays[attempt]));
      }
    }
  }

  /// Call this after the user logs in to ensure the token is registered.
  static Future<void> onUserLogin() async {
    final token = LocalStorageService.getString(Keys.fcmToken);
    if (token != null && token.isNotEmpty) {
      await _registerDeviceToken();
    } else {
      await _fetchFCMTokenWithRetry();
    }
  }

  /// Requests notification permission (call from home screen, not at startup).
  static Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Sends the FCM token to the backend. Runs silently — no toast on success or failure.
  static Future<void> _registerDeviceToken() async {
    final token = LocalStorageService.getString(Keys.fcmToken);
    final accessToken = LocalStorageService.accessToken;
    if (token == null || token.isEmpty) return;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await sl<DioClient>().post(
        ApiRoutes.deviceId,
        data: {'device_id': token},
      );
    } catch (e) {
      debugPrint('[FCM] Failed to register device token: $e');
    }
  }
}
