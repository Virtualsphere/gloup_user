import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/permission_bottom_sheet.dart';

enum LocationRequiredDialogType {
  serviceDisabled,
  permissionDeniedForever,
}

/// Sheet asking the user to fix location in system settings.
///
/// - [LocationRequiredDialogType.serviceDisabled]: device GPS is off.
/// - [LocationRequiredDialogType.permissionDeniedForever]: Figma 39
///   "Permission — location blocked (open settings)".
///
/// Resolves to `true` when the user taps the settings action.
class LocationRequiredDialog extends StatelessWidget {
  final LocationRequiredDialogType type;
  final VoidCallback onOpenSettings;
  final VoidCallback onCancel;
  final String? cancelLabel;

  const LocationRequiredDialog({
    super.key,
    required this.type,
    required this.onOpenSettings,
    required this.onCancel,
    this.cancelLabel,
  });

  /// [cancelLabel] overrides the secondary action, e.g. "Keep using Anna Nagar".
  static Future<bool?> show(
    BuildContext context, {
    required LocationRequiredDialogType type,
    String? cancelLabel,
  }) {
    return PermissionBottomSheet.show<bool>(
      context,
      builder: (ctx) => LocationRequiredDialog(
        type: type,
        cancelLabel: cancelLabel,
        onOpenSettings: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (type == LocationRequiredDialogType.serviceDisabled) {
      return PermissionBottomSheet(
        illustration: const MapPinIllustration(),
        title: 'Device location is off',
        message:
            'Turn on GPS so we can confirm your booking with an accurate location.',
        primaryLabel: 'Turn on GPS',
        onPrimary: onOpenSettings,
        secondaryLabel: cancelLabel ?? 'Not now',
        onSecondary: onCancel,
        secondaryOutlined: false,
      );
    }

    return PermissionBottomSheet(
      title: 'Allow location in Settings',
      message:
          "You've blocked location for GloUp. Turn it on in 3 quick steps:",
      extra: const _SettingsSteps(),
      primaryLabel: 'Open settings',
      onPrimary: onOpenSettings,
      secondaryLabel: cancelLabel ?? 'Not now',
      onSecondary: onCancel,
      secondaryOutlined: false,
    );
  }
}

class _SettingsSteps extends StatelessWidget {
  const _SettingsSteps();

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    const steps = [
      ['Tap ', 'Open settings', ' below'],
      ['Go to ', 'Permissions → Location', ''],
      ['Choose ', 'Allow only while using the app', ''],
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: border,
                indent: AppSizes.padding,
                endIndent: AppSizes.padding,
              ),
            _SettingsStep(number: i + 1, parts: steps[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingsStep extends StatelessWidget {
  final int number;
  final List<String> parts;

  const _SettingsStep({required this.number, required this.parts});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final accent = PermissionColors.accent(isDark);
    final base = context.textTheme.bodyMedium?.copyWith(color: textColor);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: context.textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: parts[0]),
                  TextSpan(
                    text: parts[1],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: parts[2]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
