import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/services/firebase_notification_service.dart';

void main() {
  setUp(() {
    resetLocalNotificationShowCallCount();
    showLocalNotificationOverride = ({
      required title,
      required body,
      required payload,
      required id,
    }) async {};
  });

  group('handleRemoteMessage', () {
    test('does not show local notification for notification payload in background',
        () async {
      final message = RemoteMessage(
        notification: const RemoteNotification(
          title: 'Booking confirmed',
          body: 'Your appointment is set',
        ),
        messageId: 'msg-1',
      );

      await handleRemoteMessage(message, isBackground: true);

      expect(localNotificationShowCallCount, 0);
    });

    test(
      'does not show local notification for notification payload on iOS foreground',
      () async {
        if (defaultTargetPlatform != TargetPlatform.iOS) {
          return;
        }

        final message = RemoteMessage(
          notification: const RemoteNotification(
            title: 'Booking confirmed',
            body: 'Your appointment is set',
          ),
          messageId: 'msg-2',
        );

        await handleRemoteMessage(message, isBackground: false);

        expect(localNotificationShowCallCount, 0);
      },
    );

    test('shows local notification for data-only payload in background', () async {
      final message = RemoteMessage(
        data: const {
          'title': 'Promo',
          'body': '20% off today',
        },
        messageId: 'msg-3',
      );

      await handleRemoteMessage(message, isBackground: true);

      expect(localNotificationShowCallCount, 1);
    });

    test('skips local notification when data-only payload has no title or body',
        () async {
      final message = RemoteMessage(
        data: const {'type': 'booking'},
        messageId: 'msg-4',
      );

      await handleRemoteMessage(message, isBackground: true);

      expect(localNotificationShowCallCount, 0);
    });
  });
}
