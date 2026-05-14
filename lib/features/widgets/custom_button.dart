import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/text_styles.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CustomFullButton extends StatelessWidget {
  const CustomFullButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isDisabled = false,
    this.buttonColor = AppColors.primary,
    this.titleColor = AppColors.white,
    this.borderRadius = 10,
    this.buttonHeight = 56,
    this.isLoading = false,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.textColor,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isDisabled;
  final Color buttonColor, titleColor;
  final double borderRadius, buttonHeight;
  final bool isLoading;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            borderRadius,
          ),
          color: isDisabled
              ? (isDarkMode ? AppColors.borderDark : AppColors.border)
              : (isDarkMode ? AppColors.borderDark : AppColors.border),
        ),
        child: Center(
          child: Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFullPayButton extends StatelessWidget {
  const CustomFullPayButton({
    super.key,
    required this.title,
    required this.payTitle,
    required this.onTap,
    this.buttonColor = AppColors.primary,
  });

  final String title, payTitle;
  final VoidCallback onTap;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: buttonColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            payTitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryColor,
            ),
          ),
          SvgPicture.asset(
            AppIcons.rupee,
            height: 18,
            width: 18,
            colorFilter: ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          Text(
            '$title /-',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onTap,
    this.outlineColor = AppColors.primary,
    this.titleColor = AppColors.primary,
  });

  final String title;
  final VoidCallback onTap;
  final Color outlineColor, titleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadiusDirectional.circular(15),
          border: Border.all(color: outlineColor, width: 1),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: titleColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonProgressBar extends StatelessWidget {
  const ButtonProgressBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromRadius(25)),
          shape: WidgetStateProperty.all(const CircleBorder()),
          backgroundColor: WidgetStatePropertyAll(
            AppColors.primary,
          ),
        ),
        onPressed: null,
        child: const SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}

// ---------------------------- POP UP MENU BUTTONS ----------------------------

class CustomPopupMenuButton extends StatelessWidget {
  const CustomPopupMenuButton({
    super.key,
    this.width = 110,
    required this.items,
    this.alignment = Alignment.center,
    this.iconColor = AppColors.primary,
    this.backgroundColor,
  });

  final double width;
  final List<PopupMenuItemData> items;
  final Alignment alignment;
  final Color iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return PopupMenuTheme(
      data: PopupMenuThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDarkMode ? AppColors.black : AppColors.borderColor,
            width: 1,
          ),
        ),
        surfaceTintColor: Colors.white,
        color: backgroundColor,
        position: PopupMenuPosition.under,
        iconColor: iconColor,
      ),
      child: PopupMenuButton(
        color: isDarkMode ? context.colorScheme.surface : AppColors.white,
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_vert_sharp,
          size: 20,
        ),
        constraints: BoxConstraints.tightFor(width: width),
        itemBuilder: (BuildContext context) {
          List<PopupMenuEntry> menuItems = [];
          for (int i = 0; i < items.length; i++) {
            menuItems.add(
              PopupMenuItem(
                height: 30,
                value: items[i].value,
                onTap: items[i].onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: alignment,
                  child: Text(
                    items[i].title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? AppColors.white : AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }
          return menuItems;
        },
      ),
    );
  }
}

class PopupMenuItemData {
  final String title;
  final String value;
  final VoidCallback onTap;

  PopupMenuItemData({
    required this.title,
    required this.value,
    required this.onTap,
  });
}

class CustomPopupMenuButtonDelete extends StatelessWidget {
  const CustomPopupMenuButtonDelete({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuTheme(
      data: PopupMenuThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        surfaceTintColor: AppColors.white,
        color: AppColors.white,
        position: PopupMenuPosition.under,
      ),
      child: PopupMenuButton(
        color: AppColors.background,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(height: 48, width: 160),
        itemBuilder: (BuildContext bc) {
          return [
            PopupMenuItem(
              height: 32,
              value: '/delete',
              onTap: onTap,
              child: Center(
                child: HeaderTextBlack(
                  title: "Delete Card",
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ];
        },
      ),
    );
  }
}
