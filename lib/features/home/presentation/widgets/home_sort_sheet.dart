import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';

/// Simple "Sort by" sheet. Phase 4 folds this into the full Filters sheet.
class HomeSortSheet extends StatelessWidget {
  final SalonSort selected;

  const HomeSortSheet({super.key, required this.selected});

  /// Options the list endpoint can honour today (no earliest-slot data yet).
  static const options = <SalonSort, String>{
    SalonSort.relevance: 'Relevance',
    SalonSort.distance: 'Nearest first',
    SalonSort.rating: 'Highest rated',
    SalonSort.priceLowToHigh: 'Price: low to high',
    SalonSort.priceHighToLow: 'Price: high to low',
  };

  static Future<SalonSort?> show(BuildContext context, SalonSort selected) {
    return showModalBottomSheet<SalonSort>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HomeDesignTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HomeDesignTokens.sheetTopRadius.r),
        ),
      ),
      builder: (_) => HomeSortSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: HomeDesignTokens.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            for (final entry in options.entries)
              ListTile(
                key: Key('sort_${entry.key.name}'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  entry.value,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: entry.key == selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: HomeDesignTokens.textPrimary,
                  ),
                ),
                trailing: entry.key == selected
                    ? const Icon(Icons.check_rounded,
                        color: HomeDesignTokens.accentBlue)
                    : null,
                onTap: () => Navigator.of(context).pop(entry.key),
              ),
          ],
        ),
      ),
    );
  }
}
