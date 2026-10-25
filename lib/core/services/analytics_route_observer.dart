import 'package:flutter/widgets.dart';
import 'package:tressy/core/services/app_analytics_service.dart';

/// NavigatorObserver that notifies [AppAnalyticsService] of route changes
/// and normalizes them into the exact canonical screen names specified in tracking spec.
class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _recordRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _recordRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _recordRoute(newRoute);
    }
  }

  void _recordRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    final screenName = mapRouteToScreen(routeName);
    if (screenName != null) {
      AppAnalyticsService.instance.setCurrentScreen(screenName);
    }
  }

  /// Maps internal route names / paths to spec-compliant screen names:
  /// home, search, salon_list, map, salon_details, slots, offers, checkout,
  /// payment, payment_success, bookings, favourites, reviews, profile, wallet, notifications.
  static String? mapRouteToScreen(String? route) {
    if (route == null) return null;

    final lower = route.toLowerCase();
    if (lower.contains('slot') && lower.contains('booking')) return 'slots';
    if (lower.contains('review') && lower.contains('confirm')) return 'checkout';
    if (lower.contains('checkout')) return 'checkout';
    if (lower.contains('payment_success') || lower.contains('success')) return 'payment_success';
    if (lower.contains('payment')) return 'payment';
    if (lower.contains('salon_details') || lower.contains('salondetails')) return 'salon_details';
    if (lower.contains('search')) return 'search';
    if (lower.contains('category') || lower.contains('explore')) return 'salon_list';
    if (lower.contains('map')) return 'map';
    if (lower.contains('coupon') || lower.contains('offer')) return 'offers';
    if (lower.contains('booking')) return 'bookings';
    if (lower.contains('fav')) return 'favourites';
    if (lower.contains('review')) return 'reviews';
    if (lower.contains('wallet')) return 'wallet';
    if (lower.contains('notification')) return 'notifications';
    if (lower.contains('profile') || lower.contains('settings')) return 'profile';
    if (lower == '/' || lower.contains('home')) return 'home';

    return null;
  }
}

