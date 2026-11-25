import 'package:flutter/material.dart';

/// Figma "GloUp app for development" — section 04 · Home & discovery
/// (nodes 3-2, 4-2, 5-2, 6-2, 67-2).
///
/// Values are read from the design screenshots; verify against Figma
/// Dev Mode when pixel-matching a screen.
abstract final class HomeDesignTokens {
  static const pageBackground = Color(0xFFF3F4F6);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF262A30);
  static const textSecondary = Color(0xFF717784);
  static const textHint = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);

  /// Selected chips, "Next slot" text, Copy button.
  static const accentBlue = Color(0xFF2D6FA6);
  static const accentBlueBg = Color(0xFFEAF3FB);

  /// Offer text on Favorites ("50% off").
  static const offerGreen = Color(0xFF3B956B);

  /// Dark rating pill and offer-badge background.
  static const ratingPillBg = Color(0xFF262A30);
  static const ratingPillText = Color(0xFFFFFFFF);
  static const offerBadgeBg = Color(0xFF262A30);
  static const offerBadgeText = Color(0xFFFFFFFF);

  static const heroBannerBg = Color(0xFF262A30);
  static const modalScrim = Color(0x99000000);

  static const double cardRadius = 16;
  static const double tileRadius = 16;
  static const double chipRadius = 20;
  static const double sheetTopRadius = 24;
  static const double screenGutter = 16;

  /// Figma frame width the layouts are designed on.
  static const double designWidth = 390;
}
