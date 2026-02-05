import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';

/// Main scaffold with bottom navigation
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70, // Increased height for labels
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  iconPath: 'assets/icons/ic_home.svg',
                  iconPathFill: 'assets/icons/ic_home_fill.svg',
                  label: 'Home',
                  index: 0,
                  isActive: navigationShell.currentIndex == 0,
                ),
                _buildNavItem(
                  iconPath: 'assets/icons/ic_search.svg',
                  iconPathFill: 'assets/icons/ic_search_fill.svg',
                  label: 'Explore',
                  index: 1,
                  isActive: navigationShell.currentIndex == 1,
                ),
                _buildNavItem(
                  iconPath: 'assets/icons/ic_heart.svg',
                  iconPathFill: 'assets/icons/ic_heart_fill.svg',
                  label: 'Favorites',
                  index: 2,
                  isActive: navigationShell.currentIndex == 2,
                ),
                _buildNavItem(
                  iconPath: 'assets/icons/ic_calendar.svg',
                  iconPathFill: 'assets/icons/ic_calendar_fill.svg',
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
    required String iconPath,
    required String iconPathFill,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: Builder(
        builder: (context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return InkWell(
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
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                      ? AppColors.primary
                      : (isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }
}
