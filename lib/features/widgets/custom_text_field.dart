import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.icon,
    this.inputType,
    this.inputAction,
    this.maxLines,
    this.validator,
    this.prefixWidget,
    this.onTap,
    this.suffixOnTap,
    this.isReadOnly = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLength,
    this.onChanged,
    this.inputFormatter,
    this.focusNode,
    this.iconHeight = 24,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? icon;
  final TextInputType? inputType;
  final TextInputAction? inputAction;
  final int? maxLines;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatter;
  final Widget? prefixWidget;
  final TextCapitalization textCapitalization;

  final VoidCallback? onTap, suffixOnTap;
  final bool isReadOnly, obscureText;
  final int? maxLength;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: inputAction,
      maxLines: maxLines,
      keyboardType: inputType,
      cursorColor: AppColors.primary,
      onTap: onTap,
      readOnly: isReadOnly,
      maxLength: maxLength,
      onChanged: onChanged,
      inputFormatters: inputFormatter,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: AppTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: context.colorScheme.onSurface,
      ).textStyle,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        prefixIcon: prefixWidget == null
            ? null
            : Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: prefixWidget,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: AppTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryColor,
        ).textStyle,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: icon != null
              ? GestureDetector(
            onTap: suffixOnTap,
            child: SvgPicture.asset(
              icon!,
              height: iconHeight,
              width: iconHeight,
              colorFilter: ColorFilter.mode(
                AppColors.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
          )
              : null,
        ),
      ),
      validator: validator,
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 4) text = text.substring(0, 4);
    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class DecoratedInputBorder extends InputBorder {
  DecoratedInputBorder({
    required this.child,
    required this.shadow,
  }) : super(borderSide: child.borderSide);

  final InputBorder child;

  final BoxShadow shadow;

  @override
  bool get isOutline => child.isOutline;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      child.getInnerPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      child.getOuterPath(rect, textDirection: textDirection);

  @override
  EdgeInsetsGeometry get dimensions => child.dimensions;

  @override
  InputBorder copyWith(
      {BorderSide? borderSide,
        InputBorder? child,
        BoxShadow? shadow,
        bool? isOutline}) {
    return DecoratedInputBorder(
      child: (child ?? this.child).copyWith(borderSide: borderSide),
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ShapeBorder scale(double t) {
    final scalledChild = child.scale(t);
    return DecoratedInputBorder(
      child: scalledChild is InputBorder ? scalledChild : child,
      shadow: BoxShadow.lerp(null, shadow, t)!,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart,
        double gapExtent = 0.0,
        double gapPercentage = 0.0,
        TextDirection? textDirection}) {
    final clipPath = Path()
      ..addRect(const Rect.fromLTWH(-5000, -5000, 10000, 10000))
      ..addPath(getInnerPath(rect), Offset.zero)
      ..fillType = PathFillType.evenOdd;
    canvas.clipPath(clipPath);

    final Paint paint = shadow.toPaint();
    final Rect bounds = rect.shift(shadow.offset).inflate(shadow.spreadRadius);

    canvas.drawPath(getOuterPath(bounds), paint);

    child.paint(canvas, rect,
        gapStart: gapStart,
        gapExtent: gapExtent,
        gapPercentage: gapPercentage,
        textDirection: textDirection);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is DecoratedInputBorder &&
        other.borderSide == borderSide &&
        other.child == child;
  }

  @override
  int get hashCode => Object.hash(borderSide, child, shadow);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'DecoratedInputBorder')}($borderSide, $shadow, $child)';
  }
}
