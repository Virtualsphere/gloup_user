import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_icons.dart';

class AppLaunchHomeSkeletonView extends StatelessWidget {
  final String locality;

  const AppLaunchHomeSkeletonView({
    super.key,
    this.locality = 'Anna Nagar',
  });

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFFECEFF1);
    const highlightColor = Color(0xFFF7F9FA);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Address bars + Profile circle
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 90.w,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Container(
                                  width: 170.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Search Bar Placeholder
                      Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Banner Card Placeholder
                      Container(
                        width: double.infinity,
                        height: 150.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // 4 Category Quick Action Squares
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return Column(
                            children: [
                              Container(
                                width: 68.w,
                                height: 68.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: 44.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 22.h),

                      // Large Featured Salon Card Placeholder
                      Container(
                        width: double.infinity,
                        height: 170.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // Salon details text placeholders
                      Container(
                        width: 180.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 120.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom loading status: Small spinner + text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 13.w,
                    height: 13.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Finding salons near $locality...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar Placeholder
            Container(
              height: 62.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF1F3F5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: AppIcons.icHome,
                    label: 'Home',
                    isSelected: true,
                  ),
                  _buildNavItem(
                    icon: AppIcons.icCalendar,
                    label: 'Bookings',
                    isSelected: false,
                  ),
                  _buildNavItem(
                    icon: AppIcons.icHeart,
                    label: 'Favorites',
                    isSelected: false,
                  ),
                  _buildNavItem(
                    icon: AppIcons.profile,
                    label: 'Profile',
                    isSelected: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isSelected)
          Container(
            width: 24.w,
            height: 2.h,
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D20),
              borderRadius: BorderRadius.circular(2.r),
            ),
          )
        else
          SizedBox(height: 4.h),
        SvgPicture.asset(
          icon,
          width: 20.w,
          height: 20.w,
          colorFilter: ColorFilter.mode(
            isSelected ? const Color(0xFF1A1D20) : const Color(0xFF9CA3AF),
            BlendMode.srcIn,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF1A1D20)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

