import 'package:flutter/material.dart';

/// App size constants for consistent spacing and sizing
class AppSizes {
  AppSizes._();

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double padding = 16.0;
  static const double paddingL = 20.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;
  static const double paddingXXXL = 48.0;

  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 12.0;
  static const double margin = 16.0;
  static const double marginL = 20.0;
  static const double marginXL = 24.0;
  static const double marginXXL = 32.0;
  static const double marginXXXL = 48.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radius = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircular = 999.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double icon = 28.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;

  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double font = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontXXXL = 32.0;
  static const double fontDisplay = 48.0;

  // Button Sizes
  static const double buttonHeightS = 36.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightL = 56.0;

  // AppBar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // Bottom Navigation Bar
  static const double bottomNavHeight = 80.0;

  // Card
  static const double cardElevation = 2.0;
  static const double cardRadius = radius;

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double space = 16.0;
  static const double spaceL = 20.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;
  static const double spaceXXXL = 48.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = padding;

  // Border Width
  static const double borderWidthThin = 0.5;
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // Image Sizes
  static const double imageThumbS = 40.0;
  static const double imageThumb = 60.0;
  static const double imageThumbL = 80.0;
  static const double imageS = 100.0;
  static const double imageM = 150.0;
  static const double image = 200.0;
  static const double imageL = 250.0;
  static const double imageXL = 300.0;

  // Screen Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // EdgeInsets helpers
  static const EdgeInsets paddingAllXS = EdgeInsets.all(paddingXS);
  static const EdgeInsets paddingAllS = EdgeInsets.all(paddingS);
  static const EdgeInsets paddingAllM = EdgeInsets.all(paddingM);
  static const EdgeInsets paddingAll = EdgeInsets.all(padding);
  static const EdgeInsets paddingAllL = EdgeInsets.all(paddingL);
  static const EdgeInsets paddingAllXL = EdgeInsets.all(paddingXL);
  static const EdgeInsets paddingAllXXL = EdgeInsets.all(paddingXXL);

  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: padding);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: padding);

  static const EdgeInsets marginAll = EdgeInsets.all(margin);
  static const EdgeInsets marginHorizontal = EdgeInsets.symmetric(horizontal: margin);
  static const EdgeInsets marginVertical = EdgeInsets.symmetric(vertical: margin);

  // SizedBox helpers
  static const SizedBox heightXS = SizedBox(height: spaceXS);
  static const SizedBox heightS = SizedBox(height: spaceS);
  static const SizedBox heightM = SizedBox(height: spaceM);
  static const SizedBox height = SizedBox(height: space);
  static const SizedBox heightL = SizedBox(height: spaceL);
  static const SizedBox heightXL = SizedBox(height: spaceXL);
  static const SizedBox heightXXL = SizedBox(height: spaceXXL);

  static const SizedBox widthXS = SizedBox(width: spaceXS);
  static const SizedBox widthS = SizedBox(width: spaceS);
  static const SizedBox widthM = SizedBox(width: spaceM);
  static const SizedBox width = SizedBox(width: space);
  static const SizedBox widthL = SizedBox(width: spaceL);
  static const SizedBox widthXL = SizedBox(width: spaceXL);
  static const SizedBox widthXXL = SizedBox(width: spaceXXL);
}
