import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';

/// Shimmer loading widgets for Explore screen
class ExploreShimmers {
  /// Shimmer for explore salon card list
  static Widget exploreSalonListShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSizes.paddingM),
            child: _exploreSalonCardShimmer(isDarkMode),
          );
        },
      ),
    );
  }

  /// Shimmer for a single explore salon card
  static Widget _exploreSalonCardShimmer(bool isDarkMode) {
    return Builder(
      builder: (context) => HomeShimmers.buildVerticalSalonCardShimmer(context),
    );
  }

  /// Shimmer for section header
  static Widget sectionHeaderShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
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
            SizedBox(height: AppSizes.spaceXS),
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

  /// Full explore page shimmer (for use in SliverList)
  static List<Widget> explorePageShimmerSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

      // Section header shimmer
      SliverToBoxAdapter(
        child: sectionHeaderShimmer(context),
      ),

      SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

      // Salon cards shimmer
      SliverToBoxAdapter(
        child: exploreSalonListShimmer(context),
      ),
    ];
  }
}
