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

  const SalonListHeader({
    super.key,
    required this.totalRecords,
    required this.filters,
    required this.onChanged,
    required this.onSortTap,
    this.onFiltersTap,
    this.showHeading = true,
  });

  static const double ratingQuickPick = 4.0;

  static String countLabel(int total) =>
      total == 1 ? '1 salon around you' : '$total salons around you';

  bool get _nearest => filters.sort == SalonSort.distance;
  bool get _topRated => filters.minRating == ratingQuickPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading) ...[
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(
          height: 36.h,
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
                icon: Icons.swap_vert_rounded,
                selected: filters.sort != SalonSort.relevance && !_nearest,
                onTap: onSortTap,
              ),
              _Chip(
                key: const Key('chip_nearest'),
                label: 'Nearest',
                selected: _nearest,
                onTap: () => onChanged(filters.copyWith(
                  sort: _nearest ? SalonSort.relevance : SalonSort.distance,
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
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
