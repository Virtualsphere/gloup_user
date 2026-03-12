import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/theme_toggle_button.dart';

class OtpPage extends StatelessWidget {
  final String phone;

  const OtpPage({
    super.key,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: _OtpPageContent(
        phone: phone,
      ),
    );
  }
}

class _OtpPageContent extends StatefulWidget {
  final String phone;

  const _OtpPageContent({
    required this.phone,
  });

  @override
  State<_OtpPageContent> createState() => _OtpPageContentState();
}

class _OtpPageContentState extends State<_OtpPageContent> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    setState(() {
      _isOtpComplete = _otpController.text.length == 4;
    });
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      }
    });
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 4) {
      // Extract phone number without country code for API
      final phoneNumber = widget.phone.replaceAll(RegExp(r'^\+\d+'), '');

      // Trigger BLoC event to verify OTP
      context.read<AuthBloc>().add(VerifyOtpEvent(
            phone: phoneNumber,
            otp: _otpController.text,
          ));
    } else {
      CustomToast.showWarning(context, "Please enter complete OTP");
    }
  }

  void _handleResendOtp() {
    if (_resendCountdown > 0) return;

    // Extract phone number without country code for API
    final phoneNumber = widget.phone.replaceAll(RegExp(r'^\+\d+'), '');

    // Trigger BLoC event to resend OTP
    context.read<AuthBloc>().add(SendOtpEvent(phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final screenHeight = context.screenHeight;
    final backgroundHeight = screenHeight * 0.25;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
            _isResending = false;
          });
        } else if (state is OtpSentSuccess) {
          // Handle resend OTP success
          setState(() {
            _isLoading = false;
            _isResending = false;
          });
          _startCountdown();
          _otpController.clear();
          CustomToast.showSuccess(context, state.authEntity.message);
        } else if (state is OtpVerifiedSuccess) {
          // Handle OTP verification success
          setState(() {
            _isLoading = false;
          });

          // Save token and mark user as logged in
          final authEntity = state.authEntity;
          if (authEntity is VerifyOtpEntity) {
            LocalStorageService.setAccessToken(authEntity.token);
            LocalStorageService.setLoggedIn(true);
          }

          CustomToast.showSuccess(context, "OTP verified successfully!");

          // Navigate to home screen
          context.go(RouteNames.home);
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
            _isResending = false;
          });
          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        body: Stack(
          children: [
            // Background Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: backgroundHeight,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.black.withValues(alpha: 0.5)
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
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSizes.heightXL,
                      Text(
                        'Verify OTP',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSizes.heightM,
                      Text(
                        'Enter the 4-digit code sent to +91${widget.phone}',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      AppSizes.heightXXL,
                      Pinput(
                        controller: _otpController,
                        length: 4,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        defaultPinTheme: PinTheme(
                          width: (context.screenWidth -
                                  (AppSizes.paddingL * 2) -
                                  (AppSizes.spaceM * 3)) /
                              4,
                          height: 60,
                          textStyle: context.textTheme.headlineMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            border: Border.all(
                              color: isDarkMode
                                  ? AppColors.borderDark
                                  : AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: (context.screenWidth -
                                  (AppSizes.paddingL * 2) -
                                  (AppSizes.spaceM * 3)) /
                              4,
                          height: 60,
                          textStyle: context.textTheme.headlineMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            border: Border.all(
                              color: context.colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        errorPinTheme: PinTheme(
                          width: (context.screenWidth -
                                  (AppSizes.paddingL * 2) -
                                  (AppSizes.spaceM * 3)) /
                              4,
                          height: 60,
                          textStyle: context.textTheme.headlineMedium?.copyWith(
                            color: context.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            border: Border.all(
                              color: AppColors.error,
                              width: 2,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                      ),

                      AppSizes.heightS,

                      _resendCountdown > 0
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '$_resendCountdown Sec Remaining',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      AppSizes.heightXL,

                      // Verify Button
                      PrimaryButton(
                        text: 'Verify OTP',
                        isLoading: _isLoading,
                        onPressed: _isOtpComplete ? _handleVerifyOtp : null,
                      ),

                      AppSizes.heightL,

                      // Resend OTP Button
                      Center(
                        child: TextButton(
                          onPressed: (_isResending || _resendCountdown > 0)
                              ? null
                              : _handleResendOtp,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                              vertical: AppSizes.paddingM,
                            ),
                          ),
                          child: _isResending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDarkMode
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend OTP',
                                  style: context.textTheme.labelLarge?.copyWith(
                                    color: (_resendCountdown > 0)
                                        ? (isDarkMode
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary)
                                        : (isDarkMode
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      AppSizes.heightL,
                    ],
                  ),
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
              left: AppSizes.paddingM,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.surfaceDark.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () => GoRouter.of(context).pop(),
                ),
              ),
            ),

            // Theme Toggle
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
              right: AppSizes.paddingM,
              child: const ThemeToggleButton(),
            ),
          ],
        ),
      ),
    );
  }
}
