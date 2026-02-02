import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Country Code Selector Widget
/// Shows flag and country code with rounded border on left side
class CountryCodeSelector extends StatelessWidget {
  final Function(CountryCode) onChanged;
  final String initialSelection;

  const CountryCodeSelector({
    super.key,
    required this.onChanged,
    this.initialSelection = 'IN',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        border: Border.all(
          color: isDarkMode 
            ? AppColors.borderDark 
            : AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingXS,
      ),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: initialSelection,
        favorite: const ['+91', 'IN'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        padding: EdgeInsets.zero,
        textStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.colorScheme.onSurface,
        ),
        dialogTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        dialogBackgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        searchDecoration: InputDecoration(
          labelText: 'Search Country',
          hintText: 'Search by name or code',
          labelStyle: context.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          filled: true,
          fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
            ),
          ),
        ),
        dialogSize: Size(
          context.screenWidth * 0.9,
          context.screenHeight * 0.7,
        ),
        barrierColor: isDarkMode 
          ? AppColors.black.withValues(alpha: 0.5) 
          : AppColors.black.withValues(alpha: 0.3),
        dialogItemPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        searchPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
      ),
    );
  }
}
