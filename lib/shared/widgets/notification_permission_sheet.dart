import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_images.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/permission_bottom_sheet.dart';

/// Soft prompt shown before the OS notification permission request
/// (Figma 40 "Permission — notifications off").
///
/// Resolves to `true` when the user taps "Allow notifications".
class NotificationPermissionSheet extends StatelessWidget {
  const NotificationPermissionSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final allowed = await PermissionBottomSheet.show<bool>(
      context,
      builder: (_) => const NotificationPermissionSheet(),
    );
    return allowed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PermissionBottomSheet(
      illustration: const _NotificationPreview(),
      title: 'Never miss your appointment',
      message:
          'Get a reminder before each slot, booking updates and Flash deals. '
          'Change this any time in Profile.',
      primaryLabel: 'Allow notifications',
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Not now',
      onSecondary: () => Navigator.of(context).pop(false),
      secondaryOutlined: false,
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: PermissionColors.page(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: const Column(
        children: [
          _PreviewCard(
            title: 'Your slot is in 2 hours',
            subtitle: 'Glamour Studio · 11:30 AM · PIN 8347',
            time: 'now',
          ),
          SizedBox(height: 8),
          _PreviewCard(
            title: 'Flash: 45% off massages till 6:30 PM',
            subtitle: '3 salons near you',
            time: '2h',
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS + 2,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusS + 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            isDark ? AppImages.logoDark : AppImages.logo,
            width: 32,
            height: 16,
            fit: BoxFit.contain,
          ),
          SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.spaceS),
          Text(
            time,
            style: context.textTheme.labelSmall?.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}
