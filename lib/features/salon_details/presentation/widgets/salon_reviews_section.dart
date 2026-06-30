import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_cubit.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/review_card.dart';
import 'package:tressy/shared/widgets/review_summary_widget.dart';

class SalonReviewsSection extends StatelessWidget {
  final bool isDarkMode;
  final SalonDetailEntity salonDetail;
  final int activeReviewFilterIndex;
  final ValueChanged<int> onReviewFilterChanged;
  final VoidCallback? onSeeAll;

  const SalonReviewsSection({
    super.key,
    required this.isDarkMode,
    required this.salonDetail,
    required this.activeReviewFilterIndex,
    required this.onReviewFilterChanged,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return _buildReviewsSection(context, isDarkMode, salonDetail);
  }

  Widget _buildReviewsSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'No reviews yet',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: AppSizes.spaceS),
              Text(
                'Be the first to review this salon',
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
      );
    }

    final starCounts = SalonDetailsPageCubit.calculateStarCounts(
      salonDetail.reviews,
    );
    final totalReviews = salonDetail.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewSummaryWidget(
          averageRating: salonDetail.rating,
          totalReviews: totalReviews,
          starCounts: starCounts,
        ),
        AppSizes.heightL,
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              final isActive = activeReviewFilterIndex == index;
              String label;
              int count;

              if (index == 0) {
                label = 'All';
                count = totalReviews;
              } else {
                final stars = 6 - index;
                label = '$stars ★';
                count = starCounts[stars] ?? 0;
              }

              return GestureDetector(
                onTap: () => onReviewFilterChanged(index),
                child: Container(
                  margin: EdgeInsets.only(right: AppSizes.paddingM),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary)
                        : (isDarkMode
                            ? AppColors.textSecondary.withValues(alpha: 0.2)
                            : AppColors.textSecondary.withValues(alpha: 0.15)),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: isActive
                                ? (isDarkMode
                                    ? AppColors.black
                                    : AppColors.white)
                                : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          index == 0
                              ? '$label ($count)'
                              : '${6 - index} ($count)',
                          style: TextStyle(
                            color: isActive
                                ? (isDarkMode
                                    ? AppColors.black
                                    : AppColors.white)
                                : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AppSizes.heightL,
        Column(
          children: [
            ...salonDetail.reviews.map((review) {
              return ReviewCard(
                userName: review.userName,
                userImage: review.userImage,
                timeAgo: review.timeAgo,
                rating: review.rating,
                reviewText: review.reviewText,
              );
            }),
            AppSizes.heightS,
            if (onSeeAll != null)
              OutlinedButton(
                onPressed: onSeeAll,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDarkMode
                        ? AppColors.textSecondary.withValues(alpha: 0.3)
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: AppSizes.paddingM,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See all ($totalReviews reviews)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceS),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
