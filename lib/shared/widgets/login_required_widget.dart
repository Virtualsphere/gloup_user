import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_bottom_sheet.dart';

/// A widget that checks authentication and shows login prompt if not authenticated
/// Matches the design of login_page.dart with background image and overlay card
class LoginRequiredWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLoginPressed;
  final String? title;
  final String? message;
  final String? buttonText;
  final bool showBrowseAsGuest;
  final bool useBottomSheet;

  const LoginRequiredWidget({
    super.key,
    required this.child,
    this.onLoginPressed,
    this.title,
    this.message,
    this.buttonText,
    this.showBrowseAsGuest = true,
    this.useBottomSheet = true,
  });

  @override
  State<LoginRequiredWidget> createState() => _LoginRequiredWidgetState();
}

class _LoginRequiredWidgetState extends State<LoginRequiredWidget> with WidgetsBindingObserver {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthentication();
    }
  }

  void _checkAuthentication() {
    setState(() {
      _isAuthenticated = LocalStorageService.accessToken != null &&
          LocalStorageService.accessToken!.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      // User is logged in, show the actual content
      return widget.child;
    } else {
      // User is not logged in, show login prompt
      return _buildLoginPrompt(context);
    }
  }

  Widget _buildLoginPrompt(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final backgroundHeight = screenHeight * 0.25;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          // Background Image (same as login_page.dart)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: backgroundHeight,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.black.withValues(alpha: 0.6)
                    : Colors.transparent,
                BlendMode.darken,
              ),
              child: Image.asset(
                AppImages.loginBg,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlapping Card (same design as login_page.dart)
          Positioned(
            top: backgroundHeight - 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusXL),
                  topRight: Radius.circular(AppSizes.radiusXL),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? AppColors.black.withValues(alpha: 0.3)
                        : AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSizes.spaceXL),

                    // Icon - Salon Chair Image
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Image.asset(
                        'assets/images/png/salon_chair.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceXL),

                    // Title
                    Text(
                      widget.title ?? 'Login Required',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSizes.spaceM),

                    // Message
                    Text(
                      widget.message ?? 'Please login to access this feature and enjoy personalized experience.',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSizes.spaceXXL),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.useBottomSheet) {
                            // Show login bottom sheet
                            await LoginBottomSheet.show(context);
                            // Check authentication after bottom sheet closes
                            _checkAuthentication();
                          } else if (widget.onLoginPressed != null) {
                            // Use custom callback
                            widget.onLoginPressed!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        child: Text(
                          widget.buttonText ?? 'Login to Continue',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spaceL),

                    // Skip/Browse as guest option (only show if enabled and can pop)
                    if (widget.showBrowseAsGuest && Navigator.of(context).canPop())
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Browse as Guest',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
