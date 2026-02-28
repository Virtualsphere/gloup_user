import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Black & White (Light Theme)
  static const Color primary = Color(0xFF000000); // Black
  static const Color primaryLight = Color(0xFF212121); // Dark Gray
  static const Color primaryDark = Color(0xFFFFFFFF); // Pure Black
  static const Color onPrimary = Color(0xFFFFFFFF); // White text on black

  // Primary Colors - White & Black (Dark Theme)
  static const Color primaryDarkTheme = Color(0xFFFFFFFF); // White
  static const Color primaryLightDarkTheme = Color(0xFFF5F5F5); // Off White
  static const Color primaryDarkDarkTheme = Color(0xFFEEEEEE); // Light Gray
  static const Color onPrimaryDarkTheme = Color(0xFF000000); // Black text on white

  // Secondary Colors - Light Violet (Both Themes)
  static const Color secondary = Color(0xFFB39DDB); // Light Violet
  static const Color secondaryLight = Color(0xFFD1C4E9); // Lighter Violet
  static const Color secondaryDark = Color(0xFF9575CD); // Darker Violet
  static const Color onSecondary = Color(0xFF000000); // Black text on violet

  // Secondary Colors - Dark Theme Variant
  static const Color secondaryDarkTheme = Color(0xFF9575CD); // Deeper Violet
  static const Color secondaryLightDarkTheme = Color(0xFFB39DDB); // Medium Violet
  static const Color secondaryDarkDarkTheme = Color(0xFF7E57C2); // Dark Violet
  static const Color onSecondaryDarkTheme = Color(0xFFFFFFFF); // White text

  // Tertiary Colors - Gold (Both Themes)
  static const Color tertiary = Color(0xFFFFD700); // Gold
  static const Color tertiaryLight = Color(0xFFFFE57F); // Light Gold
  static const Color tertiaryDark = Color(0xFFFFC107); // Amber Gold
  static const Color onTertiary = Color(0xFF000000); // Black text on gold

  // Tertiary Colors - Dark Theme Variant
  static const Color tertiaryDarkTheme = Color(0xFFFFD700); // Gold
  static const Color tertiaryLightDarkTheme = Color(0xFFFFE082); // Light Gold
  static const Color tertiaryDarkDarkTheme = Color(0xFFFFB300); // Dark Gold
  static const Color onTertiaryDarkTheme = Color(0xFF000000); // Black text

  // Legacy Accent Colors (Deprecated - use tertiary instead)
  @Deprecated('Use tertiary instead')
  static const Color accent = tertiaryDark;
  @Deprecated('Use tertiaryLight instead')
  static const Color accentLight = tertiaryLight;

  // Background Colors
  static const Color background = Color(0xFFEEEEEE);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF757575);
  static const Color textDisabledDark = Color(0xFF616161);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Divider & Border Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color dividerDark = Color(0xFF424242);
  static const Color borderDark = Color(0xFF616161);

  // Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color borderColor = Color(0xFFEDEDED);
  static const Color disabledColor = Color(0XFFF5F5F5);
  static const Color circleGreyColor = Color(0xFFEFECEC);
  static const Color ratingYellowDark = Color(0xFFFFDA09);
  static const Color ratingYellowLight = Color(0xFFFFF3AD);
  static const Color darkRed = Color(0XFFFF0202);
  static const Color greenText = Color(0xFF00C10D);
  static const Color secondaryColor = Color(0xFFB5B5B5);
  static const Color scaffoldBackground = Color(0XFFFFFFFF);
  static const Color greyColor = Color(0xFF808080);

  // Gradient Colors - Light Theme
  static const List<Color> primaryGradient = [
    primary,
    primaryLight,
  ];

  static const List<Color> secondaryGradient = [
    secondaryLight,
    secondaryDark,
  ];

  static const List<Color> tertiaryGradient = [
    tertiaryLight,
    tertiaryDark,
  ];

  // Gradient Colors - Dark Theme
  static const List<Color> primaryGradientDark = [
    primaryDarkTheme,
    primaryDarkDarkTheme,
  ];

  static const List<Color> secondaryGradientDark = [
    secondaryLightDarkTheme,
    secondaryDarkDarkTheme,
  ];

  static const List<Color> tertiaryGradientDark = [
    tertiaryLightDarkTheme,
    tertiaryDarkDarkTheme,
  ];
}
