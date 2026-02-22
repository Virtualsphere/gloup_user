import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';

class CustomSafeArea extends StatelessWidget {
  const CustomSafeArea({
    super.key,
    required this.child,
    this.backGroundColor= AppColors.background,
  });

  final Widget child;
  final Color backGroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backGroundColor,
      child: SafeArea(
        child: child,
      ),
    );
  }
}
