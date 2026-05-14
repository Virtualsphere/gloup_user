import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'package:tressy/features/slot_booking/presentation/bloc/slot_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/guest_bloc.dart';
import 'package:tressy/features/auth/presentation/pages/login_page.dart';
import 'package:tressy/features/auth/presentation/pages/otp_page.dart';
import 'package:tressy/features/bookings/presentation/pages/bookings_page.dart';
import 'package:tressy/features/explore/presentation/pages/explore_page.dart';
import 'package:tressy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:tressy/features/home/presentation/pages/home_page.dart';
import 'package:tressy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_event.dart';
import 'package:tressy/features/profile/presentation/pages/invite_and_earn.dart';
import 'package:tressy/features/profile/presentation/pages/my_profile.dart';
import 'package:tressy/features/my_reviews/my_reviews.dart';
import 'package:tressy/features/profile/presentation/pages/profile_page.dart';
import 'package:tressy/features/profile/presentation/pages/settings.dart';
import 'package:tressy/features/profile/presentation/pages/support.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/cancellation.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/contact.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/dev_info.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/faq.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/privacy_policy.dart';
import 'package:tressy/features/profile/presentation/pages/support_screens/terms_conditions.dart';
import 'package:tressy/features/profile/presentation/pages/wallet.dart';
import 'package:tressy/features/salon_details/presentation/pages/salon_details_page.dart';
import 'package:tressy/features/slot_booking/presentation/pages/slot_booking_page.dart';
import 'package:tressy/features/booking_confirmation/presentation/pages/review_confirm_page.dart';
import 'package:tressy/features/salon_search/presentation/pages/salon_search_page.dart';
import 'package:tressy/features/splash/presentation/pages/splash_page.dart';
import 'package:tressy/features/category/presentation/pages/category_page.dart';
import 'package:tressy/shared/widgets/main_scaffold.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
    redirect: (context, state) {
      // Add global redirect logic here (e.g., authentication)
      return null;
    },
  );

  static final List<RouteBase> _routes = [
    // Splash route
    GoRoute(
      path: RouteNames.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    // Onboarding route
    GoRoute(
      path: RouteNames.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    // Login route
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    // OTP route
    GoRoute(
      path: RouteNames.otp,
      name: RouteNames.otp,
      builder: (context, state) {
        // Get phone from extra data passed during navigation
        final phone = state.extra as String? ?? '';
        return OtpPage(
          phone: phone,
        );
      },
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: RouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Explore branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.explore,
              name: RouteNames.explore,
              builder: (context, state) => const ExplorePage(),
            ),
          ],
        ),
        // Favorites branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.favorites,
              name: RouteNames.favorites,
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        // Bookings branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.bookings,
              name: RouteNames.bookings,
              builder: (context, state) => const BookingsPage(),
            ),
          ],
        ),
      ],
    ),
    // Salon Details route
    GoRoute(
      path: RouteNames.salonDetails,
      name: RouteNames.salonDetails,
      builder: (context, state) {
        // Get salon data from extra
        final Map<String, dynamic>? salonData =
            state.extra as Map<String, dynamic>?;
        return SalonDetailsPageWrapper(
          salonId: salonData?['salonId'] as String?,
        );
      },
      routes: [
        // Slot Booking route (child of salon details)
        GoRoute(
          path: 'slot-booking',
          name: RouteNames.slotBooking,
          builder: (context, state) {
            // Get salon and service data from extra
            final data = state.extra as Map<String, dynamic>?;
            return BlocProvider(
              create: (context) => sl<SlotBloc>(),
              child: SlotBookingPage(bookingData: data),
            );
          },
          routes: [
            // Review & Confirm route (child of slot booking)
            GoRoute(
              path: 'review-confirm',
              name: RouteNames.reviewConfirm,
              builder: (context, state) {
                // Get complete booking data including slot timing
                final data = state.extra as Map<String, dynamic>?;
                return BlocProvider(
                  create: (context) => sl<GuestBloc>(),
                  child: ReviewConfirmPage(bookingData: data),
                );
              },
            ),
          ],
        ),
      ],
    ),

    // Category route
    GoRoute(
      path: RouteNames.category,
      name: RouteNames.category,
      builder: (context, state) {
        final Map<String, dynamic>? categoryData =
            state.extra as Map<String, dynamic>?;
        return CategoryPage(
          categoryName: categoryData?['categoryName'] as String?,
          categoryIndex: categoryData?['categoryIndex'] as int?,
        );
      },
    ),

    // Salon Search route
    GoRoute(
        path: RouteNames.salonSearch,
        name: RouteNames.salonSearch,
        builder: (context, state) => SalonSearchPage()),

    //profile
    GoRoute(
      path: '/personal_profile',
      name: RouteNames.personalProfile,
      builder: (context, state) => ProfilePage(),
    ),
    //support
    GoRoute(
      path: '/support',
      name: RouteNames.support,
      builder: (context, state) => Support(),
      routes: [
        GoRoute(
          path: 'privacy_policy',
          name: RouteNames.privacyPolicy,
          builder: (context, state) => PrivacyPolicy(),
        ),
        GoRoute(
          path: 'terms_conditions',
          name: RouteNames.termsConditions,
          builder: (context, state) => TermsConditions(),
        ),
        GoRoute(
          path: 'cancellation',
          name: RouteNames.cancellation,
          builder: (context, state) => Cancellation(),
        ),
        GoRoute(
          path: 'dev_info',
          name: RouteNames.devInfo,
          builder: (context, state) => DevInfo(),
        ),
        GoRoute(
          path: 'contact',
          name: RouteNames.contact,
          builder: (context, state) => Contact(),
        ),
        GoRoute(
          path: 'faqs',
          name: RouteNames.faqs,
          builder: (context, state) => Faq(),
        ),
      ],
    ),

    //wallet
    GoRoute(
      path: '/wallet',
      name: RouteNames.wallet,
      builder: (context, state) => Wallet(),
    ),
    //Invite And Earn
    GoRoute(
      path: '/invite_and_earn',
      name: RouteNames.inviteAndEarn,
      builder: (context, state) => InviteAndEarn(),
    ),

    //Settings
    GoRoute(
      path: '/settings',
      name: RouteNames.settings,
      builder: (context, state) {
        final profile = state.extra as ProfileEntity;
        return Settings(profile: profile);
      },
    ),

    //Profile
    GoRoute(
      path: '/profile',
      name: RouteNames.profile,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(const GetProfileEvent()),
          child: const MyProfile(),
        );
      },
    ),

    //Review
    GoRoute(
      path: '/reviews',
      name: RouteNames.reviews,
      builder: (context, state) => MyReviews(),
    ),
  ];
}

// Error page
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => {},
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
