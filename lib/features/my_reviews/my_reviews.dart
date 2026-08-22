import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/enums.dart';
import 'package:tressy/core/services/review_service.dart';
import 'package:tressy/features/profile/presentation/model/review_data.dart';
import 'package:tressy/features/widgets/add_rating_dialogue.dart';
import 'package:tressy/features/widgets/custom_button.dart';
import 'package:tressy/features/widgets/custom_dialogues.dart';
import 'package:tressy/features/widgets/custom_image.dart';
import 'package:tressy/features/widgets/custom_rating_bar.dart';
import 'package:tressy/features/widgets/profile_appbar.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class MyReviews extends StatefulWidget {
  const MyReviews({super.key});

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  List<UserReview> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ReviewService.fetchMyReviews();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result == null) {
        _error = 'Could not load your reviews. Please try again.';
        _reviews = [];
      } else {
        _reviews = result.reviews;
      }
    });
  }

  Future<void> _handleEdit(UserReview review) async {
    final reviewData = review.toReviewData();
    final updated = await AddRatingDialogue().showAddReviewDialogue(
      context: context,
      reviewData: reviewData,
      isEditReview: true,
      onSubmit: (rating, description) {
        return ReviewService.updateReview(
          reviewId: review.id,
          rating: rating,
          description: description,
        );
      },
    );

    if (!mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review updated')),
      );
      await _loadReviews();
    } else if (updated == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update review')),
      );
    }
  }

  Future<void> _handleDelete(UserReview review) async {
    CustomDialogues.showCancelDialogue(
      context,
      title: 'delete this review',
      submitOnTap: () async {
        Navigator.of(context).pop();
        final success = await ReviewService.deleteReview(reviewId: review.id);
        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review deleted')),
          );
          await _loadReviews();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not delete review')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: ProfileAppBar(
        title: 'My Reviews',
        centerTitle: true,
        onBack: () => GoRouter.of(context).pop(),
      ),
      body: SafeArea(child: _buildBody(isDarkMode)),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadReviews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete a booking and share your experience',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: EdgeInsets.only(top: AppSizes.paddingL),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return MyReviewContainer(
            reviewData: review.toReviewData(),
            onEdit: () => _handleEdit(review),
            onDelete: () => _handleDelete(review),
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}

class MyReviewContainer extends StatelessWidget {
  const MyReviewContainer({
    super.key,
    required this.reviewData,
    required this.onEdit,
    required this.onDelete,
    required this.isDarkMode,
  });

  final ReviewData reviewData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDarkMode;

  String _locationLabel() {
    final city = reviewData.city?.trim();
    final district = reviewData.district?.trim();
    if (district != null && district.isNotEmpty && city != null && city.isNotEmpty) {
      return '$district, $city';
    }
    return city ?? district ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final location = _locationLabel();
    final imageUrl = reviewData.storeImages?.isNotEmpty == true
        ? reviewData.storeImages!.first
        : '';

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: imageUrl,
                        imageType: ImageType.images,
                      )
                    : ColoredBox(
                        color: isDarkMode
                            ? AppColors.backgroundDark
                            : AppColors.borderColor,
                        child: Icon(
                          Icons.store_outlined,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 15),
                  title: Text(
                    reviewData.storeName ?? 'Salon',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: location.isEmpty
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
              ),
              CustomPopupMenuButton(
                iconColor: isDarkMode ? AppColors.white : AppColors.black,
                items: [
                  PopupMenuItemData(
                    title: 'Edit',
                    value: '/edit',
                    onTap: onEdit,
                  ),
                  PopupMenuItemData(
                    title: 'Delete',
                    value: '/delete',
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Divider(
              color: isDarkMode
                  ? AppColors.dividerDark
                  : AppColors.disabledColor,
              thickness: 1.5,
              height: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomRatingBar(
              rating: reviewData.rating?.toDouble(),
              ignoreGestures: true,
              onRatingUpdate: (_) {},
            ),
          ),
          if ((reviewData.reviewDescription ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isDarkMode
                    ? AppColors.backgroundDark
                    : AppColors.borderColor,
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.borderDark
                      : AppColors.borderColor,
                ),
              ),
              child: Text(
                reviewData.reviewDescription!,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
