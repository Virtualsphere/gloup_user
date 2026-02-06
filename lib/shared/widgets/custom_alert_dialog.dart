import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String cancelText;
  final String submitText;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.description,
    this.cancelText = 'Cancel',
    this.submitText = 'OK',
    this.onCancel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSizes.heightM,
            
            // Description
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            AppSizes.heightXL,
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onCancel?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                      vertical: AppSizes.paddingM,
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary,
                    ),
                  ),
                ),
                AppSizes.widthM,
                
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSubmit?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingXL,
                      vertical: AppSizes.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: Text(
                    submitText,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    String cancelText = 'Cancel',
    String submitText = 'OK',
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: title,
        description: description,
        cancelText: cancelText,
        submitText: submitText,
        onCancel: onCancel,
        onSubmit: onSubmit,
      ),
    );
  }
}
