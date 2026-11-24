import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/services/app_analytics_service.dart';
import 'package:tressy/core/services/attribution_service.dart';
import 'package:tressy/core/services/presence_heartbeat_service.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_event.dart';
import 'package:tressy/features/auth/presentation/bloc/auth_state.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';

class OtpPage extends StatelessWidget {
  final String phone;
  final AuthBloc? authBloc;

  const OtpPage({
    super.key,
    required this.phone,
    this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => authBloc ?? sl<AuthBloc>(),
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
  final FocusNode _otpFocusNode = FocusNode();
  bool _isLoading = false;
  int _resendCountdown = 30;
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
    _otpFocusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    setState(() {
      _isOtpComplete = _otpController.text.length == 4;
    });
  }

  void _startCountdown() {
    _resendCountdown = 30;
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

  String get _formattedPhone {
    final digits = widget.phone.replaceAll(RegExp(r'\D'), '');
    final pure = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    if (pure.length == 10) {
      return '+91 ${pure.substring(0, 5)} ${pure.substring(5)}';
    }
    return '+91 ${widget.phone}';
  }

  String get _cleanPhoneNumber {
    final digits = widget.phone.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length == 4) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            VerifyOtpEvent(
              phone: _cleanPhoneNumber,
              otp: _otpController.text.trim(),
            ),
          );
    } else {
      CustomToast.showWarning(context, "Please enter complete 4-digit OTP");
    }
  }

  void _handleResendOtp({bool isWhatsApp = false}) {
    if (_resendCountdown > 0 && !isWhatsApp) return;

    if (isWhatsApp) {
      CustomToast.showSuccess(context, "Requesting code via WhatsApp...");
    }

    context.read<AuthBloc>().add(SendOtpEvent(_cleanPhoneNumber));
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
          _startCountdown();
          _otpController.clear();
          CustomToast.showSuccess(context, state.authEntity.message);
        } else if (state is OtpVerifiedSuccess) {
          setState(() {
            _isLoading = false;
          });

          final authEntity = state.authEntity;
          if (authEntity is VerifyOtpEntity) {
            LocalStorageService.setAccessToken(authEntity.token);
            LocalStorageService.setLoggedIn(true);
            PresenceHeartbeatService.onUserLogin();
            UserLocationSyncService.onUserLogin();
            AttributionService.onUserLogin();
            AppAnalyticsService.instance.flush();
          }

          CustomToast.showSuccess(context, "OTP verified successfully!");
          context.go(RouteNames.home);
        } else if (state is AuthFailure) {
          setState(() {
            _isLoading = false;
          });
          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              // 4-digit verification code: container is 358px with 16px screen margins on 390px frame.
              // 4 boxes with 3 gaps of 12px.
              final computedBoxWidth =
                  ((availableWidth - 32.w - (3 * 12.w)) / 4).clamp(56.0, 70.0);
              final boxHeight = 56.h;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.h),

                        // Back Button Chevron (Figma: #262A30)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteNames.login);
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 4.h,
                              bottom: 18.h,
                              right: 16.w,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20.w,
                              color: const Color(0xFF262A30),
                            ),
                          ),
                        ),

                        // Title: "Enter verification code" (Inter, 24px, 700 bold, line-height 30px, letterSpacing -0.4px, #262A30)
                        Text(
                          'Enter verification code',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF262A30),
                            height: 30 / 24,
                            letterSpacing: -0.4,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle line: "We've sent a 4-digit code to +91 XXXXX XXXXX" + "Edit" (#2D6FA6)
                        Row(
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF717784),
                                    height: 20 / 14,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "We've sent a 4-digit code to ",
                                    ),
                                    TextSpan(
                                      text: _formattedPhone,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF262A30),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                if (context.canPop()) {
                                    context.pop();
                                } else {
                                  context.go(RouteNames.login);
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Text(
                                  'Edit',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D6FA6),
                                    height: 20 / 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Figma: 30px padding top for OTP container
                        SizedBox(height: 30.h),

                        // 4-digit Pinput
                        Center(
                          child: Pinput(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            length: 4,
                            autofocus: true,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            separatorBuilder: (index) => SizedBox(width: 12.w),
                            defaultPinTheme: PinTheme(
                              width: computedBoxWidth,
                              height: boxHeight,
                              textStyle: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF262A30),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFD9DDE2),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: computedBoxWidth,
                              height: boxHeight,
                              textStyle: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF262A30),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFF262A30),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: computedBoxWidth,
                              height: boxHeight,
                              textStyle: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF262A30),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFD9DDE2),
                                  width: 1.2,
                                ),
                              ),
                            ),
                            cursor: Center(
                              child: Container(
                                width: 1.5,
                                height: 22.h,
                                color: const Color(0xFF262A30),
                              ),
                            ),
                            onCompleted: (_) => _handleVerifyOtp(),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // "Waiting to auto-read the code from SMS" status pill (#F3F4F6)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2F8F62),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'Waiting to auto-read the code from SMS',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF717784),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // Row 1: Didn't get the code? + Resend countdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Didn't get the code?",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF717784),
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _resendCountdown > 0
                                ? Text(
                                    'Resend in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF717784),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _handleResendOtp(),
                                    child: Text(
                                      'Resend OTP',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF2D6FA6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ],
                        ),

                        SizedBox(height: 14.h),

                        // Row 2: Prefer another way? + Get code on WhatsApp (#2D6FA6)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Prefer another way?',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF717784),
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _handleResendOtp(isWhatsApp: true),
                              child: Text(
                                'Get code on WhatsApp',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF2D6FA6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        SizedBox(height: 20.h),

                        // Bottom "Verify" Button (Disabled: #C9CED6, Enabled: #262A30)
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed:
                                (_isOtpComplete && !_isLoading) ? _handleVerifyOtp : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isOtpComplete
                                  ? const Color(0xFF262A30)
                                  : const Color(0xFFC9CED6),
                              disabledBackgroundColor: const Color(0xFFC9CED6),
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
                                    'Verify',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(
                          height: bottomInset > 0 ? (bottomInset + 8.h) : 24.h,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
