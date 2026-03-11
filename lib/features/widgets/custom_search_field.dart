import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/features/widgets/custom_text_field.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.inputType,
    this.inputAction,
    this.isReadOnly = false,
    this.onTap,
    this.suffixOnTap,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final VoidCallback? suffixOnTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          cursorColor: AppColors.primary,
          keyboardType: inputType,
          textInputAction: inputAction,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onChanged,
          readOnly: isReadOnly,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            focusedBorder: DecoratedInputBorder(
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
              ),
            ),
            border: InputBorder.none,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: value.text.isNotEmpty
                  ? IconButton(
                      icon: SvgPicture.asset(
                        AppIcons.cancel,
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          AppColors.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        controller.clear();
                        if (suffixOnTap != null) {
                          suffixOnTap!();
                        }
                        if (onChanged != null) onChanged!('');
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        AppIcons.search,
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          AppColors.secondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
