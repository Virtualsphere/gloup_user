import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class SearchShimmer extends StatelessWidget {
  final bool isDarkMode;

  const SearchShimmer({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 16,
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        bottom: 16,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
            highlightColor:
                isDarkMode ? AppColors.borderDark : AppColors.background,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                children: [
                  // Image placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.borderDark : AppColors.divider,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusM),
                        bottomLeft: Radius.circular(AppSizes.radiusM),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  // Content placeholder
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Distance
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Price
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
