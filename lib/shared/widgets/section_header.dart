import 'package:flutter/material.dart';
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
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ??
        EdgeInsets.only(
          left: AppSizes.paddingM,
          right: AppSizes.paddingXS,
          top: AppSizes.paddingS,
          bottom: AppSizes.paddingS,
        );
    return Padding(
      padding: resolvedPadding,
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
                    color: context.onSurfaceEmphasis,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: AppSizes.spaceXS),
                  Text(
                    subtitle!,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.mutedOnSurface,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // See All button (if callback provided)
          if (onSeeAllTap != null) ...[
            SizedBox(width: AppSizes.spaceM),
            InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seeAllText!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.onSurfaceEmphasis,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontM,
                      ),
                    ),
                    SizedBox(width: AppSizes.spaceXS),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.onSurfaceEmphasis,
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
