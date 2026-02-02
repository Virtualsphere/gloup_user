import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

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
      bottomNavigationBar: ClipRRect(
        child: Container(
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
            child: SizedBox(
              height: AppSizes.bottomNavHeight,
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
                    iconPath: 'assets/icons/ic_calendar.svg',
                    iconPathFill: 'assets/icons/ic_calendar_fill.svg',
                    label: 'Calendar',
                    index: 1,
                    isActive: navigationShell.currentIndex == 1,
                  ),
                  _buildNavItem(
                    iconPath: 'assets/icons/ic_profile.svg',
                    iconPathFill: 'assets/icons/ic_profile_fill.svg',
                    label: 'Profile',
                    index: 2,
                    isActive: navigationShell.currentIndex == 2,
                  ),
                ],
              ),
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
      child: InkWell(
        onTap: () => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.marginXXL),
          decoration: BoxDecoration(
            border: isActive
                ? Border(top: BorderSide(color: AppColors.primary, width: AppSizes.borderWidthThick))
                : null,
          ),
          child: Center(
            child: SvgPicture.asset(
              isActive ? iconPathFill : iconPath,
              width: AppSizes.iconM,
              height: AppSizes.iconM,
            ),
          ),
        ),
      ),
    );
  }
}
