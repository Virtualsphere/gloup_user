import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.colorScheme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  iconPath: AppIcons.icHome,
                  iconPathFill: AppIcons.icHomeFill,
                  label: 'Home',
                  index: 0,
                  isActive: navigationShell.currentIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  iconPath: AppIcons.icSearch,
                  iconPathFill: AppIcons.icSearchFill,
                  label: 'Explore',
                  index: 1,
                  isActive: navigationShell.currentIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  iconPath: AppIcons.icHeart,
                  iconPathFill: AppIcons.icHeartFill,
                  label: 'Favorites',
                  index: 2,
                  isActive: navigationShell.currentIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  iconPath: AppIcons.icCalendar,
                  iconPathFill: AppIcons.icCalendarFill,
                  label: 'Bookings',
                  index: 3,
                  isActive: navigationShell.currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required String iconPathFill,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final colorScheme = context.colorScheme;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isActive ? iconPathFill : iconPath,
                width: AppSizes.iconM,
                height: AppSizes.iconM,
                fit: BoxFit.contain,
                colorFilter: isActive
                    ? ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      )
                    : ColorFilter.mode(
                        colorScheme.onSurface.withValues(alpha: 0.6),
                        BlendMode.srcIn,
                      ),
              ),
              const SizedBox(height: 4),
              // Text(
              //   label,
              //   style: textTheme.labelSmall?.copyWith(
              //     color: isActive
              //         ? colorScheme.primary
              //         : colorScheme.onSurface.withValues(alpha: 0.6),
              //     fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              //     fontSize: 12,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
