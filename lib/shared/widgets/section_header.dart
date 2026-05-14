import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAllTap;
  final String? seeAllText;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAllTap,
    this.seeAllText = 'See All',
    this.padding = const EdgeInsets.only(
      left: AppSizes.paddingM,
      right: AppSizes.paddingXS,
      top: AppSizes.paddingS,
      bottom: AppSizes.paddingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Padding(
      padding: padding!,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title and subtitle section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontXL,
                    color:
                        isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    subtitle!,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // See All button (if callback provided)
          if (onSeeAllTap != null) ...[
            const SizedBox(width: AppSizes.spaceM),
            InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seeAllText!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
