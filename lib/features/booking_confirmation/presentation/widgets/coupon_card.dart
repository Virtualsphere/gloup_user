import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class CouponCard extends StatelessWidget {
  final int discountAmount;
  final String couponCode;
  final String discountType; // 'flat' | 'percentage'
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEnabled;
  final String? disabledReason;

  const CouponCard({
    super.key,
    required this.discountAmount,
    required this.couponCode,
    this.discountType = 'flat',
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color surface =
        isDarkMode ? AppColors.surfaceDark : AppColors.surface;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isEnabled ? surface : surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: isEnabled
              ? null
              : Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? AppColors.success.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: isEnabled ? AppColors.success : Colors.grey,
                    size: 22,
                  ),
                ),
                SizedBox(width: AppSizes.spaceM),

                // Middle text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Save ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isEnabled
                                    ? (isDarkMode
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary)
                                    : Colors.grey,
                              ),
                          children: [
                            TextSpan(
                              text: discountType == 'percentage'
                                  ? '$discountAmount%'
                                  : '₹$discountAmount',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: ' with'),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.spaceXS),
                      Text(
                        '"$couponCode"',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:
                                  isEnabled ? AppColors.success : Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),

                // Right button / toggle
                _ApplyToggle(
                  isSelected: isSelected,
                  isEnabled: isEnabled,
                  onTap: onTap,
                ),
              ],
            ),
            // Show disabled reason if provided
            if (!isEnabled && disabledReason != null) ...[
              SizedBox(height: AppSizes.spaceS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: AppSizes.spaceXS),
                    Expanded(
                      child: Text(
                        disabledReason!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 11,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplyToggle extends StatelessWidget {
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ApplyToggle({
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isSelected
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.success)
              : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && isEnabled) ...[
              const Icon(
                Icons.check,
                size: 16,
                color: AppColors.success,
              ),
              SizedBox(width: AppSizes.spaceXS),
            ],
            Text(
              isSelected ? 'Applied' : 'Apply',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isEnabled
                        ? (isSelected ? AppColors.success : AppColors.white)
                        : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
