import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;
  final bool showBorder;
  final EdgeInsetsGeometry? padding;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.onSettingsTap,
    this.showBorder = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: showBorder ? Border.all(
            color: isDarkMode
                ? AppColors.borderDark
                : AppColors.border,
            width: 1 ,
          ) : Border.all(
            color: Colors.transparent,
            width: 0,
          )
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ic_search.svg',
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                'Search for salons, parlors, or massages...',
                style: context.textTheme.bodySmall?.copyWith(
                  color:
                      isDarkMode ? AppColors.textHintDark : AppColors.textHint,
                ),
              ),
            ),
            InkWell(
              onTap: onSettingsTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              child: Container(
                decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primaryDark.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS)),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  AppIcons.icSettings,
                  width: AppSizes.iconS,
                  height: AppSizes.iconS,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            // ThemeToggleButton(),
          ],
        ),
      ),
    );
  }
}
