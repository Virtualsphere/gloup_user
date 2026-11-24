import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

enum LocationRequiredDialogType {
  serviceDisabled,
  permissionDeniedForever,
}

class LocationRequiredDialog extends StatelessWidget {
  final LocationRequiredDialogType type;
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;

  const LocationRequiredDialog({
    super.key,
    required this.type,
    required this.onOpenSettings,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required LocationRequiredDialogType type,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationRequiredDialog(
        type: type,
        onOpenSettings: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final isService = type == LocationRequiredDialogType.serviceDisabled;
    final title = isService
        ? 'Device Location Disabled'
        : 'Location Permission Required';
    final message = isService
        ? 'Device location must be enabled before allowing a booking. Please turn on location in your settings to proceed with an accurate booking.'
        : 'Location permission is permanently denied for Gloup. Please enable location access in App Settings to proceed with your booking.';
    final buttonText =
        isService ? 'Open Location Settings' : 'Open App Settings';
    final iconData =
        isService ? Icons.location_off_rounded : Icons.location_disabled_rounded;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      backgroundColor:
          isDarkMode ? AppColors.surfaceDark : AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSizes.spaceS),

            // Icon section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (isDarkMode
                            ? AppColors.primaryDarkTheme
                            : AppColors.primary)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primaryDarkTheme
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: isDarkMode ? AppColors.black : AppColors.white,
                    size: 30,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSizes.spaceL),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizes.spaceS),

            // Body message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSizes.spaceL),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOpenSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppColors.primaryDarkTheme
                      : AppColors.primary,
                  foregroundColor:
                      isDarkMode ? AppColors.black : AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.black : AppColors.white,
                      ),
                ),
              ),
            ),

            SizedBox(height: AppSizes.spaceXS),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                ),
              ),
            ),

            SizedBox(height: AppSizes.spaceXS),
          ],
        ),
      ),
    ),
  );
  }
}
