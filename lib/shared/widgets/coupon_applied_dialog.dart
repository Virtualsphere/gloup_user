import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class CouponAppliedDialog extends StatelessWidget {
  final String couponCode;
  final int discountAmount;
  final VoidCallback onContinue;

  const CouponAppliedDialog({
    super.key,
    required this.couponCode,
    required this.discountAmount,
    required this.onContinue,
  });

  static Future<void> show(
    BuildContext context, {
    required String couponCode,
    required int discountAmount,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CouponAppliedDialog(
        couponCode: couponCode,
        discountAmount: discountAmount,
        onContinue: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lottie celebration animation overlay
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/celebration_anim.json',
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSizes.spaceXL),

                // Check icon with layered circles
                _buildCheckIcon(),

                const SizedBox(height: AppSizes.spaceL),

                // Title
                Text(
                  'Coupon Applied',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: AppSizes.spaceS),

                // Coupon code with success message
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '"$couponCode"',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      const TextSpan(text: ' applied successfully'),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spaceL),

                // Savings card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₹$discountAmount',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spaceXS),
                      Text(
                        'Saved on this booking',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceL),

                // Tap to continue hint
                Text(
                  'Tap to continue',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: AppSizes.spaceS),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCheckIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle with opacity
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
        // Inner circle solid
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.white,
            size: 32,
          ),
        ),
      ],
    );
  }
}
