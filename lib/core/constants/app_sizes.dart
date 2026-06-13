import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  AppSizes._();

  // Padding & Margins
  static double get paddingXS => 4.0.w;
  static double get paddingS => 8.0.w;
  static double get paddingM => 12.0.w;
  static double get padding => 16.0.w;
  static double get paddingL => 20.0.w;
  static double get paddingXL => 24.0.w;
  static double get paddingXXL => 32.0.w;
  static double get paddingXXXL => 48.0.w;

  static double get marginXS => 4.0.w;
  static double get marginS => 8.0.w;
  static double get marginM => 12.0.w;
  static double get margin => 16.0.w;
  static double get marginL => 20.0.w;
  static double get marginXL => 24.0.w;
  static double get marginXXL => 32.0.w;
  static double get marginXXXL => 48.0.w;

  // Border Radius
  static double get radiusXS => 4.0.r;
  static double get radiusS => 8.0.r;
  static double get radiusM => 12.0.r;
  static double get radius => 16.0.r;
  static double get radiusL => 20.0.r;
  static double get radiusXL => 24.0.r;
  static double get radiusXXL => 32.0.r;
  static double get radiusCircular => 999.0.r;

  // Icon Sizes
  static double get iconXS => 16.0.w;
  static double get iconS => 20.0.w;
  static double get iconM => 24.0.w;
  static double get icon => 28.0.w;
  static double get iconL => 32.0.w;
  static double get iconXL => 40.0.w;
  static double get iconXXL => 48.0.w;

  // Font Sizes
  static double get fontXS => 10.0.sp;
  static double get fontS => 12.0.sp;
  static double get fontM => 14.0.sp;
  static double get font => 16.0.sp;
  static double get fontL => 18.0.sp;
  static double get fontXL => 20.0.sp;
  static double get fontXXL => 24.0.sp;
  static double get fontXXXL => 32.0.sp;
  static double get fontDisplay => 48.0.sp;

  // Button Sizes
  static double get buttonHeightS => 36.0.h;
  static double get buttonHeight => 48.0.h;
  static double get buttonHeightL => 56.0.h;

  // AppBar
  static double get appBarHeight => 64.0.h;
  static double get appBarElevation => 0.0;

  // Bottom Navigation Bar
  static double get bottomNavHeight => 80.0.h;

  // Card
  static double get cardElevation => 2.0;
  static double get cardRadius => radius;

  // Spacing
  static double get spaceXS => 4.0.w;
  static double get spaceS => 8.0.w;
  static double get spaceM => 12.0.w;
  static double get space => 16.0.w;
  static double get spaceL => 20.0.w;
  static double get spaceXL => 24.0.w;
  static double get spaceXXL => 32.0.w;
  static double get spaceXXXL => 48.0.w;

  // Divider
  static double get dividerThickness => 1.0;
  static double get dividerIndent => padding;

  // Border Width
  static double get borderWidthThin => 0.5;
  static double get borderWidth => 1.0;
  static double get borderWidthThick => 2.0;
  static double get borderWidthSmall => 1.5;

  // Image Sizes
  static double get imageThumbS => 40.0.w;
  static double get imageThumb => 60.0.w;
  static double get imageThumbL => 80.0.w;
  static double get imageS => 100.0.w;
  static double get imageM => 150.0.w;
  static double get image => 200.0.w;
  static double get imageL => 250.0.w;
  static double get imageXL => 300.0.w;

  // Screen Breakpoints
  static double get mobileBreakpoint => 600.0;
  static double get tabletBreakpoint => 900.0;
  static double get desktopBreakpoint => 1200.0;

  // EdgeInsets helpers
  static EdgeInsets get paddingAllXS => EdgeInsets.all(paddingXS);
  static EdgeInsets get paddingAllS => EdgeInsets.all(paddingS);
  static EdgeInsets get paddingAllM => EdgeInsets.all(paddingM);
  static EdgeInsets get paddingAll => EdgeInsets.all(padding);
  static EdgeInsets get paddingAllL => EdgeInsets.all(paddingL);
  static EdgeInsets get paddingAllXL => EdgeInsets.all(paddingXL);
  static EdgeInsets get paddingAllXXL => EdgeInsets.all(paddingXXL);

  static EdgeInsets get paddingHorizontal =>
      EdgeInsets.symmetric(horizontal: padding);
  static EdgeInsets get paddingVertical =>
      EdgeInsets.symmetric(vertical: padding);

  static EdgeInsets get marginAll => EdgeInsets.all(margin);
  static EdgeInsets get marginHorizontal =>
      EdgeInsets.symmetric(horizontal: margin);
  static EdgeInsets get marginVertical =>
      EdgeInsets.symmetric(vertical: margin);

  // SizedBox helpers
  static SizedBox get heightXS => SizedBox(height: spaceXS);
  static SizedBox get heightS => SizedBox(height: spaceS);
  static SizedBox get heightM => SizedBox(height: spaceM);
  static SizedBox get height => SizedBox(height: space);
  static SizedBox get heightL => SizedBox(height: spaceL);
  static SizedBox get heightXL => SizedBox(height: spaceXL);
  static SizedBox get heightXXL => SizedBox(height: spaceXXL);

  static SizedBox get widthXS => SizedBox(width: spaceXS);
  static SizedBox get widthS => SizedBox(width: spaceS);
  static SizedBox get widthM => SizedBox(width: spaceM);
  static SizedBox get width => SizedBox(width: space);
  static SizedBox get widthL => SizedBox(width: spaceL);
  static SizedBox get widthXL => SizedBox(width: spaceXL);
  static SizedBox get widthXXL => SizedBox(width: spaceXXL);
}
