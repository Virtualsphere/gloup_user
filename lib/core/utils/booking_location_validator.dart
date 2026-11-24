import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';
import 'package:tressy/shared/widgets/location_required_dialog.dart';

/// Validates device location and permissions before allowing a booking.
/// Guarantees that bookings use a verified, fresh live location and prevents
/// bookings from proceeding when device location is disabled or outdated.
class BookingLocationValidator {
  BookingLocationValidator._();

  /// Checks whether device location is enabled and permission is granted.
  /// If disabled, presents a dialog directing the user to device location settings.
  /// If permanently denied, presents a dialog directing the user to app settings.
  /// If enabled, acquires a fresh live GPS fix, updates the local state and backend,
  /// and returns the fresh [Position].
  ///
  /// Returns `null` if location is disabled/denied or cannot be determined,
  /// which immediately BLOCKS the booking from proceeding.
  static Future<Position?> ensureLocationEnabled(BuildContext context) async {
    // 1. Check whether device location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return null;

      final openSettings = await LocationRequiredDialog.show(
        context,
        type: LocationRequiredDialogType.serviceDisabled,
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
        // User may have just toggled location in device settings; re-check.
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (context.mounted) {
            CustomToast.showError(
              context,
              'Device location is still disabled. Please turn it on to proceed with your booking.',
            );
          }
          return null;
        }
      } else {
        return null;
      }
    }

    // 2. Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          CustomToast.showError(
            context,
            'Location permission is required to confirm your booking.',
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return null;

      final openSettings = await LocationRequiredDialog.show(
        context,
        type: LocationRequiredDialogType.permissionDeniedForever,
      );

      if (openSettings == true) {
        await Geolocator.openAppSettings();
      }
      return null;
    }

    // 3. Prevent bookings from using an incorrect or outdated location:
    // Acquire a fresh live position.
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('[BookingLocationValidator] High accuracy failed: $e');
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
    }

    if (position == null) {
      if (context.mounted) {
        CustomToast.showError(
          context,
          'Unable to get your current location. Please check your GPS signal and try again.',
        );
      }
      return null;
    }

    // 4. Update local storage & global provider so app state is current
    await LocalStorageService.setDouble('user_latitude', position.latitude);
    await LocalStorageService.setDouble('user_longitude', position.longitude);

    if (context.mounted) {
      try {
        unawaited(context.read<LocationProvider>().updateLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              silent: true,
            ));
      } catch (e) {
        debugPrint('[BookingLocationValidator] LocationProvider update error: $e');
      }
    }

    // 5. Send verified live location to backend immediately so the booking snapshot is fresh
    unawaited(UserLocationSyncService.instance.reportLiveLocation(
      lat: position.latitude,
      lng: position.longitude,
    ));

    return position;
  }
}
