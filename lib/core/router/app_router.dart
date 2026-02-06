import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/auth/presentation/pages/login_page.dart';
import 'package:tressy/features/auth/presentation/pages/otp_page.dart';
import 'package:tressy/features/bookings/presentation/pages/bookings_page.dart';
import 'package:tressy/features/explore/presentation/pages/explore_page.dart';
import 'package:tressy/features/favorites/presentation/pages/favorites_page.dart';
import 'package:tressy/features/home/presentation/pages/home_page.dart';
import 'package:tressy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:tressy/features/splash/presentation/pages/splash_page.dart';
import 'package:tressy/shared/widgets/main_scaffold.dart';

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
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
    // Add more routes here
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
