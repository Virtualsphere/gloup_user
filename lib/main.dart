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
import 'package:tressy/core/services/force_update_service.dart';
import 'package:tressy/core/services/presence_heartbeat_service.dart';
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

  // Real-time presence for admin live stats
  await PresenceHeartbeatService.initialize();

  // Initialize Firebase Cloud Messaging (non-blocking token fetch runs in bg)
  await FirebaseNotificationService.initialize();

  // App links only bring the app to the foreground; no in-app redirection.
  AppLinks().uriLinkStream.listen(
    (uri) => debugPrint('App Link Received: $uri'),
    onError: (error) => debugPrint('App Link Error: $error'),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService.checkAndForceUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ForceUpdateService.checkAndForceUpdate();
    }
  }

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
                    final content = child ?? const SizedBox.shrink();
                    // Dart-only forced update dialog. Required for older Play
                    // builds (e.g. 2.8.8) that lack the native in_app_update
                    // plugin — Shorebird can still patch this path. Newer
                    // builds also get Play Immediate via ForceUpdateService.
                    return UpgradeAlert(
                      showIgnore: false,
                      showLater: false,
                      barrierDismissible: false,
                      shouldPopScope: () => false,
                      dialogStyle: UpgradeDialogStyle.cupertino,
                      upgrader: Upgrader(
                        durationUntilAlertAgain: Duration.zero,
                      ),
                      child: content,
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
