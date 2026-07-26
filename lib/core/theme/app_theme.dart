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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: GoogleFonts.inter(
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
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary, width: AppSizes.borderWidth),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingS,
        ),
        textStyle: TextStyle(
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
        borderSide: BorderSide(
            color: AppColors.primary, width: AppSizes.borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(
            color: AppColors.error, width: AppSizes.borderWidthThick),
      ),
      hintStyle: const TextStyle(color: AppColors.textHint),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: AppSizes.dividerThickness,
      space: AppSizes.space,
    ),
    iconTheme: IconThemeData(
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
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: GoogleFonts.inter(
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
        backgroundColor: AppColors.primaryDarkTheme,
        foregroundColor: AppColors.onPrimaryDarkTheme,
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDarkTheme,
        side: BorderSide(
            color: AppColors.primaryDarkTheme, width: AppSizes.borderWidth),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingXL,
          vertical: AppSizes.paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        textStyle: TextStyle(
          fontSize: AppSizes.font,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDarkTheme,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingS,
        ),
        textStyle: TextStyle(
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
        borderSide: BorderSide(
            color: AppColors.primaryDarkTheme,
            width: AppSizes.borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide: BorderSide(
            color: AppColors.error, width: AppSizes.borderWidthThick),
      ),
      hintStyle: const TextStyle(color: AppColors.textHintDark),
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.dividerDark,
      thickness: AppSizes.dividerThickness,
      space: AppSizes.space,
    ),
    iconTheme: IconThemeData(
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
      displayLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontXXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      // Headlines - Bodoni MT (primary font for headlines)
      headlineLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      // Titles - Bodoni MT (primary font for titles)
      titleLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      // Body text - inter (secondary font for body/content)
      bodyLarge: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      ),
      // Labels - inter (secondary font for labels/buttons)
      labelLarge: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
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
      displayLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontDisplay,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontXXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryDark,
      ),
      // Headlines - Bodoni MT (primary font for headlines)
      headlineLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontXXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontXL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      // Titles - Bodoni MT (primary font for titles)
      titleLarge: GoogleFonts.inter(
        fontSize: AppSizes.fontL,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      // Body text - inter (secondary font for body/content)
      bodyLarge: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimaryDark,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondaryDark,
      ),
      // Labels - inter (secondary font for labels/buttons)
      labelLarge: GoogleFonts.inter(
        fontSize: AppSizes.font,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: AppSizes.fontM,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppSizes.fontS,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondaryDark,
      ),
    );
  }
}
