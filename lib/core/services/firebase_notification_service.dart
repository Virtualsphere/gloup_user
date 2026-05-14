import 'package:dio/dio.dart' show Options;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/firebase_options.dart';

/// Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Must be a top-level function annotated with @pragma
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await showLocalNotification(message);
}

/// Shows a local notification from a [RemoteMessage]
Future<void> showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

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
    notification.hashCode,
    notification.title,
    notification.body,
    platformDetails,
    payload: message.data.isNotEmpty ? message.data.toString() : null,
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
      // TODO: Handle notification tap / deep link navigation
    },
  );
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request notification permission
    await requestPermission();

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        showLocalNotification(message);
      }
    });

    // Notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // TODO: Handle navigation based on message.data
    });

    // iOS: show notifications while app is in foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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
        options: Options(headers: {'userauth': accessToken}),
      );
    } catch (e) {
      debugPrint('[FCM] Failed to register device token: $e');
    }
  }
}
