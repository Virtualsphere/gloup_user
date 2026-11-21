import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/features/app_launch/presentation/widgets/circular_chair_indicator.dart';
import 'package:tressy/features/app_launch/presentation/widgets/launch_action_button.dart';

class AppLaunchFailureView extends StatelessWidget {
  final VoidCallback onTryAgain;
  final VoidCallback onOpenNetworkSettings;
  final String? errorMessage;
  final String? errorCode;

  const AppLaunchFailureView({
    super.key,
    required this.onTryAgain,
    required this.onOpenNetworkSettings,
    this.errorMessage,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Grey static chair circle
              const CircularChairIndicator(
                mode: ChairIndicatorMode.greyFailure,
              ),
              SizedBox(height: 28.h),

              // Title
              Text(
                'We couldn\'t load GloUp',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D20),
                ),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  errorMessage ??
                      'Check your mobile data or Wi-Fi and try again. Nothing you booked is lost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Error Code
              Text(
                errorCode ?? 'Error GL-503 · server didn\'t respond',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 4),

              // Action Buttons
              LaunchActionButton(
                title: 'Try again',
                isPrimary: true,
                onPressed: onTryAgain,
              ),
              SizedBox(height: 12.h),
              LaunchActionButton(
                title: 'Open network settings',
                isPrimary: false,
                onPressed: onOpenNetworkSettings,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

