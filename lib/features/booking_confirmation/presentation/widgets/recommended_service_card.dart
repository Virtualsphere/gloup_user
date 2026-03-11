import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class RecommendedServiceCard extends StatelessWidget {
  final String name;
  final String duration;
  final double price;
  final double originalPrice;
  final String? discountPercentage;
  final bool isAdded;
  final VoidCallback onAdd;

  const RecommendedServiceCard({
    super.key,
    required this.name,
    required this.duration,
    required this.price,
    required this.originalPrice,
    this.discountPercentage,
    this.isAdded = false,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate if there's a discount
    final hasDiscount = discountPercentage != null &&
        discountPercentage!.isNotEmpty &&
        discountPercentage != '0%' &&
        discountPercentage != '0';

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppSizes.spaceM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Service name
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.spaceS),

          // Duration with clock icon
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),

          Spacer(),

          // Price and Add button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discounted price (bold)
                    Text(
                      hasDiscount
                          ? '₹${price.toStringAsFixed(0)}'
                          : '₹${originalPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                    ),
                    // Original price (strikethrough if discounted)
                    if (hasDiscount)
                      Text(
                        '₹${originalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
              ),

              // Add/Added button
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isAdded
                        ? AppColors.success
                        : (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    isAdded ? Icons.check : Icons.add,
                    color: isDarkMode
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryDark,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
