import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String? userImage; // Optional profile image URL
  final String timeAgo;
  final double rating;
  final String reviewText;

  const ReviewCard({
    super.key,
    required this.userName,
    this.userImage,
    required this.timeAgo,
    required this.rating,
    required this.reviewText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.textSecondary.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Profile + Name + Time + Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image or initial
              _buildProfileAvatar(),
              const SizedBox(width: AppSizes.paddingM),
              // Name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
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
              // Star rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star
                        : (index < rating ? Icons.star_half : Icons.star_border),
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          AppSizes.heightM,
          // Row 2: Review content
          Text(
            reviewText,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (userImage != null && userImage!.isNotEmpty) {
      // Show profile image
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            userImage!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildInitialAvatar();
            },
          ),
        ),
      );
    } else {
      // Show initial
      return _buildInitialAvatar();
    }
  }

  Widget _buildInitialAvatar() {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
