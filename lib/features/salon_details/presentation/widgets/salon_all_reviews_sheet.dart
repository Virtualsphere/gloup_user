import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/cubit/salon_details_page_cubit.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/review_card.dart';
import 'package:tressy/shared/widgets/review_summary_widget.dart';

/// Full-screen sheet listing all salon reviews.
class SalonAllReviewsSheet extends StatefulWidget {
  final SalonDetailEntity salonDetail;
  final bool isDarkMode;
  final int initialFilterIndex;

  const SalonAllReviewsSheet({
    super.key,
    required this.salonDetail,
    required this.isDarkMode,
    this.initialFilterIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required SalonDetailEntity salonDetail,
    required bool isDarkMode,
    int initialFilterIndex = 0,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: isDarkMode
          ? AppColors.surfaceDark
          : SalonDetailDesignTokens.pageBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      builder: (_) => SalonAllReviewsSheet(
        salonDetail: salonDetail,
        isDarkMode: isDarkMode,
        initialFilterIndex: initialFilterIndex,
      ),
    );
  }

  @override
  State<SalonAllReviewsSheet> createState() => _SalonAllReviewsSheetState();
}

class _SalonAllReviewsSheetState extends State<SalonAllReviewsSheet> {
  late int _activeFilterIndex;

  @override
  void initState() {
    super.initState();
    _activeFilterIndex = widget.initialFilterIndex;
  }

  List<ReviewEntity> get _filteredReviews {
    if (_activeFilterIndex == 0) return widget.salonDetail.reviews;

    final stars = 6 - _activeFilterIndex;
    return widget.salonDetail.reviews
        .where((review) => review.rating.round() == stars)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final starCounts = SalonDetailsPageCubit.calculateStarCounts(
      widget.salonDetail.reviews,
    );
    final totalReviews = widget.salonDetail.reviewCount;
    final isDarkMode = widget.isDarkMode;
    final filteredReviews = _filteredReviews;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.paddingM,
                AppSizes.paddingM,
                AppSizes.paddingM,
                AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'All reviews',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : SalonDetailDesignTokens.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : SalonDetailDesignTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                children: [
                  ReviewSummaryWidget(
                    averageRating: widget.salonDetail.rating,
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
                        final isActive = _activeFilterIndex == index;
                        final count = index == 0
                            ? totalReviews
                            : (starCounts[6 - index] ?? 0);

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _activeFilterIndex = index),
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
                                      ? AppColors.textSecondary
                                          .withValues(alpha: 0.2)
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.15)),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusCircular,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                index == 0
                                    ? 'All ($count)'
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AppSizes.heightL,
                  if (filteredReviews.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(AppSizes.paddingXL),
                      child: Center(
                        child: Text(
                          'No reviews in this filter',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredReviews.map(
                      (review) => ReviewCard(
                        userName: review.userName,
                        userImage: review.userImage,
                        timeAgo: review.timeAgo,
                        rating: review.rating,
                        reviewText: review.reviewText,
                      ),
                    ),
                  SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
