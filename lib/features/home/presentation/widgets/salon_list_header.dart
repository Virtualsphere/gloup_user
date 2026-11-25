import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';

/// "N salons around you" plus the Filters / Sort / quick-pick chips.
class SalonListHeader extends StatelessWidget {
  /// Total matches from `pagination.totalRecords`; null hides the count.
  final int? totalRecords;
  final FilterState filters;
  final ValueChanged<FilterState> onChanged;

  /// Opens the full Filters sheet. The chip is hidden until this is provided.
  final VoidCallback? onFiltersTap;
  final VoidCallback onSortTap;

  /// Hide the "N salons" heading when the page shows the count elsewhere.
  final bool showHeading;

  /// Offers quick pick; Figma's Home shows only Filters, Sort, Nearest and
  /// Rating, so it is off by default.
  final bool showOffersChip;

  const SalonListHeader({
    super.key,
    required this.totalRecords,
    required this.filters,
    required this.onChanged,
    required this.onSortTap,
    this.onFiltersTap,
    this.showHeading = true,
    this.showOffersChip = false,
  });

  static const double ratingQuickPick = 4.0;

  static String countLabel(int total) =>
      total == 1 ? '1 salon around you' : '$total salons around you';

  /// Relevance already orders by distance, so Nearest reads as selected by
  /// default (Figma) and only a different sort deselects it.
  bool get _nearest =>
      filters.sort == SalonSort.relevance || filters.sort == SalonSort.distance;
  bool get _topRated => filters.minRating == ratingQuickPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: HomeDesignTokens.screenGutter.w,
            ),
            child: Text(
              totalRecords == null
                  ? 'Salons around you'
                  : countLabel(totalRecords!),
              key: const Key('salon_count'),
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(
          height: 32.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: HomeDesignTokens.screenGutter.w,
            ),
            child: Row(children: [
              if (onFiltersTap != null)
                _Chip(
                  key: const Key('chip_filters'),
                  label: filters.activeCount > 0
                      ? 'Filters ${filters.activeCount}'
                      : 'Filters',
                  icon: Icons.tune_rounded,
                  selected: filters.activeCount > 0,
                  onTap: onFiltersTap!,
                ),
              _Chip(
                key: const Key('chip_sort'),
                label: 'Sort',
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                selected: !_nearest,
                onTap: onSortTap,
              ),
              _Chip(
                key: const Key('chip_nearest'),
                label: 'Nearest',
                selected: _nearest,
                onTap: () => onChanged(filters.copyWith(
                  sort: SalonSort.distance,
                )),
              ),
              _Chip(
                key: const Key('chip_rating'),
                label: 'Rating 4.0+',
                selected: _topRated,
                onTap: () => onChanged(
                  _topRated
                      ? filters.copyWith(clearMinRating: true)
                      : filters.copyWith(minRating: ratingQuickPick),
                ),
              ),
              if (showOffersChip)
                _Chip(
                  key: const Key('chip_offers'),
                  label: 'Offers',
                  selected: filters.hasOffers,
                  onTap: () => onChanged(
                    filters.copyWith(hasOffers: !filters.hasOffers),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final fg =
        selected ? HomeDesignTokens.accentBlue : HomeDesignTokens.textPrimary;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: selected
                ? HomeDesignTokens.accentBlueBg
                : HomeDesignTokens.surface,
            borderRadius: BorderRadius.circular(HomeDesignTokens.chipRadius.r),
            border: Border.all(
              color: selected
                  ? HomeDesignTokens.accentBlue
                  : HomeDesignTokens.border,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.w, color: fg),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: 2.w),
                Icon(trailingIcon, size: 16.w, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
