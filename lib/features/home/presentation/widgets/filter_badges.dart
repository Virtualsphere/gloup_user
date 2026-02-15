import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/extensions/context_extensions.dart';

class FilterBadges extends StatefulWidget {
  const FilterBadges({super.key});

  @override
  State<FilterBadges> createState() => _FilterBadgesState();
}

class _FilterBadgesState extends State<FilterBadges> {
  String? _selectedFilter;

  final List<String> _filters = ['Men', 'Women', 'Unisex', 'Kids', 'Senior'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        children: [
          // Primary Filter Button (Settings + Filter + Arrow)
          _buildPrimaryFilterButton(context),
          const SizedBox(width: AppSizes.spaceS),
          // Filter chips
          ..._filters.map((filter) => _buildFilterChip(context, filter)),
        ],
      ),
    );
  }

  Widget _buildPrimaryFilterButton(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        // Show filter bottom sheet or dialog
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? AppColors.primaryDark.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppIcons.icSettings,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDarkMode ? AppColors.primary : AppColors.primaryDark,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              'Filter',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.primary : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontS,
              ),
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDarkMode ? AppColors.primary : AppColors.primaryDark,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final bool isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spaceS),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = isSelected ? null : label;
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? AppColors.primaryDark.withValues(alpha: 0.1) :  AppColors.primary.withValues(alpha: 0.1))
                : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            border: Border.all(
              color: isSelected ? (isDarkMode ? AppColors.primaryDark:  AppColors.primary) :(isDarkMode ? AppColors.borderDark:  AppColors.border),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSelected ? (isDarkMode ? AppColors.primaryDark:  AppColors.primary) : (isDarkMode ? AppColors.primaryDark:  AppColors.primary) ,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: AppSizes.fontS,
            ),
          ),
        ),
      ),
    );
  }
}
