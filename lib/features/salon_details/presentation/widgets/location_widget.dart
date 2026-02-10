import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class LocationWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const LocationWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: const MarkerId('salon_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: 'Salon Location',
          snippet: widget.address,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rounded map container
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15,
              ),
              markers: _markers,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
        AppSizes.heightL,
        // Address row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_location.svg',
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Expanded(
              child: Text(
                widget.address,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        AppSizes.heightL,
        // Get Direction button
        OutlinedButton(
          onPressed: () {
            // TODO: Open Google Maps with directions
            // Example: Open maps app with coordinates
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDarkMode
                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                  : AppColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/ic_location.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              Text(
                'Get Direction',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
