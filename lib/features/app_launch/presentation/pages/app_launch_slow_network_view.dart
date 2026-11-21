import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/features/app_launch/presentation/widgets/circular_chair_indicator.dart';
import 'package:tressy/features/app_launch/presentation/widgets/launch_action_button.dart';

class AppLaunchSlowNetworkView extends StatelessWidget {
  final VoidCallback onBrowseSavedSalons;
  final VoidCallback onKeepWaiting;

  const AppLaunchSlowNetworkView({
    super.key,
    required this.onBrowseSavedSalons,
    required this.onKeepWaiting,
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

              // Amber animated circular chair loader
              const CircularChairIndicator(
                mode: ChairIndicatorMode.amberLoader,
              ),
              SizedBox(height: 32.h),

              // Title
              Text(
                'Taking longer than usual',
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
                  'Your connection seems slow. We\'ll keep trying in the background.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Offline ready status pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Saved salons are ready to browse offline',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 4),

              // Action Buttons
              LaunchActionButton(
                title: 'Browse saved salons',
                isPrimary: true,
                onPressed: onBrowseSavedSalons,
              ),
              SizedBox(height: 12.h),
              LaunchActionButton(
                title: 'Keep waiting',
                isPrimary: false,
                onPressed: onKeepWaiting,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

