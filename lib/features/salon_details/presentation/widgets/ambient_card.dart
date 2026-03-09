import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class AmbientCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const AmbientCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.textSecondary.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            size: 28,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          AppSizes.heightXS,
          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
