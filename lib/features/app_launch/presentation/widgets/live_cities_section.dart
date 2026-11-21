import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';

class LiveCitiesSection extends StatelessWidget {
  final bool showFooter;

  const LiveCitiesSection({
    super.key,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "● NOW LIVE IN"
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
            SizedBox(width: 6.w),
            Text(
              'NOW LIVE IN',
              style: TextStyle(
                color: const Color(0xFF0284C7),
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // City Pills: Chennai, Bengaluru, Hyderabad
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: const [
            _CityPill(cityName: 'Chennai'),
            _CityPill(cityName: 'Bengaluru'),
            _CityPill(cityName: 'Hyderabad'),
          ],
        ),

        if (showFooter) ...[
          SizedBox(height: 14.h),
          Text(
            'Operated by GloUp instantly',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

class _CityPill extends StatelessWidget {
  final String cityName;

  const _CityPill({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E232A),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.icLocation,
            width: 12.w,
            height: 12.w,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            cityName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

