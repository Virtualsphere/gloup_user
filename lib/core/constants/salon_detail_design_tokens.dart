import 'package:flutter/material.dart';

/// Figma Gloup-Onboarding-screens — store detail (2554:3100 / 2573:5164)
abstract final class SalonDetailDesignTokens {
  static const pageBackground = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF737373);
  static const openGreen = Color(0xFF21C45D);
  static const priceGreen = Color(0xFF21C45D);
  static const starGold = Color(0xFFFFC02E);
  static const accentBlue = Color(0xFF0C8CE9);
  static const femaleIconPink = Color(0xFFC41D7F);

  /// Hero carousel — taller hero keeps the info sheet lower on screen.
  static const carouselHeightFraction = 0.36;

  /// White sheet overlapping hero carousel (minimal lip on hero).
  static const infoSheetTopRadius = 18.0;
  static const infoSheetOverlap = 12.0;

  /// Pinned header: title + info + tabs (must cover full sheet + tab bar).
  static const stickyHeaderExtent = 248.0;

  /// Vertical rhythm inside the info sheet.
  static const infoSheetRowGap = 6.0;
  static const infoSheetSectionGap = 8.0;

  /// Category chips (Figma 2554:3534)
  static const chipCategoryBg = Color(0xFFF5F5F5);
  static const chipCategoryText = Color(0xFF6B7280);
  static const heroControlBg = Color(0xE6FFFFFF);
  static const heroControlIcon = Color(0xFF000000);
  static const dotTrack = Color(0x66FFFFFF);
  static const dotActive = Color(0xFFFFFFFF);
  static const ratingChipBg = Color(0xFFEEF9F4);
  static const ratingChipBorder = Color(0xFFE2F5EA);
  static const tabInactiveText = Color(0xFF9A9A9A);
  static const tabBarDivider = Color(0x1A000000);

  static const carouselGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x59000000)],
    stops: [0.541, 0.7772],
  );

  static List<BoxShadow> get infoSheetShadow => const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 32,
          offset: Offset(0, -4),
        ),
      ];

  /// Popular service card (mint tint)
  static const serviceCardPopularBg = Color(0xFFEEF9F4);
  static const serviceCardDefaultBg = Color(0xFFFFFFFF);
  static const serviceCardBorder = Color(0xFFE8E8E8);

  static const popularBadgeBg = Color(0x1A0C8CE9);
  static const popularBadgeText = Color(0xFF0C8CE9);
  static const discountBadgeBg = Color(0x1A21C45D);

  static const addButtonBg = Color(0xFF000000);
  static const addedButtonBg = Color(0xFFF3F4F6);
  static const addedButtonBorder = Color(0xFFE5E7EB);
  static const addedButtonText = Color(0xFF4B5563);
}
