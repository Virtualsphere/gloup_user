import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Horizontally scrollable filter badges with primary filter button
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
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_settings.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              'Filter',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontS,
              ),
            ),
            const SizedBox(width: AppSizes.spaceXS),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
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
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: AppSizes.fontS,
            ),
          ),
        ),
      ),
    );
  }
}
