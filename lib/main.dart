import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/constants/app_strings.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/network/auth_session_manager.dart';
import 'package:tressy/core/router/app_router.dart';
import 'package:tressy/core/services/firebase_notification_service.dart';
import 'package:tressy/core/theme/app_theme.dart';
import 'package:tressy/core/theme/theme_provider.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';
import 'package:tressy/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:tressy/firebase_options.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app_links/app_links.dart';
import 'package:tressy/core/router/route_names.dart';

bool _isSupportedAppLink(Uri uri) {
  final path = uri.path.endsWith('/') && uri.path.length > 1
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;

  return (uri.host == 'www.gloup.in' && path == '/open') ||
      (uri.host == 'api.v1.gloup.in' && path == '/download');
}

void _handleAppLink(Uri uri) {
  debugPrint('App Link Received: $uri');
  if (_isSupportedAppLink(uri)) {
    AppRouter.router.go(RouteNames.home);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await LocalStorageService.init();

  AuthSessionManager.onSessionExpired = () async {
    AppRouter.router.go(RouteNames.login);
  };

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications (must be before Firebase messaging setup)
  await initializeLocalNotifications();

  // Initialize dependencies (must be before FirebaseNotificationService so DioClient is registered)
  await initializeDependencies();

  // Initialize Firebase Cloud Messaging (non-blocking token fetch runs in bg)
  await FirebaseNotificationService.initialize();

  // Initialize App Links listener
  final appLinks = AppLinks();
  Uri? initialAppLink;
  try {
    initialAppLink = await appLinks.getInitialLink();
    appLinks.uriLinkStream.listen(
      _handleAppLink,
      onError: (error) => debugPrint('App Link Error: $error'),
    );
  } catch (error) {
    debugPrint('Failed to initialize app links: $error');
  }

  runApp(const MyApp());

  if (initialAppLink != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAppLink(initialAppLink!);
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global CategoryBloc - shared across all screens
        BlocProvider<CategoryBloc>.value(
          value: sl<CategoryBloc>(),
        ),
        // Global FavoritesBloc - manages favorite state across all screens
        BlocProvider<FavoritesBloc>.value(
          value: sl<FavoritesBloc>(),
        ),
        // Global HomeBloc - shared home feed state across tab switches
        BlocProvider<HomeBloc>.value(
          value: sl<HomeBloc>(),
        ),
        // Global ProfileBloc - shared profile state for home, profile, and edit screens
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
        ),
      ],
      child: MultiProvider(
        providers: [
          // Theme Provider - manages app theme
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          // Location Provider - manages user location globally
          ChangeNotifierProvider(create: (_) => LocationProvider()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  title: AppStrings.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  routerConfig: AppRouter.router,
                  builder: (context, child) {
                    return UpgradeAlert(
                      showIgnore: false,
                      showLater: false,
                      barrierDismissible: false,
                      shouldPopScope: () => false,
                      dialogStyle: UpgradeDialogStyle.cupertino,
                      upgrader: Upgrader(
                        debugLogging:
                            true, // Enables logs to debug why it might not be showing
                        durationUntilAlertAgain: Duration
                            .zero, // Ignores the default 3-day wait period
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
