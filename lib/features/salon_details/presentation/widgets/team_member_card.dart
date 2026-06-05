import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Round profile image
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode
                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                  : AppColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: 70,
              height: 70,
              memCacheWidth: 140,
              memCacheHeight: 140,
              errorWidget: (context, url, error) {
                return Container(
                  color: isDarkMode
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        AppSizes.heightS,
        // Name
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color:
                isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        // Role
        Text(
          role,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
