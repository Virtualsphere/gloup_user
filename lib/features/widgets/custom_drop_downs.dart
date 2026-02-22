import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/core/constants/themes.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';

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
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2(
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          // const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
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
                AppColors.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          // Add more decoration..
        ),
        barrierColor: Colors.transparent,
        iconStyleData: IconStyleData(
          icon: SvgPicture.asset(
            AppIcons.dropDownArrow,
            height: 12,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          padding: EdgeInsets.zero,
          maxHeight: maxHeight != null ? 150 : null,
          decoration: Themes.dropDownBoxDecoration(),
        ),
        menuItemStyleData:
        MenuItemStyleData(padding: EdgeInsets.only(left: 15)),
        hint: Text(
          hintText,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ).textStyle,
        ),
        value: dropdownValue,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: AppTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primary,
              ).textStyle,
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return items.map((String value) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ).textStyle,
              ),
            );
          }).toList();
        },
        validator: validator,
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(10),
        border: Border.all(
          color: AppColors.textDisabled,
        ),
      ),
      child: CountryCodePicker(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        onChanged: onChanged,
        initialSelection: 'IN',
        favorite: ['+91', 'IN'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: true,
        flagWidth: 26,
        searchPadding: EdgeInsets.symmetric(horizontal: 15),
        dialogBackgroundColor: AppColors.background,
        boxDecoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadiusDirectional.circular(10),
          border: Border.all(color: AppColors.textDisabled),
        ),
        searchDecoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.textDisabled,
              width: 1,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SvgPicture.asset(
              AppIcons.search,
              height: 24,
              width: 24,
            ),
          ),
          enabledBorder: DecoratedInputBorder(
            child: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.textDisabled,
                width: 1,
              ),
            ),
            shadow: BoxShadow(
              color: AppColors.primary.withValues(alpha: .06),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ),
        ),
        headerTextStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        dialogTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
        searchStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
