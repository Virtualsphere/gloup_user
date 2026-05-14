import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';

class BookingsShimmer {
  static Widget bookingListShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? const Color(0xFF2A2A2A) : AppColors.divider,
      highlightColor:
          isDarkMode ? const Color(0xFF3A3A3A) : AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => _bookingCardShimmer(isDarkMode),
      ),
    );
  }

  static Widget _bookingCardShimmer(bool isDarkMode) {
    final base = isDarkMode ? const Color(0xFF2A2A2A) : AppColors.divider;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppColors.borderDark.withValues(alpha: 0.4)
              : AppColors.borderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image placeholder
            Container(
              height: 130,
              width: double.infinity,
              color: base,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking ID row
                  _shimmerBox(base, width: 130, height: 12),
                  const SizedBox(height: 12),

                  // Date + Time pills
                  Row(
                    children: [
                      _shimmerPill(base, width: 110),
                      const SizedBox(width: 8),
                      _shimmerPill(base, width: 140),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // "Services" label
                  _shimmerBox(base, width: 70, height: 11),
                  const SizedBox(height: 10),

                  // Service rows
                  _serviceRowShimmer(base),
                  _serviceRowShimmer(base),
                  _serviceRowShimmer(base, lastRow: true),

                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: base,
                  ),
                  const SizedBox(height: 10),

                  // Total row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBox(base, width: 70, height: 13),
                      _shimmerBox(base, width: 60, height: 18),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // Button placeholder
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _serviceRowShimmer(Color base, {bool lastRow = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: lastRow ? 0 : 6),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          _shimmerBox(base, width: 120, height: 11),
          const Spacer(),
          _shimmerBox(base, width: 40, height: 11),
        ],
      ),
    );
  }

  static Widget _shimmerPill(Color base, {required double width}) {
    return Container(
      width: width,
      height: 30,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static Widget _shimmerBox(Color base,
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
