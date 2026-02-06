import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/theme/theme_provider.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return IconButton(
      icon: SvgPicture.asset(
        isDarkMode ? AppIcons.icSun : AppIcons.icMoon,
        width: 24,
        height: 24,
      ),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
