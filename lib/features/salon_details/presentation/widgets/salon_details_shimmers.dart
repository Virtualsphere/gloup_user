import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class SalonDetailsShimmers {
  /// Build shimmer effect for carousel loading
  static Widget buildCarouselShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      ),
    );
  }

  /// Build shimmer effect for header (title, info, tabs)
  static Widget buildHeaderShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            // Badges shimmer
            Row(
              children: [
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AppSizes.widthS,
                Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            AppSizes.heightL,
            // Info shimmer lines
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
              width: 250,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
                width: 280,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                )),
            AppSizes.heightS,
          ],
        ),
      ),
    );
  }

  /// Build shimmer effect for about section
  static Widget buildAboutShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: 250,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for opening hours section
  static Widget buildOpeningHoursShimmer(
      BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        children: List.generate(
          7,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // Dot shimmer
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                // Day shimmer
                Expanded(
                  child: Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Hours shimmer
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build shimmer effect for reviews section
  static Widget buildReviewsShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review summary shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AppSizes.heightS,
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              // Right side - progress bars
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Container(
                            width: 30,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSizes.heightL,
          // Filter badges shimmer
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                );
              },
            ),
          ),
          AppSizes.heightL,
          // Review cards shimmer
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      // Name and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stars
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  AppSizes.heightM,
                  // Review text
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AppSizes.heightS,
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AppSizes.heightS,
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for team section
  static Widget buildTeamShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

          return Wrap(
            spacing: AppSizes.paddingL,
            runSpacing: AppSizes.paddingL,
            children: List.generate(
              4,
              (index) => SizedBox(
                width: cardWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile circle shimmer
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSizes.heightS,
                    // Name shimmer
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Role shimmer
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build shimmer effect for ambients section
  static Widget buildAmbientsShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - (AppSizes.paddingM * 2)) / 3;

          return Wrap(
            spacing: AppSizes.paddingM,
            runSpacing: AppSizes.paddingM,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: cardWidth,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build shimmer effect for services section
  static Widget buildServicesShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badges shimmer
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                );
              },
            ),
          ),
          AppSizes.heightL,
          // Service cards shimmer
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AppSizes.heightS,
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AppSizes.heightS,
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for location section
  static Widget buildLocationShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map shimmer
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
          ),
          AppSizes.heightL,
          // Address shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
              AppSizes.widthS,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AppSizes.heightXS,
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.heightL,
          // Button shimmer
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
          ),
        ],
      ),
    );
  }
}
