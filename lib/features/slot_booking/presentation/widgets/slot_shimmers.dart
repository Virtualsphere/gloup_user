import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Shimmer loading widgets for Slot Booking screen
class SlotShimmers {
  /// Shimmer for time slot grid
  static Widget slotGridShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSizes.spaceM,
          mainAxisSpacing: AppSizes.spaceM,
          childAspectRatio: 3,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          return _slotCardShimmer(isDarkMode);
        },
      ),
    );
  }

  /// Shimmer for a single slot card
  static Widget _slotCardShimmer(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
    );
  }

  /// Shimmer for calendar section
  static Widget calendarShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        child: Row(
          children: List.generate(7, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Shimmer for section header
  static Widget sectionHeaderShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Container(
              width: 100,
              height: 14,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full slot booking page shimmer
  static Widget fullPageShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar shimmer
        calendarShimmer(context),
        
        const SizedBox(height: AppSizes.spaceL),
        
        // Section header shimmer
        sectionHeaderShimmer(context),
        
        const SizedBox(height: AppSizes.spaceM),
        
        // Slot grid shimmer
        Expanded(
          child: slotGridShimmer(context),
        ),
      ],
    );
  }
}
