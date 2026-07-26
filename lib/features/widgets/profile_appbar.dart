import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool? centerTitle;

  const ProfileAppBar(
      {super.key, required this.title, this.onBack, this.centerTitle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leadingWidth: 40,
      titleSpacing: 10,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: isDarkMode ? AppColors.borderDark : AppColors.border,
          width: AppSizes.borderWidthThin,
        ),
      ),
      leading: IconButton(
        padding: EdgeInsets.only(left: 16.0),
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}
