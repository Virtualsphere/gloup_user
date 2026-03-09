import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ReviewSummaryWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starCounts; // star rating (5-1) -> count

  const ReviewSummaryWidget({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.starCounts,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Average rating
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating number
              Text(
                averageRating.toStringAsFixed(1),
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              AppSizes.heightXS,
              // Star icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : (index < averageRating ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              AppSizes.heightXS,
              // Total reviews count
              Text(
                '$totalReviews ratings',
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.paddingL),
        // Right side - Star breakdown
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildStarProgressBar(5, starCounts[5] ?? 0, totalReviews, isDarkMode),
              AppSizes.heightS,
              _buildStarProgressBar(4, starCounts[4] ?? 0, totalReviews, isDarkMode),
              AppSizes.heightS,
              _buildStarProgressBar(3, starCounts[3] ?? 0, totalReviews, isDarkMode),
              AppSizes.heightS,
              _buildStarProgressBar(2, starCounts[2] ?? 0, totalReviews, isDarkMode),
              AppSizes.heightS,
              _buildStarProgressBar(1, starCounts[1] ?? 0, totalReviews, isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarProgressBar(int stars, int count, int total, bool isDarkMode) {
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        // Star number
        Text(
          '$stars',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        // Star icon
        Icon(
          Icons.star,
          size: 14,
          color: Colors.amber,
        ),
        const SizedBox(width: AppSizes.paddingS),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDarkMode
                  ? AppColors.textSecondary.withValues(alpha: 0.2)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        // Count
        SizedBox(
          width: 30,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
