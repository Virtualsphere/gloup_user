import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/app_launch/presentation/widgets/circular_chair_indicator.dart';
import 'package:tressy/features/app_launch/presentation/widgets/live_cities_section.dart';

class AppLaunchChairLoaderView extends StatelessWidget {
  final String locality;

  const AppLaunchChairLoaderView({
    super.key,
    this.locality = '',
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

              // Animated Circular Chair Indicator
              const CircularChairIndicator(
                mode: ChairIndicatorMode.blueLoader,
              ),
              SizedBox(height: 38.h),

              // GloUp Logo
              SvgPicture.asset(
                AppIcons.gloUp,
                width: 110.w,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1A1D20),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 12.h),

              // Status Subtitle
              Text(
                locality.isEmpty
                    ? 'Finding salons near you...'
                    : 'Finding salons near $locality...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF4B5563),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 4),

              // Bottom "NOW LIVE IN" + Cities + Footer
              const LiveCitiesSection(showFooter: true),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
