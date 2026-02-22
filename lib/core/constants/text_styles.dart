import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';

class HeaderTextBlack extends StatelessWidget {
  const HeaderTextBlack({
    super.key,
    required this.title,
    required this.fontSize,
    this.isBodoniModa = false,
    this.fontWeight = FontWeight.w500,
    this.textDecoration = TextDecoration.none,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign,
  });

  final String title;
  final double fontSize;
  final bool isBodoniModa;
  final FontWeight fontWeight;
  final TextDecoration textDecoration;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style:
      // isBodoniModa
      //     ? GoogleFonts.bodoniModa(
      //         fontSize: fontSize,
      //         fontWeight: fontWeight,
      //         color: AppColors.primary,
      //       )
      //     :
      GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: AppColors.primary,
              decoration: textDecoration,
            ),
    );
  }
}

class BodyTextHint extends StatelessWidget {
  const BodyTextHint(
      {super.key,
      required this.title,
      required this.fontSize,
      this.fontWeight = FontWeight.w400,
      this.isSecondary = false,
      this.overflow = TextOverflow.visible,
      this.textAlign = TextAlign.start});

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isSecondary;
  final TextOverflow overflow;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: overflow,
      textAlign: textAlign,
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: isSecondary ? AppColors.secondary : AppColors.textSecondaryDark,
      ),
    );
  }
}

class BodyTextColors extends StatelessWidget {
  const BodyTextColors({
    super.key,
    required this.title,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    required this.color,
    this.isBodoniModa = false,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.visible,
  });

  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final bool isBodoniModa;
  final TextAlign textAlign;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      overflow: overflow,
      style:
      // isBodoniModa
      //     ? GoogleFonts.bodoniModa(
      //         fontSize: fontSize,
      //         fontWeight: fontWeight,
      //         color: color,
      //       )
      //     :
      GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
    );
  }
}

class AppTextStyle {
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color? decorationColor;
  final TextDecoration? decoration;
  final double? height;

  AppTextStyle({
    required this.fontSize,
    required this.fontWeight,
    this.decoration,
    this.decorationColor,
    required this.color,
    this.height,
  });

  TextStyle get textStyle => GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: fontWeight,
        decoration: decoration,
        height: height,
        decorationColor: decorationColor,
        color: color,
      );
}
