import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/core/utils/validators.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/features/auth/presentation/widgets/apple_signin_button.dart';
import 'package:tressy/features/auth/presentation/widgets/country_code_selector.dart';
import 'package:tressy/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:tressy/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/theme_toggle_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: const _LoginPageContent(),
    );
  }
}

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountryChanged(CountryCode countryCode) {
    setState(() {});
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();

      // Trigger BLoC event to send OTP
      context.read<AuthBloc>().add(SendOtpEvent(phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final backgroundHeight = screenHeight * 0.25;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is OtpSentSuccess) {
          setState(() {
            _isLoading = false;
          });

          CustomToast.showSuccess(context, state.authEntity.message);

          final completePhone = _phoneController.text;
          GoRouter.of(context).push(RouteNames.otp, extra: completePhone);
        } else if (state is SocialAuthSuccess) {
          setState(() {
            _isLoading = false;
          });
          LocalStorageService.setAccessToken(state.token);
          LocalStorageService.setLoggedIn(true);
          CustomToast.showSuccess(context, 'Login successful!');
          GoRouter.of(context).go(RouteNames.home);
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
          });

          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        body: Stack(
          children: [
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

            // Overlapping Card
            Positioned(
              top: backgroundHeight - 50,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.only(
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
                  padding: EdgeInsets.all(AppSizes.paddingL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSizes.heightXL,
                        // Title
                        Text(
                          'Welcome Back!',
                          style: context.textTheme.displaySmall?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSizes.heightM,
                        // Subtitle
                        Text(
                          'Enter Mobile Number to Get OTP for Login',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        AppSizes.heightXXL,

                        // Mobile Number Input with Country Code
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Country Code Selector
                            CountryCodeSelector(
                              onChanged: _onCountryChanged,
                              initialSelection: 'IN',
                            ),

                            AppSizes.widthS,
                            // Mobile Number Input Field
                            Expanded(
                              child: PhoneInputField(
                                controller: _phoneController,
                                hintText: 'Mobile Number',
                                maxLength: 10,
                                validator: Validators.indianPhone,
                              ),
                            ),
                          ],
                        ),

                        AppSizes.heightXL,

                        // Login Button
                        PrimaryButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),

                        AppSizes.heightXL,

                        // Or Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDarkMode
                                    ? AppColors.borderDark
                                    : AppColors.border,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingM,
                              ),
                              child: Text(
                                'or',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDarkMode
                                    ? AppColors.borderDark
                                    : AppColors.border,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        AppSizes.heightL,

                        // Apple Sign-In
                        if (Platform.isIOS || Platform.isMacOS) ...[
                          AppSizes.heightM,
                          AppleSignInButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AppleSignInEvent());
                            },
                          ),
                        ] else ...[
                          // Google Sign-In Button
                          GoogleSignInButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const GoogleSignInEvent());
                            },
                          ),
                        ],

                        AppSizes.heightL,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Theme Toggle Button
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
              right: AppSizes.paddingM,
              left: AppSizes.paddingM,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const ThemeToggleButton(),
                  InkWell(
                    onTap: () {
                      context.pushTo(RouteNames.home);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.white : AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusCircular),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingL,
                        vertical: AppSizes.paddingM,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Skip',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: isDarkMode
                                  ? AppColors.primary
                                  : AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                          AppSizes.widthXS,
                          Icon(
                            Icons.arrow_forward_ios,
                            color: isDarkMode
                                ? AppColors.primary
                                : AppColors.white,
                            size: AppSizes.iconXS,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
