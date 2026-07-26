import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class LocationBadge extends StatelessWidget {
  final String location;
  final String? addressLine2;
  final VoidCallback? onTap;

  const LocationBadge({
    super.key,
    required this.location,
    this.addressLine2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor =
        isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              color: foregroundColor,
              size: AppSizes.iconM,
            ),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      location,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: foregroundColor,
                      size: AppSizes.iconS,
                    ),
                  ],
                ),
                if (addressLine2 != null && addressLine2!.isNotEmpty)
                  Text(
                    addressLine2!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: foregroundColor.withValues(alpha: 0.8),
                      fontSize: AppSizes.fontXS,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
