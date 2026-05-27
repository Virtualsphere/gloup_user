import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/utils/salon_address_formatter.dart';
import 'package:tressy/shared/widgets/responsive_ellipsis_text.dart';

/// Responsive location + distance row for salon cards.
class SalonLocationRow extends StatelessWidget {
  const SalonLocationRow({
    super.key,
    required this.locationLabel,
    this.distanceKm,
    this.showDistance = true,
    this.isDarkMode = false,
    this.useTwoLines = true,
  });

  /// Pre-formatted `displayAddress` or raw address (parsed internally).
  final String? locationLabel;
  final double? distanceKm;
  final bool showDistance;
  final bool isDarkMode;
  final bool useTwoLines;

  @override
  Widget build(BuildContext context) {
    final parts = SalonAddressFormatter.parse(locationLabel);
    final secondaryColor =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final locationStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: secondaryColor,
          fontSize: AppSizes.fontS,
          height: 1.25,
        );
    final cityStyle = locationStyle?.copyWith(fontWeight: FontWeight.w600);

    final showTwoLines = useTwoLines && parts.hasArea && parts.hasCity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            AppIcons.icLocation,
            width: AppSizes.iconXS,
            height: AppSizes.iconXS,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: showTwoLines
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveEllipsisText(
                      text: parts.area,
                      style: locationStyle,
                      maxLines: 1,
                    ),
                    ResponsiveEllipsisText(
                      text: parts.city,
                      style: cityStyle,
                      maxLines: 1,
                    ),
                  ],
                )
              : ResponsiveEllipsisText(
                  text: parts.singleLine,
                  style: locationStyle,
                  maxLines: 2,
                ),
        ),
        if (showDistance && distanceKm != null) ...[
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _DistanceChip(
              distanceKm: distanceKm!,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ],
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({
    required this.distanceKm,
    required this.isDarkMode,
  });

  final double distanceKm;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color =
        isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.primaryDark.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${distanceKm.toStringAsFixed(1)} KM',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
