import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final hasCompletedOnboarding =
            LocalStorageService.hasCompletedOnboarding;
        final isLoggedIn = LocalStorageService.isLoggedIn;

        if (!hasCompletedOnboarding) {
          context.go(RouteNames.onboarding);
        } else if (!isLoggedIn) {
          context.go(RouteNames.login);
        } else {
          // User is logged in - go to home
          context.go(RouteNames.home);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: Center(
        child: Image.asset(
          isDarkMode ? AppImages.logoDark : AppImages.logo,
          width: context.screenWidth * 0.6,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
