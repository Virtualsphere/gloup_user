import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LaunchPerkTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;

  const LaunchPerkTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded Square Icon Container
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FB),
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconPath,
            width: 18.w,
            height: 18.w,
            colorFilter: const ColorFilter.mode(
              Color(0xFF0284C7),
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1A1D20),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

