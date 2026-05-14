import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Shimmer loading widgets for Guest list
class GuestShimmers {
  /// Shimmer for guest list
  static Widget guestListShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            child: _guestCardShimmer(isDarkMode),
          );
        },
      ),
    );
  }

  /// Shimmer for a single guest card
  static Widget _guestCardShimmer(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar shimmer
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: AppSizes.spaceM),

          // Content shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceS),

                // Details row
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Radio button shimmer
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
