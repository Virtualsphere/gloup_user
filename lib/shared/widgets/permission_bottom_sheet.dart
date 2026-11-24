import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

/// Shared colors for the location & permission screens (Figma "03 · Location
/// & permissions").
class PermissionColors {
  PermissionColors._();

  static const Color accentBlue = Color(0xFF2B6CB0);
  static const Color pageGrey = Color(0xFFF3F4F6);
  static const Color pageGreyDark = Color(0xFF0E0E0E);
  static const Color tileGrey = Color(0xFFE5E7EB);
  static const Color tileGreyDark = Color(0xFF2A2A2A);

  static Color page(bool isDark) => isDark ? pageGreyDark : pageGrey;
  static Color tile(bool isDark) => isDark ? tileGreyDark : tileGrey;
  static Color accent(bool isDark) =>
      isDark ? const Color(0xFF7DB3F0) : accentBlue;
}

/// Bottom sheet layout used by the permission prompts: drag handle,
/// illustration, title, message, optional extra content, a filled primary
/// action and a secondary action (outlined or plain text).
class PermissionBottomSheet extends StatelessWidget {
  final Widget? illustration;
  final String title;
  final String message;
  final Widget? extra;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final bool secondaryOutlined;

  const PermissionBottomSheet({
    super.key,
    this.illustration,
    required this.title,
    required this.message,
    this.extra,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.secondaryOutlined = true,
  });

  /// Shows a non-dismissible sheet; callers resolve it through the actions.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusL)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.paddingS,
        AppSizes.padding,
        AppSizes.padding + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSizes.space),
            if (illustration != null) ...[
              illustration!,
              SizedBox(height: AppSizes.spaceL),
            ],
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.spaceS),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: textSecondary,
                height: 1.4,
              ),
            ),
            if (extra != null) ...[
              SizedBox(height: AppSizes.space),
              extra!,
            ],
            SizedBox(height: AppSizes.spaceL),
            PermissionPrimaryButton(label: primaryLabel, onPressed: onPrimary),
            SizedBox(height: AppSizes.spaceS),
            secondaryOutlined
                ? PermissionSecondaryButton(
                    label: secondaryLabel,
                    onPressed: onSecondary,
                  )
                : TextButton(
                    onPressed: onSecondary,
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondary,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Filled dark button used across the location & permission screens.
class PermissionPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const PermissionPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.onPrimary : AppColors.textPrimary,
          foregroundColor: isDark ? AppColors.primary : AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.primary : AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined button paired with [PermissionPrimaryButton].
class PermissionSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const PermissionSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified street-map tile with a blue "you are here" dot.
class MapPinIllustration extends StatelessWidget {
  final double height;

  const MapPinIllustration({super.key, this.height = 104});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final block = PermissionColors.tile(isDark);
    final road = isDark ? AppColors.surfaceDark : AppColors.surface;
    final accent = PermissionColors.accent(isDark);

    Widget row() => Expanded(
          child: Row(
            children: [
              Expanded(child: Container(color: block)),
              SizedBox(width: 8, child: Container(color: road)),
              Expanded(child: Container(color: block)),
              SizedBox(width: 8, child: Container(color: road)),
              Expanded(child: Container(color: block)),
            ],
          ),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                row(),
                SizedBox(height: 8, child: Container(color: road)),
                row(),
              ],
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
