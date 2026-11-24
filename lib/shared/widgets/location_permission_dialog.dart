import 'package:flutter/material.dart';
import 'package:tressy/shared/widgets/permission_bottom_sheet.dart';

/// Soft prompt shown before the OS location permission request
/// (Figma 38 "Permission — location off").
class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  /// When set, the secondary action reads "Enter area manually" and calls
  /// this after [onDeny]; otherwise it reads "Not now".
  final VoidCallback? onEnterManually;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
    this.onEnterManually,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAllow,
    required VoidCallback onDeny,
    VoidCallback? onEnterManually,
  }) async {
    await PermissionBottomSheet.show<void>(
      context,
      builder: (context) => LocationPermissionDialog(
        onAllow: onAllow,
        onDeny: onDeny,
        onEnterManually: onEnterManually,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PermissionBottomSheet(
      illustration: const MapPinIllustration(),
      title: 'Turn on location for salons near you',
      message: 'We use it to show distance, open salons and travel time. '
          "It's never shared with salons.",
      primaryLabel: 'Turn on location',
      onPrimary: () {
        Navigator.of(context).pop();
        onAllow();
      },
      secondaryLabel:
          onEnterManually != null ? 'Enter area manually' : 'Not now',
      onSecondary: () {
        Navigator.of(context).pop();
        onDeny();
        onEnterManually?.call();
      },
    );
  }
}
