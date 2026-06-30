import 'package:flutter_test/flutter_test.dart';
import 'package:tressy/core/router/notification_routes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/services/firebase_notification_service.dart'
    show decodeNotificationPayload;

void main() {
  group('NotificationRoutes.resolve', () {
    test('returns null for empty data', () {
      expect(NotificationRoutes.resolve({}), isNull);
    });

    test('maps booking type to bookings tab', () {
      final target = NotificationRoutes.resolve({'type': 'booking'});
      expect(target?.location, RouteNames.bookings);
      expect(target?.extra, isNull);
    });

    test('maps salon type with store_id to salon details', () {
      final target = NotificationRoutes.resolve({
        'type': 'salon',
        'store_id': '42',
        'salon_name': 'Glow Spa',
      });

      expect(target?.location, RouteNames.salonDetails);
      expect(target?.extra, isA<Map<String, dynamic>>());
      expect((target!.extra! as Map)['salonId'], '42');
      expect((target.extra! as Map)['salonName'], 'Glow Spa');
    });

    test('maps direct route path', () {
      final target = NotificationRoutes.resolve({'route': '/wallet'});
      expect(target?.location, '/wallet');
    });

    test('maps promotion type to home', () {
      final target = NotificationRoutes.resolve({'type': 'promotion'});
      expect(target?.location, RouteNames.home);
    });

    test('maps category type with metadata', () {
      final target = NotificationRoutes.resolve({
        'type': 'category',
        'category_name': 'Hair',
        'category_index': '2',
      });

      expect(target?.location, RouteNames.category);
      expect((target!.extra! as Map)['categoryName'], 'Hair');
      expect((target.extra! as Map)['categoryIndex'], 2);
    });

    test('defaults unknown type to home', () {
      final target = NotificationRoutes.resolve({'type': 'unknown_event'});
      expect(target?.location, RouteNames.home);
    });
  });

  group('decodeNotificationPayload', () {
    test('decodes JSON notification payload for local tap', () {
      final data = decodeNotificationPayload(
        '{"type":"booking","appointment_id":"99"}',
      );
      expect(data['type'], 'booking');
      expect(data['appointment_id'], '99');
    });
  });
}
