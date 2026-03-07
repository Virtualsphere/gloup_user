import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/providers/location_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/local_storage_service.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await LocalStorageService.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications (must be before Firebase messaging setup)
  await initializeLocalNotifications();

  // Initialize dependencies (must be before FirebaseNotificationService so DioClient is registered)
  await initializeDependencies();

  // Initialize Firebase Cloud Messaging (non-blocking token fetch runs in bg)
  await FirebaseNotificationService.initialize();

  runApp(const MyApp());
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
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
