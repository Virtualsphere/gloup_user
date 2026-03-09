import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class FilterBadges extends StatefulWidget {
  final Function(String gender)? onGenderSelected;
  final String? initialGender;
  
  const FilterBadges({
    super.key,
    this.onGenderSelected,
    this.initialGender,
  });

  @override
  State<FilterBadges> createState() => _FilterBadgesState();
}

class _FilterBadgesState extends State<FilterBadges> {
  String? _selectedFilter;

  final List<Map<String, String>> _filters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Men', 'value': 'male'},
    {'label': 'Women', 'value': 'female'},
    {'label': 'Unisex', 'value': 'unisex'},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial gender if provided (only if not null)
    if (widget.initialGender != null && widget.initialGender!.isNotEmpty) {
      final filter = _filters.firstWhere(
        (f) => f['value'] == widget.initialGender,
        orElse: () => {'label': '', 'value': ''},
      );
      if (filter['label']!.isNotEmpty) {
        _selectedFilter = filter['label'];
      }
    } else {
      // Default selection is "All"
      _selectedFilter = 'All';
    }
  }

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
          ..._filters.map((filter) => _buildFilterChip(
                context,
                filter['label']!,
                filter['value']!,
              )),
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
              'Price',
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

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final bool isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spaceS),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = isSelected ? null : label;
          });
          // Notify parent about gender selection
          if (widget.onGenderSelected != null) {
            widget.onGenderSelected!(isSelected ? 'unisex' : value);
          }
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? AppColors.primaryDark :  AppColors.primary)
                : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            border: Border.all(
              color: isSelected ? (isDarkMode ? AppColors.primaryDark:  AppColors.primary) :(isDarkMode ? AppColors.borderDark:  AppColors.border),
              width:  1.0,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSelected ? (isDarkMode ? AppColors.primary :  AppColors.primaryDark) : (isDarkMode ? AppColors.textSecondaryDark:  AppColors.textSecondary) ,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: AppSizes.fontS,
            ),
          ),
        ),
      ),
    );
  }
}
