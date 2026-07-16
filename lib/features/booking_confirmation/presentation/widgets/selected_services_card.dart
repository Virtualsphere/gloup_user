import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SelectedServicesCard extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  const SelectedServicesCard({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.marginM,
      ),
      padding: EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          // Service items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              child: Divider(
                color: (isDarkMode ? AppColors.borderDark : AppColors.border)
                    .withValues(alpha: 0.3),
                height: 1,
              ),
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceItem(context, service, isDarkMode);
            },
          ),
          // Divider before "Add more service"
          Padding(
            padding: EdgeInsets.only(
                top: AppSizes.paddingM, bottom: AppSizes.paddingM),
            child: Divider(
              color: (isDarkMode ? AppColors.borderDark : AppColors.border)
                  .withValues(alpha: 0.3),
              height: 1,
            ),
          ),
          // "Forget Something? Add more service" option
          _buildAddMoreService(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    Map<String, dynamic> service,
    bool isDarkMode,
  ) {
    // print('service: $service');
    final name = service['name'] as String? ?? 'N/A';
    final duration = service['duration'] as String? ?? 'N/A';
    final originalPrice = service['originalPrice'] as double? ?? 0.0;
    final price = service['price'] as double? ?? 0.0;
    final discountPercentage = service['discountPercentage'] as String? ?? '';
    final isPopular = service['isPopular'] as bool? ?? false;

    // Calculate discounted price if discount exists
    final hasDiscount = discountPercentage.isNotEmpty &&
        discountPercentage != '0%' &&
        discountPercentage != '0';

    // double? discountedPrice;
    // if (hasDiscount) {
    //   final discountValue = int.tryParse(
    //     discountPercentage.replaceAll('%', '').trim(),
    //   ) ?? 0;
    //   discountedPrice = price - (price * discountValue / 100);
    // }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Service info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service name with popular badge
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontM,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isPopular) ...[
                    SizedBox(width: AppSizes.spaceS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        'Popular',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: AppSizes.spaceS),
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
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSizes.fontS,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: AppSizes.spaceM),
        // Right side - Price info
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Price (original and discounted in same line if discounted)
            if (hasDiscount)
              Row(
                children: [
                  Text(
                    '₹${originalPrice.toStringAsFixed(0)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: AppSizes.fontS,
                      decoration: TextDecoration.lineThrough,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontM,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              )
            else
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontM,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            if (hasDiscount) ...[
              SizedBox(height: AppSizes.spaceS),
              // Discount badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 10,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$discountPercentage Off',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAddMoreService(BuildContext context, bool isDarkMode) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Forget Something? ',
            style: context.textTheme.bodyMedium?.copyWith(
              fontSize: AppSizes.fontM,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate back to salon details to add more services
              Navigator.of(context).pop();
            },
            child: Text(
              'Add more service',
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: AppSizes.fontM,
                color: context.onSurfaceEmphasis,
                decoration: TextDecoration.underline,
                decorationColor: context.onSurfaceEmphasis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
