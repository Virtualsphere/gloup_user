import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

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
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingM,
      vertical: AppSizes.paddingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title and subtitle section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontXL,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
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
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceXS),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
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
