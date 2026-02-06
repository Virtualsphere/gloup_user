import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary, // Black
      secondary: AppColors.secondary, // Light Violet
      tertiary: AppColors.tertiary, // Gold
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary, // White on Black
      onSecondary: AppColors.onSecondary, // Black on Violet
      onTertiary: AppColors.onTertiary, // Black on Gold
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppSizes.appBarElevation,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleTextStyle: GoogleFonts.bodoniModa(
        color: AppColors.white,
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      color: AppColors.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidth),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingS,
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: AppSizes.paddingAll,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderWidthThick),
      ),
      hintStyle: const TextStyle(color: AppColors.textHint),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: AppSizes.dividerThickness,
      space: AppSizes.space,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: AppSizes.iconM,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0, // Remove shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
    ),
    textTheme: _textTheme,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDarkTheme,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDarkTheme, // White
      secondary: AppColors.secondaryDarkTheme, // Deeper Violet
      tertiary: AppColors.tertiaryDarkTheme, // Gold
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.onPrimaryDarkTheme, // Black on White
      onSecondary: AppColors.onSecondaryDarkTheme, // White on Violet
      onTertiary: AppColors.onTertiaryDarkTheme, // Black on Gold
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),
    appBarTheme: AppBarTheme(
      elevation: AppSizes.appBarElevation,
      centerTitle: true,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleTextStyle: GoogleFonts.bodoniModa(
        color: AppColors.white,
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      color: AppColors.surfaceDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidth),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingS,
        ),
        textStyle: const TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: AppSizes.paddingAll,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderWidthThick),
      ),
      hintStyle: const TextStyle(color: AppColors.textHintDark),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: AppSizes.dividerThickness,
      space: AppSizes.space,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimaryDark,
      size: AppSizes.iconM,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0, // Remove shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
    ),
    textTheme: _darkTextTheme,
  );

  // Text theme with Google Fonts - Light Theme
  static TextTheme get _textTheme {
    return TextTheme(
      // Display text - Bodoni MT (primary/elegant font for large displays)
      displayLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      // Headlines - Bodoni MT (primary font for headlines)
      headlineLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // Titles - Bodoni MT (primary font for titles)
      titleLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      // Body text - Outfit (secondary font for body/content)
      bodyLarge: GoogleFonts.outfit(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      // Labels - Outfit (secondary font for labels/buttons)
      labelLarge: GoogleFonts.outfit(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // Text theme with Google Fonts - Dark Theme
  static TextTheme get _darkTextTheme {
    return TextTheme(
      // Display text - Bodoni MT (primary/elegant font for large displays)
      displayLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      // Headlines - Bodoni MT (primary font for headlines)
      headlineLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      // Titles - Bodoni MT (primary font for titles)
      titleLarge: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: GoogleFonts.bodoniModa(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: GoogleFonts.bodoniModa(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      // Body text - Outfit (secondary font for body/content)
      bodyLarge: GoogleFonts.outfit(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryDark,
      ),
      // Labels - Outfit (secondary font for labels/buttons)
      labelLarge: GoogleFonts.outfit(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark,
      ),
    );
  }
}
