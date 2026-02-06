import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';

/// Custom Toast Widget
/// Shows custom styled toast messages at the bottom of the screen
class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = true,
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    // Determine colors based on message type
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppColors.error;
      textColor = AppColors.white;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = AppColors.success;
      textColor = AppColors.white;
      icon = Icons.check_circle_outline;
    } else {
      backgroundColor = AppColors.primary;
      textColor = AppColors.onPrimary;
      icon = Icons.info_outline;
    }

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  /// Show a success toast
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, isSuccess: true, isError: false);
  }

  /// Show an error toast
  static void showError(BuildContext context, String message) {
    show(context, message: message, isError: true, isSuccess: false);
  }

  /// Show an info toast
  static void showInfo(BuildContext context, String message) {
    show(context, message: message, isError: false, isSuccess: false);
  }
  
  /// Show a warning toast
  static void showWarning(BuildContext context, String message) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.0),
        color: AppColors.warning,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
