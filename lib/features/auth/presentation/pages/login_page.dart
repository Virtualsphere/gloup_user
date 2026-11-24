import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_strings.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.authBloc});

  /// Optional bloc for widget tests; production uses [sl].
  final AuthBloc? authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => authBloc ?? sl<AuthBloc>(),
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
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      context.read<AuthBloc>().add(SendOtpEvent(phone));
    }
  }

  void _openLegalUrl(String type) {
    if (type == 'terms') {
      context.pushNamed(RouteNames.termsConditions);
    } else {
      context.pushNamed(RouteNames.privacyPolicy);
    }
  }

  @override
  Widget build(BuildContext context) {
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

          final completePhone = _phoneController.text.trim();
          GoRouter.of(context).push(RouteNames.otp, extra: completePhone);
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
          });

          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEEF5FC),
                Color(0xFFFCF2F3),
              ],
              stops: [0.0, 0.45],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Top Navigation Bar with Skip Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.go(RouteNames.home);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF14181E).withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF14181E),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hero Graphic Section with Salon Chair & 2 Floating Badges
                  SizedBox(
                    height: 290.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Center Salon Chair Graphic
                        Center(
                          child: Image.asset(
                            AppImages.loginChair,
                            width: 270.w,
                            height: 270.h,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Floating Badge 1 (Top Left) - "Booked today"
                        Positioned(
                          top: 14.h,
                          left: 20.w,
                          child: Container(
                            width: 96.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF14181E).withValues(alpha: 0.08),
                                  offset: const Offset(0, 8),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Booked today',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF717784),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '12,480+',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF14181E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Floating Badge 2 (Right) - "Partner salons"
                        Positioned(
                          top: 96.h,
                          right: 20.w,
                          child: Container(
                            width: 99.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF262A30),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Partner salons',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '1,200+',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom White Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14181E).withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline
                          Text(
                            'Look good.\nBook in seconds.',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF14181E),
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 22.h),

                          // "Log in or sign up" Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Text(
                                  'Log in or sign up',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF717784),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18.h),

                          // Mobile Number Input Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Country Code Box
                              Container(
                                height: 52.h,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF14181E),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18.w,
                                      color: const Color(0xFF717784),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.w),

                              // Phone Text Input Field
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF14181E),
                                    letterSpacing: 0.5,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  validator: (val) {
                                    final text = val?.trim() ?? '';
                                    if (text.isEmpty) {
                                      return AppStrings.validationRequired;
                                    }
                                    if (text.length != 10) {
                                      return 'Please enter a valid 10-digit phone number';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    counterText: '',
                                    hintText: '98765 43221',
                                    hintStyle: TextStyle(
                                      fontSize: 15.sp,
                                      color: const Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.5,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 14.h,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1.2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1.2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF14181E),
                                        width: 1.4,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18.h),

                          // Continue Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF262A30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 15.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // "Continue as guest" Text Button
                          Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                context.go(RouteNames.home);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Text(
                                  'Continue as guest',
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          // Footer Terms and Policies
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF9CA3AF),
                                    height: 1.45,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'By continuing, you agree to our ',
                                    ),
                                    TextSpan(
                                      text: 'Terms of service',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color(0xFF6B7280),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _openLegalUrl('terms'),
                                    ),
                                    const TextSpan(text: ',\n'),
                                    TextSpan(
                                      text: 'Privacy policy',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color(0xFF6B7280),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _openLegalUrl('privacy'),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Content policy',
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color(0xFF6B7280),
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => _openLegalUrl('content'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
