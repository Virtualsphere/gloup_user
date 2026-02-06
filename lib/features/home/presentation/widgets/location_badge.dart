import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/extensions/context_extensions.dart';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
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
            const Icon(
              Icons.location_on,
              color: AppColors.textLight,
              size: AppSizes.iconM,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  location,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                if (addressLine2 != null && addressLine2!.isNotEmpty)
                  Text(
                    addressLine2!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.8),
                      fontSize: AppSizes.fontXS,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textLight,
              size: AppSizes.iconS,
            ),
          ],
        ),
      ),
    );
  }
}
