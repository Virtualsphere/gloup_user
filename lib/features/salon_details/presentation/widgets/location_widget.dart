import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String salonName;

  const LocationWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.salonName,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  late Set<Marker> _markers;

  Future<void> _openMapsDirections(
      String lat, String lng, String salonName) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$salonName&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
              liteModeEnabled: true,
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
              colorFilter: ColorFilter.mode(
                isDarkMode ? AppColors.primaryDark : AppColors.primary,
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
            _openMapsDirections(
              widget.latitude.toString(),
              widget.longitude.toString(),
              widget.salonName,
            );
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
            padding: EdgeInsets.symmetric(
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
              SizedBox(width: AppSizes.spaceS),
              Text(
                'Get Direction',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSizes.spaceS),
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
