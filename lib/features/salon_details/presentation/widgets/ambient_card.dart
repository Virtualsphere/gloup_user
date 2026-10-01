import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class AmbientCard extends StatelessWidget {
  final String icon;
  final String label;

  const AmbientCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    // Resolve full URL
    final String fullIconUrl = icon.startsWith('http') 
        ? icon 
        : ApiRoutes.getImageUrl(icon);
        
    final bool isSvg = icon.toLowerCase().endsWith('.svg');

    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(
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
          SizedBox(
            width: 28,
            height: 28,
            child: isSvg 
                ? SvgPicture.network(
                    fullIconUrl,
                    colorFilter: ColorFilter.mode(
                      isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (BuildContext context) => Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: fullIconUrl,
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    placeholder: (context, url) => Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.check_circle,
                      size: 28,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
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
