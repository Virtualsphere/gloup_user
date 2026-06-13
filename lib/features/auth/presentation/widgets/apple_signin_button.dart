import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const AppleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Apple',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
          side: BorderSide(
            color: isDisabled
                ? (isDarkMode ? AppColors.borderDark : AppColors.border)
                : (isDarkMode ? AppColors.borderDark : AppColors.border),
            width: 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingL,
            vertical: AppSizes.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          backgroundColor:
              isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.icApple,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceM),
                  Flexible(
                    child: Text(
                      text,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
