import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';

class Themes {
  static var authBoxDecoration = BoxDecoration(
    color: AppColors.scaffoldBackground,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(25),
      topLeft: Radius.circular(25),
    ),
    boxShadow: [
      BoxShadow(
        blurRadius: 60,
        spreadRadius: 0,
        color: AppColors.primary.withValues(alpha: .15),
      )
    ],
  );

  static dropDownBoxDecoration({double radius = 15}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: AppColors.white,
      boxShadow: [
        BoxShadow(
          color: AppColors.border,
          blurRadius: 30,
          spreadRadius: 0,
          offset: Offset(0, 0),
        )
      ],
    );
  }

  static BoxDecoration borderDecoration({double radius = 15}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.borderColor,
      ),
    );
  }

  static var saloonBoxDecoration = BoxDecoration(
    color: AppColors.scaffoldBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AppColors.borderDark,
      width: 0.5,
    ),
  );

  static BoxDecoration bottomSheetDecoration = BoxDecoration(
    color: AppColors.scaffoldBackground,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(20),
      topLeft: Radius.circular(20),
    ),
  );
  static var primaryBoxDecorationPurple = BoxDecoration(
    color: AppColors.scaffoldBackground,
    border: Border.all(
      color: AppColors.scaffoldBackground,
      width: 1,
    ),
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(20),
      topLeft: Radius.circular(20),
    ),
  );

  static var primaryCircleDecoration = BoxDecoration(
    color: AppColors.primaryLight,
    shape: BoxShape.circle,
  );
  static var containerDecoration = BoxDecoration(
    color: AppColors.scaffoldBackground,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: .05),
        blurRadius: 20,
        spreadRadius: 1,
      )
    ],
  );
}
