import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/features/app_launch/presentation/widgets/launch_perk_tile.dart';
import 'package:tressy/features/app_launch/presentation/widgets/live_cities_section.dart';

class AppLaunchFirstOpenView extends StatelessWidget {
  final VoidCallback onProceed;

  const AppLaunchFirstOpenView({
    super.key,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onProceed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                // Logo
                SvgPicture.asset(
                  AppIcons.gloUp,
                  width: 130.w,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1A1D20),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(height: 6.h),
                // Subtitle
                Text(
                  'Book salons near you. Instantly.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF4B5563),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16.h),

                // Now Live In Section
                const LiveCitiesSection(showFooter: false),
                SizedBox(height: 18.h),

                // Hero Salon Chair Card
                Container(
                  width: double.infinity,
                  height: 220.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF5FB),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Stack(
                    children: [
                      // Rating Badge Top-Left
                      Positioned(
                        top: 14.h,
                        left: 14.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.star,
                                width: 11.w,
                                height: 11.w,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF1A1D20),
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '4.6 avg salon rating',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1D20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Salon Chair Graphic
                      Center(
                        child: Image.asset(
                          AppImages.salonChair,
                          height: 145.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Services starting price badge bottom-right
                      Positioned(
                        bottom: 14.h,
                        right: 14.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E232A),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Text(
                            'Services from ₹9',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),

                // 3 Feature Perks
                const LaunchPerkTile(
                  iconPath: AppIcons.icDealPercent,
                  title: 'Best salon deals',
                  subtitle: 'Exclusive offers you won\'t get at the counter',
                ),
                SizedBox(height: 14.h),
                const LaunchPerkTile(
                  iconPath: AppIcons.icVerifiedShield,
                  title: 'Verified partner salons',
                  subtitle: 'Every salon checked for hygiene & pricing',
                ),
                SizedBox(height: 14.h),
                const LaunchPerkTile(
                  iconPath: AppIcons.icInstantSlot,
                  title: 'Instant slot booking',
                  subtitle: 'Pick a time, skip the waiting line',
                ),

                const Spacer(),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E232A),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1D5DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Footer
                Text(
                  'Operated by GloUp instantly',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

