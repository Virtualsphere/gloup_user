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
    if (widget.initialGender != null && widget.initialGender!.isNotEmpty) {
      final filter = _filters.firstWhere(
        (f) => f['value'] == widget.initialGender,
        orElse: () => {'label': '', 'value': ''},
      );
      if (filter['label']!.isNotEmpty) {
        _selectedFilter = filter['label'];
      }
    } else {
      _selectedFilter = 'All';
    }
  }

  TextStyle _labelStyle({
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontSize: AppSizes.fontS,
      height: 1.2,
    );
  }

  /// Shared pill used by Gender and every filter chip so sizing/styling match.
  Widget _buildPill({
    required BuildContext context,
    required String label,
    VoidCallback? onTap,
    required bool filled,
    Widget? leading,
  }) {
    final fill = filled ? context.primaryFill : context.appSurface;
    final labelColor = filled ? context.onPrimaryFill : context.mutedOnSurface;
    final borderColor = filled
        ? context.primaryFill
        : (context.isDarkMode ? AppColors.borderDark : AppColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingXS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading,
                SizedBox(width: AppSizes.spaceXS),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _labelStyle(color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onFill = context.onPrimaryFill;

    return Container(
      color: context.appSurface,
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          itemCount: _filters.length + 1,
          separatorBuilder: (_, __) => SizedBox(width: AppSizes.spaceS),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildPill(
                context: context,
                label: 'Gender',
                filled: true,
                onTap: () {},
                leading: SvgPicture.asset(
                  AppIcons.icSettings,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(onFill, BlendMode.srcIn),
                ),
              );
            }

            final filter = _filters[index - 1];
            final label = filter['label']!;
            final value = filter['value']!;
            final isSelected = _selectedFilter == label;

            return _buildPill(
              context: context,
              label: label,
              filled: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = isSelected ? null : label;
                });
                widget.onGenderSelected?.call(isSelected ? 'unisex' : value);
              },
            );
          },
        ),
      ),
    );
  }
}
