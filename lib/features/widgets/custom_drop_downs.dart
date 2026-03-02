import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CustomDropDownField extends StatelessWidget {
  const CustomDropDownField({
    super.key,
    required this.dropdownValue,
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.icon = '',
    this.validator,
    this.maxHeight,
    this.color = AppColors.primary,
  });

  final String? dropdownValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final String icon;
  final FormFieldValidator<String>? validator;
  final int? maxHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2(
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          fillColor: isDarkMode ? AppColors.black : AppColors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: isDarkMode
                  ? AppColors.transparent
                  : AppColors.border,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: isDarkMode
                  ? AppColors.transparent
                  : AppColors.border,
              width: 1,
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: icon.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(
                    icon,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      theme.iconTheme.color ?? Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        ),
        barrierColor: Colors.transparent,
        iconStyleData: IconStyleData(
          icon: SvgPicture.asset(
            AppIcons.dropDownArrow,
            height: 12,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.white : AppColors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          padding: EdgeInsets.zero,
          maxHeight: maxHeight != null ? 150 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        hint: Text(
          hintText,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black,
            fontSize: 14,
          ),
        ),
        value: dropdownValue,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: context.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? AppColors.white : AppColors.black,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomCountryPicker extends StatelessWidget {
  const CustomCountryPicker({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(10),
        color: isDarkMode ? AppColors.black : AppColors.white,
        border: Border.all(
          color: isDarkMode ? AppColors.transparent : AppColors.border,
          width: 1,
        ),
      ),
      child: CountryCodePicker(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        onChanged: onChanged,
        initialSelection: 'IN',
        favorite: const ['+91', 'IN'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: true,
        flagWidth: 26,
        dialogBackgroundColor:
            isDarkMode ? Colors.grey.shade900 : AppColors.white,
        boxDecoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        searchPadding: const EdgeInsets.symmetric(horizontal: 15),
        searchDecoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? AppColors.black : Colors.grey.shade100,
          hintText: "Search country",
          hintStyle: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.search,
              color: isDarkMode ? AppColors.white : AppColors.greyColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        headerTextStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        dialogTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        searchStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}
