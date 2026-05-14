import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Shimmer loading widgets for Favorites screen
class FavoritesShimmers {
  /// Shimmer for favorites salon card list
  static Widget favoritesSalonListShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            child: _favoritesSalonCardShimmer(isDarkMode),
          );
        },
      ),
    );
  }

  /// Shimmer for a single favorites salon card
  static Widget _favoritesSalonCardShimmer(bool isDarkMode) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          // Image shimmer
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusM),
                bottomLeft: Radius.circular(AppSizes.radiusM),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.spaceM),

          // Content shimmer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceDark
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceS),

                  // Rating row
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

                  const SizedBox(height: AppSizes.spaceS),

                  // Address
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceDark
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const Spacer(),

                  // Service and price row
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.surfaceDark
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 14,
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
          ),

          const SizedBox(width: AppSizes.spaceM),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 22,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Container(
              width: 250,
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

  /// Full favorites page shimmer (for use in SliverList)
  static List<Widget> favoritesPageShimmerSlivers(BuildContext context) {
    return [
      const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

      // Section header shimmer
      SliverToBoxAdapter(
        child: sectionHeaderShimmer(context),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

      // Salon cards shimmer
      SliverToBoxAdapter(
        child: favoritesSalonListShimmer(context),
      ),
    ];
  }
}
