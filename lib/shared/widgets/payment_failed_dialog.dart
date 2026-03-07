import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;

  const PaymentFailedDialog({
    super.key,
    required this.message,
    required this.onRetry,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaymentFailedDialog(
        message: message,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Padding(
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
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spaceL),

              // Title
              Text(
                'Payment Failed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: AppSizes.spaceS),

              // Error message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.spaceL),

              // Error info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Text(
                      'Don\'t worry!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spaceXS),
                    Text(
                      'No amount has been deducted from your account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spaceL),

              // Try Again button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Try Again',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.spaceS),

              // Tap to dismiss hint
              Text(
                'Tap anywhere to dismiss',
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
      ),
    );
  }
}
