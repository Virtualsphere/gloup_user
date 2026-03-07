import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final String paymentId;
  final VoidCallback onViewBooking;

  const PaymentSuccessDialog({
    super.key,
    required this.paymentId,
    required this.onViewBooking,
  });

  static Future<void> show(
    BuildContext context, {
    required String paymentId,
    required VoidCallback onViewBooking,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(
        paymentId: paymentId,
        onViewBooking: onViewBooking,
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Celebration animation overlay
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

                // Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
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
                ),

                const SizedBox(height: AppSizes.spaceL),

                // Title
                Text(
                  'Payment Successful!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: AppSizes.spaceS),

                // Subtitle
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '"$paymentId"',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      const TextSpan(text: ' verified successfully'),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSizes.spaceL),

                // Booking confirmed card
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
                        'Booking Confirmed',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spaceXS),
                      Text(
                        'Your appointment is all set',
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

                // View My Booking button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onViewBooking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View My Booking',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceS),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
