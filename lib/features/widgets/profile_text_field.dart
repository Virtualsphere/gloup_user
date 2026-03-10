import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.inputType,
    this.inputAction,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.isReadOnly = false,
    this.showClear = false,
    this.showChange = false,
    this.onClearTap,
    this.onChangeTap,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final int maxLines;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool isReadOnly;
  final int? maxLength;
  final bool showClear;
  final bool showChange;
  final VoidCallback? onClearTap;
  final VoidCallback? onChangeTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      height: 55.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller!,
        builder: (context, value, child) {
          final isEmpty = value.text.isEmpty;

          return TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            maxLength: maxLength,
            onTap: onTap,
            onChanged: onChanged,
            focusNode: focusNode,
            keyboardType: inputType,
            textInputAction: inputAction,
            maxLines: maxLines,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            decoration: InputDecoration(
              counterText: '',
              // labelText: labelText,
              hintText: hintText,
              filled: true,
              fillColor:
                  isDarkMode ? AppColors.backgroundDark : AppColors.background,
              hintStyle: context.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              labelStyle: context.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.transparent,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDarkMode ? AppColors.transparent : AppColors.border,
                  width: 1,
                ),
              ),
              suffixIcon: isEmpty
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showClear)
                          GestureDetector(
                            onTap: onClearTap ??
                                () {
                                  controller?.clear();
                                },
                            child: Padding(
                              padding: EdgeInsets.only(right: 5.0, left: 15.0),
                              child: Icon(
                                Icons.clear,
                                size: 18,
                                color: isDarkMode
                                    ? AppColors.white
                                    : AppColors.greyColor,
                              ),
                            ),
                          ),
                        if (showChange)
                          GestureDetector(
                            onTap: onChangeTap,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10.0, left: 15.0),
                              child: Text(
                                "CHANGE",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            validator: validator,
          );
        },
      ),
    );
  }
}
