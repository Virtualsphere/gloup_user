import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class HomeShimmers {
  /// Build shimmer effect for carousel loading
  static Widget buildCarouselShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? AppColors.surfaceDark : AppColors.divider,
              isDarkMode ? AppColors.backgroundDark : AppColors.border,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cut_outlined,
                size: 80,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              SizedBox(height: AppSizes.paddingM),
              Container(
                width: 150,
                height: 16,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(height: AppSizes.paddingS),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build shimmer effect for salon cards loading
  static Widget buildSalonCardsShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildSalonCardShimmerItem();
        },
      ),
    );
  }

  /// Build single salon card shimmer item
  static Widget _buildSalonCardShimmerItem() {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusL),
                topRight: Radius.circular(AppSizes.radiusL),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: AppSizes.spaceS),
                // Rating and distance placeholder
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceS),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spaceS),
                // Service info placeholder
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for vertical salon cards
  static Widget buildVerticalSalonCardShimmer(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusL),
                  topRight: Radius.circular(AppSizes.radiusL),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  SizedBox(height: AppSizes.spaceM),
                  // Rating and distance placeholder
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceM),
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spaceM),
                  // Service info placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spaceM),
                  // Categories placeholder
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceS),
                      Container(
                        width: 70,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(width: AppSizes.spaceS),
                      Container(
                        width: 50,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
