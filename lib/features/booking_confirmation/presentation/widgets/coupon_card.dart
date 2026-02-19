import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class CouponCard extends StatelessWidget {
  final int discountAmount;
  final String couponCode;
  final bool isSelected;
  final VoidCallback onTap;

  const CouponCard({
    super.key,
    required this.discountAmount,
    required this.couponCode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color surface = isDarkMode ? AppColors.surfaceDark : AppColors.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                Icons.local_offer_outlined,
                color: AppColors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),

            // Middle text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Save ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                      children: [
                        TextSpan(
                          text: '₹$discountAmount',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' with'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    '"$couponCode"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ),

            // Right button / toggle
            _ApplyToggle(
              isSelected: isSelected,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyToggle extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _ApplyToggle({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.success,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSizes.spaceXS),
            ],
            Text(
              isSelected ? 'Applied' : 'Apply',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? AppColors.success : AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
