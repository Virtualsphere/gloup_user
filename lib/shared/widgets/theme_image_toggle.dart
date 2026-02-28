import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/theme/theme_provider.dart';

class ThemeImageToggle extends StatelessWidget {
  const ThemeImageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment:
          isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child:
            SvgPicture.asset(
              isDarkMode ? AppIcons.icSun : AppIcons.icMoon,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}