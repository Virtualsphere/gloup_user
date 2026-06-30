import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';

class SalonDetailsActionBar extends StatelessWidget {
  final bool isCollapsed;
  final bool isDarkMode;
  final VoidCallback? onShare;

  const SalonDetailsActionBar({
    super.key,
    required this.isCollapsed,
    required this.isDarkMode,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isCollapsed
                    ? Colors.transparent
                    : SalonDetailDesignTokens.heroControlBg,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.all(AppSizes.paddingXS),
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: isCollapsed
                      ? (isDarkMode ? AppColors.white : AppColors.black)
                      : SalonDetailDesignTokens.heroControlIcon,
                  size: AppSizes.iconS,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Row(
              children: [
                if (onShare != null)
                  Container(
                    decoration: BoxDecoration(
                      color: isCollapsed
                          ? Colors.transparent
                          : SalonDetailDesignTokens.heroControlBg,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(AppSizes.paddingXS),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.share,
                        color: isCollapsed
                            ? (isDarkMode ? AppColors.white : AppColors.black)
                            : SalonDetailDesignTokens.heroControlIcon,
                        size: AppSizes.iconS,
                      ),
                      onPressed: onShare,
                    ),
                  ),
                if (onShare != null) SizedBox(width: AppSizes.spaceS),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
