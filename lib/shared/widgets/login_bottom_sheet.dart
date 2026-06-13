import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
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

/// Login bottom sheet with same UI as login_page.dart
/// Shows phone input and social sign-in options
class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();

  /// Show the login bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginBottomSheet(),
      ),
    );
  }
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedCountryCode = '+91';
  bool _isLoading = false;
  bool _isResending = false;
  bool _showOtpInput = false;
  String _fullPhoneNumber = '';
  Timer? _countdownTimer;
  int _resendCountdown = 30;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 30);

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

  void _handleResendOtp() {
    setState(() => _isResending = true);
    // Send OTP with phone number only (no country code)
    context.read<AuthBloc>().add(SendOtpEvent(_phoneController.text));
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
      debugPrint(
          'LoginBottomSheet: Sending OTP to: $_fullPhoneNumber (API will receive: ${_phoneController.text})');
      // Send OTP with phone number only (no country code) to match verify flow
      context.read<AuthBloc>().add(SendOtpEvent(_phoneController.text));
    }
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 4) {
      // Extract phone number without country code for API
      // Use the phone number from controller (without country code)
      final phoneNumber = _phoneController.text;

      debugPrint(
          'LoginBottomSheet: Full: $_fullPhoneNumber, Phone only: $phoneNumber, OTP: ${_otpController.text}');
      context.read<AuthBloc>().add(VerifyOtpEvent(
            phone: phoneNumber,
            otp: _otpController.text,
          ));
    } else {
      CustomToast.showWarning(context, 'Please enter complete OTP');
    }
  }

  void _goBackToPhone() {
    setState(() {
      _showOtpInput = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() {
            _isLoading = false;
            _isResending = false;
          });
        }

        if (state is OtpSentSuccess) {
          // Show OTP input instead of navigating
          setState(() {
            _showOtpInput = true;
          });
          _startResendCountdown();
          CustomToast.showSuccess(context, 'OTP sent to $_fullPhoneNumber');
        } else if (state is OtpVerifiedSuccess) {
          // Login successful - save token and mark as logged in
          final authEntity = state.authEntity;
          if (authEntity is VerifyOtpEntity) {
            LocalStorageService.setAccessToken(authEntity.token);
            LocalStorageService.setLoggedIn(true);
          }

          CustomToast.showSuccess(context, 'Login successful!');
          Navigator.pop(context);
        } else if (state is SocialAuthSuccess) {
          LocalStorageService.setAccessToken(state.token);
          LocalStorageService.setLoggedIn(true);
          CustomToast.showSuccess(context, 'Login successful!');
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          CustomToast.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusXL),
                  topRight: Radius.circular(AppSizes.radiusXL),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(AppSizes.paddingXL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin:
                              EdgeInsets.only(bottom: AppSizes.spaceL),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Back button (only show when on OTP screen)
                      if (_showOtpInput)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: _goBackToPhone,
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back to phone input',
                          ),
                        ),

                      SizedBox(height: AppSizes.spaceXL),

                      // Title
                      Text(
                        _showOtpInput ? 'Verify OTP' : 'Welcome Back!',
                        style: _showOtpInput
                            ? context.textTheme.displaySmall?.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              )
                            : context.textTheme.headlineMedium?.copyWith(
                                color: context.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                      ),

                      SizedBox(height: AppSizes.spaceS),

                      // Subtitle
                      Text(
                        _showOtpInput
                            ? 'Enter the 4-digit code sent to $_fullPhoneNumber'
                            : 'Enter Mobile Number to Get OTP for Login',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        textAlign:
                            _showOtpInput ? TextAlign.center : TextAlign.start,
                      ),

                      SizedBox(height: AppSizes.spaceXXL),

                      // Conditional Input: Phone or OTP
                      if (_showOtpInput) ...[
                        // OTP Input Field - Pinput (same as otp_page.dart)
                        Pinput(
                          controller: _otpController,
                          length: 4,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          defaultPinTheme: PinTheme(
                            width: (context.screenWidth -
                                    (AppSizes.paddingXL * 2) -
                                    (AppSizes.spaceM * 3)) /
                                4,
                            height: 60,
                            textStyle:
                                context.textTheme.headlineMedium?.copyWith(
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
                                    (AppSizes.paddingXL * 2) -
                                    (AppSizes.spaceM * 3)) /
                                4,
                            height: 60,
                            textStyle:
                                context.textTheme.headlineMedium?.copyWith(
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
                          onChanged: (value) {
                            if (value.length == 4) {
                              _handleVerifyOtp();
                            }
                          },
                        ),

                        SizedBox(height: AppSizes.spaceS),

                        // Resend OTP Section (matches otp_page.dart exactly)
                        _resendCountdown > 0
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Didn't receive code? Resend in $_resendCountdown",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      (_isResending || _resendCountdown > 0)
                                          ? null
                                          : _handleResendOtp,
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDarkMode
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                  ),
                                  child: _isResending
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDarkMode
                                                ? AppColors.primaryDark
                                                : AppColors.primary,
                                          ),
                                        )
                                      : Text(
                                          'Resend OTP',
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: isDarkMode
                                                ? AppColors.primaryDark
                                                : AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                        SizedBox(height: AppSizes.spaceXXL),

                        // Verify OTP Button
                        PrimaryButton(
                          text: 'Verify OTP',
                          isLoading: _isLoading,
                          onPressed: _handleVerifyOtp,
                        ),
                      ] else ...[
                        // Mobile Number Input with Country Code
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Country Code Selector
                            CountryCodeSelector(
                              onChanged: (CountryCode code) {
                                setState(() => _selectedCountryCode =
                                    code.dialCode ?? '+91');
                              },
                              initialSelection: 'IN',
                            ),

                            SizedBox(width: AppSizes.spaceM),

                            // Phone Input Field
                            Expanded(
                              child: PhoneInputField(
                                controller: _phoneController,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppSizes.spaceXXL),

                        // Login Button
                        PrimaryButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],

                      // Only show social sign-in on phone input screen
                      if (!_showOtpInput) ...[
                        SizedBox(height: AppSizes.spaceXL),

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

                        SizedBox(height: AppSizes.spaceL),

                        // Platform-specific Social Sign-In
                        if (Platform.isIOS || Platform.isMacOS) ...[
                          // iOS/macOS: Only show Apple Sign-In
                          AppleSignInButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AppleSignInEvent());
                            },
                          ),
                        ] else ...[
                          // Android/Others: Only show Google Sign-In
                          GoogleSignInButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const GoogleSignInEvent());
                            },
                          ),
                        ],

                        SizedBox(height: AppSizes.spaceXL),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
