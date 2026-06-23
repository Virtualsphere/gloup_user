import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Shared, overflow-safe row that renders salon language icons on the left and
/// category chips on the right.
///
/// The language cluster takes its intrinsic width while the category cluster is
/// wrapped in [Expanded] and ellipsizes, so the row can never overflow on any
/// screen size. All salon cards should use this instead of bespoke copies.
class SalonBadgesRow extends StatelessWidget {
  const SalonBadgesRow({
    super.key,
    this.languageCodes,
    this.categories,
    this.maxLanguages = 3,
    this.maxCategories = 2,
    this.languageIconSize = 14,
    this.languageFontSize = 8,
    this.separatorSize = 4,
    this.chipFontSize = 11,
    this.fallbackLanguages = const ['en', 'ta'],
    this.fallbackCategories = const ['Haircut', 'Facial'],
  });

  final List<String>? languageCodes;
  final List<String>? categories;
  final int maxLanguages;
  final int maxCategories;

  /// Logical size (pre-ScreenUtil) for each language glyph.
  final double languageIconSize;
  final double languageFontSize;
  final double separatorSize;
  final double chipFontSize;
  final List<String> fallbackLanguages;
  final List<String> fallbackCategories;

  static const Map<String, String> _languageIcons = {
    'ta': AppIcons.icTamil,
    'ml': AppIcons.icMalayalam,
    'hi': AppIcons.icHindi,
    'te': AppIcons.icTelugu,
    'kn': AppIcons.icKannada,
    'bn': AppIcons.icBengali,
    'gu': AppIcons.icGujarati,
    'en': AppIcons.icEnglish,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 0,
          child: _buildLanguageBadges(context),
        ),
        SizedBox(width: AppSizes.spaceS),
        Expanded(child: _buildCategoryBadges(context)),
      ],
    );
  }

  Widget _buildLanguageBadges(BuildContext context) {
    final codes = (languageCodes == null || languageCodes!.isEmpty)
        ? fallbackLanguages
        : languageCodes!;
    final display = codes.take(maxLanguages).toList();
    final muted = context.mutedOnSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: display.asMap().entries.expand((entry) {
        final index = entry.key;
        final code = entry.value;
        final iconPath = _languageIcons[code];
        final isLast = index == display.length - 1;

        final Widget glyph = iconPath != null
            ? SvgPicture.asset(
                iconPath,
                width: languageIconSize.w,
                height: languageIconSize.h,
                colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
              )
            : Container(
                width: (languageIconSize + 6).w,
                height: (languageIconSize + 6).h,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    code.length >= 2
                        ? code.substring(0, 2).toUpperCase()
                        : code.toUpperCase(),
                    style: TextStyle(
                      color: muted,
                      fontSize: languageFontSize.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );

        return [
          glyph,
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: separatorSize.w,
                height: separatorSize.h,
                decoration: BoxDecoration(
                  color: muted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ];
      }).toList(),
    );
  }

  Widget _buildCategoryBadges(BuildContext context) {
    final source = (categories == null || categories!.isEmpty)
        ? fallbackCategories
        : categories!;
    final display = source.take(maxCategories).toList();
    final remaining = source.length - display.length;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final category in display)
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F1FE),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF8F89CA),
                  fontSize: chipFontSize.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (remaining > 0)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: context.mutedOnSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                color: context.mutedOnSurface,
                fontSize: chipFontSize.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
