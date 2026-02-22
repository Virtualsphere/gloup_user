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
    this.actionBarHeight = 120,
  });

  final String title;
  final bool isBackButton, isClearButton, isBackButtonDecoration;
  final Widget? actionWidget;
  final double actionBarHeight;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: actionWidget != null ? 140 : actionBarHeight,
      width: size.width,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isBackButton)
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Container(
                    height: 35,
                    width: 37,
                    decoration: isBackButtonDecoration
                        ? BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        )
                      ],
                    )
                        : BoxDecoration(color: AppColors.surfaceDark),
                    child: Align(
                      alignment: isBackButtonDecoration
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: SvgPicture.asset(
                        AppIcons.arrowBack,
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isClearButton)
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Container(
                    height: 22,
                    width: 22,
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      AppIcons.cancel,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (isBackButton)
            SizedBox(
                height:
                title.length > 20 ? 10 : (actionWidget != null ? 10 : 20))
          else
            SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTextColors(
                title: title,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                isBodoniModa: false,
              ),
              actionWidget != null
                  ? actionWidget!
                  : SizedBox(height: 2, width: 2)
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
