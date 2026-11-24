import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/core/services/user_location_sync_service.dart';
import 'package:tressy/features/location/data/saved_address.dart';
import 'package:tressy/features/location/presentation/pages/location_page.dart';
import 'package:tressy/shared/widgets/location_required_dialog.dart';

/// Onboarding step after location access (Figma 21 "Confirm location",
/// node 58-2): drag the map under the pin, optionally add flat / landmark,
/// pick Home / Work / Other, then confirm. Saves the address, sets it as the
/// app location and goes to Home.
class ConfirmLocationPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ConfirmLocationPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ConfirmLocationPage> createState() => _ConfirmLocationPageState();
}

class _ConfirmLocationPageState extends State<ConfirmLocationPage> {
  static const Color _textDark = Color(0xFF262A30);
  static const Color _textGrey = Color(0xFF717784);
  static const Color _hintGrey = Color(0xFF9CA3AF);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _blue = Color(0xFF2D6FA6);
  static const Color _chipSelected = Color(0xFFEAF2FA);

  final _detailsController = TextEditingController();
  GoogleMapController? _mapController;
  Timer? _geocodeDebounce;

  late LatLng _target;
  SavedAddressLabel _label = SavedAddressLabel.home;
  bool _isResolving = true;
  bool _isLocating = false;
  bool _isSaving = false;
  String _area = '';
  String _city = '';
  String _street = '';
  String _fullAddress = '';

  bool get _canConfirm => !_isResolving && !_isSaving && _area.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _target = LatLng(widget.latitude, widget.longitude);
    _resolveAddress(_target);
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _mapController?.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng target) async {
    setState(() => _isResolving = true);
    try {
      final placemarks =
          await placemarkFromCoordinates(target.latitude, target.longitude);
      if (!mounted || target != _target) return;
      if (placemarks.isEmpty) throw StateError('no placemark');
      final p = placemarks.first;

      String clean(String? v) {
        final s = v?.trim() ?? '';
        return s.contains('+') ? '' : s; // drop plus-codes
      }

      final road = clean(p.thoroughfare).isNotEmpty
          ? clean(p.thoroughfare)
          : clean(p.street);
      final sub = clean(p.subLocality);
      final city = clean(p.locality).isNotEmpty
          ? clean(p.locality)
          : clean(p.administrativeArea);
      final postal = clean(p.postalCode);

      setState(() {
        _area = sub.isNotEmpty ? sub : (road.isNotEmpty ? road : city);
        _city = city;
        _street = [road, sub].where((e) => e.isNotEmpty).toSet().join(', ');
        _fullAddress = [
          [clean(p.name), road, sub, city]
              .where((e) => e.isNotEmpty)
              .toSet()
              .join(', '),
          postal,
        ].where((e) => e.isNotEmpty).join(' ');
        _isResolving = false;
      });
    } catch (_) {
      if (!mounted || target != _target) return;
      setState(() {
        _area = 'Pinned location';
        _city = '';
        _street = '';
        _fullAddress = "Couldn't look up this address. You can still save it.";
        _isResolving = false;
      });
    }
  }

  void _onCameraIdle() {
    _geocodeDebounce?.cancel();
    final target = _target;
    _geocodeDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _resolveAddress(target),
    );
  }

  Future<void> _moveTo(double lat, double lng) async {
    _target = LatLng(lat, lng);
    await _mapController?.animateCamera(CameraUpdate.newLatLng(_target));
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        final open = await LocationRequiredDialog.show(
          context,
          type: LocationRequiredDialogType.serviceDisabled,
        );
        if (open == true) await Geolocator.openLocationSettings();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        final open = await LocationRequiredDialog.show(
          context,
          type: LocationRequiredDialogType.permissionDeniedForever,
        );
        if (open == true) await Geolocator.openAppSettings();
        return;
      }
      if (permission == LocationPermission.denied) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      await _moveTo(position.latitude, position.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't get your location. Try again."),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchArea() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationPage(showSavedAddresses: false),
      ),
    );
    if (result is Map<String, dynamic> &&
        result['latitude'] is num &&
        result['longitude'] is num) {
      await _moveTo(
        (result['latitude'] as num).toDouble(),
        (result['longitude'] as num).toDouble(),
      );
    }
  }

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() => _isSaving = true);

    final details = _detailsController.text.trim();
    await SavedAddressStore.upsert(SavedAddress(
      id: SavedAddressStore.newId(),
      label: _label,
      flat: details,
      street: _street.isNotEmpty ? _street : _area,
      area: _area,
      city: _city,
      region: _fullAddress,
      latitude: _target.latitude,
      longitude: _target.longitude,
    ));

    if (!mounted) return;
    await context.read<LocationProvider>().updateLocation(
          latitude: _target.latitude,
          longitude: _target.longitude,
          city: _city.isNotEmpty ? _city : null,
          area: _area,
          silent: true,
        );
    unawaited(UserLocationSyncService.instance.reportManual(
      lat: _target.latitude,
      lng: _target.longitude,
    ));

    if (!mounted) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(height: mapHeight, child: _buildMap()),
          Expanded(child: _buildDetails()),
          _buildConfirmBar(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: _target, zoom: 16),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: (p) => _target = p.target,
            onCameraIdle: _onCameraIdle,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
          ),
        ),
        // Fixed pin; the map moves underneath it.
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, -28.h),
              child: _buildPin(),
            ),
          ),
        ),
        Positioned(
          top: topInset + 12.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            children: [
              _shadowed(
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.locationAccess);
                    }
                  },
                  child: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child:
                        Icon(Icons.chevron_left, color: _textDark, size: 24.w),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _shadowed(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: _searchArea,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 11.h),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18.w, color: _textGrey),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Search area, street or landmark',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: _hintGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24.h,
          child: Center(
            child: _shadowed(
              shape: const StadiumBorder(side: BorderSide(color: _border)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: _useCurrentLocation,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLocating
                          ? SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _blue,
                              ),
                            )
                          : Icon(Icons.near_me_outlined,
                              size: 16.w, color: _blue),
                      SizedBox(width: 6.w),
                      Text(
                        'Use current location',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: _textDark,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Salons near this spot',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Move the map to adjust',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: _blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 3.h),
          width: 14.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 12.h),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isResolving ? 'Finding address…' : _area,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    if (!_isResolving && _fullAddress.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        _fullAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: _textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _searchArea,
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    'Change',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          TextField(
            controller: _detailsController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(fontSize: 15.sp, color: _textDark),
            decoration: InputDecoration(
              hintText: 'Flat / house no. / landmark (optional)',
              hintStyle: GoogleFonts.inter(fontSize: 15.sp, color: _hintGrey),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _textDark, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Save as',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            children: [
              for (final label in SavedAddressLabel.values) _buildChip(label),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(SavedAddressLabel label) {
    final selected = _label == label;
    return GestureDetector(
      onTap: () => setState(() => _label = label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _chipSelected : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? _textDark : _border),
        ),
        child: Text(
          label.title,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        8.h,
        16.w,
        16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: _canConfirm ? _confirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _textDark,
            disabledBackgroundColor: const Color(0xFFC9CDD3),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Confirm & save location',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _shadowed({required ShapeBorder shape, required Widget child}) {
    return Material(
      color: Colors.white,
      shape: shape,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: child,
    );
  }
}
