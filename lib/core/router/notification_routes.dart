import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/keys.dart';
import 'package:tressy/core/router/route_names.dart';

/// Resolved in-app destination for a push notification tap.
class NotificationTarget {
  final String location;
  final Object? extra;

  const NotificationTarget({
    required this.location,
    this.extra,
  });
}

enum _NotificationRouteKind {
  home,
  bookings,
  salon,
  profile,
  wallet,
  favorites,
  explore,
  category,
  personalProfile,
  inviteAndEarn,
}

/// Maps FCM [RemoteMessage.data] keys to [GoRouter] destinations.
class NotificationRoutes {
  NotificationRoutes._();

  static const Map<String, _NotificationRouteKind> _typeAliases = {
    'booking': _NotificationRouteKind.bookings,
    'appointment': _NotificationRouteKind.bookings,
    'booking_reminder': _NotificationRouteKind.bookings,
    'booking_cancelled': _NotificationRouteKind.bookings,
    'booking_confirmed': _NotificationRouteKind.bookings,
    'salon': _NotificationRouteKind.salon,
    'store': _NotificationRouteKind.salon,
    'salon_detail': _NotificationRouteKind.salon,
    'promotion': _NotificationRouteKind.home,
    'offer': _NotificationRouteKind.home,
    'banner': _NotificationRouteKind.home,
    'profile': _NotificationRouteKind.profile,
    'wallet': _NotificationRouteKind.wallet,
    'favorites': _NotificationRouteKind.favorites,
    'explore': _NotificationRouteKind.explore,
    'category': _NotificationRouteKind.category,
    'invite': _NotificationRouteKind.inviteAndEarn,
    'invite_and_earn': _NotificationRouteKind.inviteAndEarn,
  };

  static const Map<String, String> _pathAliases = {
    '/home': RouteNames.home,
    'home': RouteNames.home,
    '/bookings': RouteNames.bookings,
    'bookings': RouteNames.bookings,
    '/favorites': RouteNames.favorites,
    'favorites': RouteNames.favorites,
    '/explore': RouteNames.explore,
    'explore': RouteNames.explore,
    '/profile': '/profile',
    'profile': '/profile',
    '/personal_profile': '/personal_profile',
    'personal_profile': '/personal_profile',
    '/wallet': '/wallet',
    'wallet': '/wallet',
    '/invite_and_earn': '/invite_and_earn',
    'invite_and_earn': '/invite_and_earn',
    '/category': RouteNames.category,
    'category': RouteNames.category,
    '/salon-details': RouteNames.salonDetails,
    'salon-details': RouteNames.salonDetails,
    '/salon_details': RouteNames.salonDetails,
    'salon_details': RouteNames.salonDetails,
  };

  static void navigateFromMessage(GoRouter router, RemoteMessage message) {
    navigateFromData(router, message.data);
  }

  static void navigateFromData(GoRouter router, Map<String, dynamic> data) {
    final target = resolve(data);
    if (target == null) return;

    if (target.extra != null) {
      router.push(target.location, extra: target.extra);
      return;
    }

    router.go(target.location);
  }

  /// Returns null when [data] is empty or has no navigable target.
  static NotificationTarget? resolve(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    final directRoute = _firstNonEmpty(data, [
      'route',
      'screen',
      'deep_link',
      'link',
      'path',
    ]);
    if (directRoute != null) {
      return _targetFromPath(directRoute, data);
    }

    final type = _firstNonEmpty(data, [
      'type',
      'notification_type',
      'click_action',
      'action',
    ])?.toLowerCase();

    if (type == null) {
      return const NotificationTarget(location: RouteNames.home);
    }

    final kind = _typeAliases[type];
    if (kind == null) {
      return const NotificationTarget(location: RouteNames.home);
    }

    return _targetForKind(kind, data);
  }

  static NotificationTarget? _targetFromPath(
    String rawPath,
    Map<String, dynamic> data,
  ) {
    final normalized = rawPath.trim();
    if (normalized.isEmpty) return null;

    final pathOnly = normalized.split('?').first;
    final mapped = _pathAliases[pathOnly] ?? pathOnly;

    if (mapped == RouteNames.salonDetails || pathOnly.contains('salon')) {
      final salonId = _salonId(data);
      if (salonId != null) {
        return NotificationTarget(
          location: RouteNames.salonDetails,
          extra: {
            Keys.storeId: salonId,
            'salonId': salonId,
            if (_firstNonEmpty(
                    data, ['salon_name', 'salonName', 'store_name']) !=
                null)
              'salonName': _firstNonEmpty(
                data,
                ['salon_name', 'salonName', 'store_name'],
              ),
          },
        );
      }
    }

    if (mapped == RouteNames.category) {
      return NotificationTarget(
        location: RouteNames.category,
        extra: _categoryExtra(data),
      );
    }

    return NotificationTarget(location: mapped);
  }

  static NotificationTarget _targetForKind(
    _NotificationRouteKind kind,
    Map<String, dynamic> data,
  ) {
    switch (kind) {
      case _NotificationRouteKind.home:
        return const NotificationTarget(location: RouteNames.home);
      case _NotificationRouteKind.bookings:
        return const NotificationTarget(location: RouteNames.bookings);
      case _NotificationRouteKind.favorites:
        return const NotificationTarget(location: RouteNames.favorites);
      case _NotificationRouteKind.explore:
        return const NotificationTarget(location: RouteNames.explore);
      case _NotificationRouteKind.profile:
        return const NotificationTarget(location: '/profile');
      case _NotificationRouteKind.personalProfile:
        return const NotificationTarget(location: '/personal_profile');
      case _NotificationRouteKind.wallet:
        return const NotificationTarget(location: '/wallet');
      case _NotificationRouteKind.inviteAndEarn:
        return const NotificationTarget(location: '/invite_and_earn');
      case _NotificationRouteKind.category:
        return NotificationTarget(
          location: RouteNames.category,
          extra: _categoryExtra(data),
        );
      case _NotificationRouteKind.salon:
        final salonId = _salonId(data);
        if (salonId == null) {
          return const NotificationTarget(location: RouteNames.home);
        }
        return NotificationTarget(
          location: RouteNames.salonDetails,
          extra: {
            Keys.storeId: salonId,
            'salonId': salonId,
            if (_firstNonEmpty(
                    data, ['salon_name', 'salonName', 'store_name']) !=
                null)
              'salonName': _firstNonEmpty(
                data,
                ['salon_name', 'salonName', 'store_name'],
              ),
          },
        );
    }
  }

  static Map<String, dynamic> _categoryExtra(Map<String, dynamic> data) {
    final categoryName = _firstNonEmpty(data, [
      'category_name',
      'categoryName',
      'category',
    ]);
    final categoryIndex = int.tryParse(
      _firstNonEmpty(data, ['category_index', 'categoryIndex']) ?? '',
    );

    return {
      if (categoryName != null) 'categoryName': categoryName,
      if (categoryIndex != null) 'categoryIndex': categoryIndex,
    };
  }

  static String? _salonId(Map<String, dynamic> data) {
    final raw = _firstNonEmpty(data, [
      Keys.storeId,
      'store_id',
      'storeId',
      'salon_id',
      'salonId',
    ]);
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String? _firstNonEmpty(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final asString = value.toString().trim();
      if (asString.isNotEmpty) return asString;
    }
    return null;
  }
}
