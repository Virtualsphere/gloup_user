import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/extensions/context_extensions.dart';

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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ic_search.svg',
              width: AppSizes.iconM,
              height: AppSizes.iconM,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Text(
                'Search for salons, parlors, or massages...',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ),
            InkWell(
              onTap: onSettingsTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              child: Container(
                decoration: BoxDecoration(
                    color: context.theme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS)),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset(
                  AppIcons.icSettings,
                  width: AppSizes.iconM,
                  height: AppSizes.iconM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
