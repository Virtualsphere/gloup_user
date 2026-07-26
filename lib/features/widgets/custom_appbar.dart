import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.title,
    this.isBackButton = true,
    this.isClearButton = false,
    this.isBackButtonDecoration = false,
    this.actionWidget,
    this.actionBarHeight = 90,
  });

  final String title;
  final bool isBackButton, isClearButton, isBackButtonDecoration;
  final Widget? actionWidget;
  final double actionBarHeight;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor =
        isDarkMode ? AppColors.primaryDarkTheme : AppColors.primary;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      centerTitle: true,
      elevation: 0,
      leading: isBackButton
          ? Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 10.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  height: 35,
                  width: 37,
                  decoration: isBackButtonDecoration
                      ? BoxDecoration(
                          color: isDarkMode
                              ? AppColors.surfaceDark
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        )
                      : const BoxDecoration(),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcons.arrowBack,
                      colorFilter: ColorFilter.mode(
                        foregroundColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: BodyTextColors(
        title: title,
        fontSize: 20,
        color: foregroundColor,
        isBodoniModa: false,
      ),
      actions: actionWidget != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: actionWidget!,
              )
            ]
          : null,
    );
  }
}
