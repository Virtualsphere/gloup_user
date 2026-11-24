import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/location/data/saved_address.dart';
import 'package:tressy/features/location/presentation/pages/location_page.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/permission_bottom_sheet.dart';

/// Add or edit a saved address by dragging the map under a fixed pin
/// (Figma 21c "Add / edit address"). Pops with the saved [SavedAddress].
///
/// With [pickOnly] it's the "Pin on map" picker from Figma 21d: no form,
/// nothing saved, and it pops with a LocationPage-style result map
/// (`city`, `area`, `latitude`, `longitude`).
class AddAddressPage extends StatefulWidget {
  final SavedAddress? existing;
  final double initialLatitude;
  final double initialLongitude;
  final bool pickOnly;

  const AddAddressPage({
    super.key,
    this.existing,
    required this.initialLatitude,
    required this.initialLongitude,
    this.pickOnly = false,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _flatController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _nameController = TextEditingController();
  GoogleMapController? _mapController;
  Timer? _geocodeDebounce;

  late LatLng _target;
  SavedAddressLabel _label = SavedAddressLabel.home;
  bool _isResolving = true;
  bool _isSaving = false;
  bool _isLocating = false;
  String _street = '';
  String _area = '';
  String _city = '';
  String _region = '';

  bool get _isEditing => widget.existing != null;

  bool get _canSave =>
      !_isSaving &&
      !_isResolving &&
      _street.isNotEmpty &&
      (widget.pickOnly ||
          _flatController.text.trim().isNotEmpty &&
              (_label != SavedAddressLabel.other ||
                  _nameController.text.trim().isNotEmpty));

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _target = LatLng(existing.latitude, existing.longitude);
      _label = existing.label;
      _flatController.text = existing.flat;
      _landmarkController.text = existing.landmark ?? '';
      _nameController.text = existing.name ?? '';
      _street = existing.street;
      _area = existing.area;
      _city = existing.city;
      _region = existing.region;
      _isResolving = false;
    } else {
      _target = LatLng(widget.initialLatitude, widget.initialLongitude);
      _resolveAddress(_target);
    }
    for (final c in [_flatController, _nameController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _mapController?.dispose();
    _flatController.dispose();
    _landmarkController.dispose();
    _nameController.dispose();
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

      String clean(String? v) => v?.trim() ?? '';
      final road = clean(p.thoroughfare).isNotEmpty
          ? clean(p.thoroughfare)
          : clean(p.street);
      final area = clean(p.subLocality);
      final city = clean(p.locality).isNotEmpty
          ? clean(p.locality)
          : clean(p.administrativeArea);
      final state = clean(p.administrativeArea);
      final postal = clean(p.postalCode);

      setState(() {
        _street = [road, area]
            .where((e) => e.isNotEmpty && !e.contains('+'))
            .toSet()
            .join(', ');
        if (_street.isEmpty) _street = city.isEmpty ? 'Pinned location' : city;
        _area = area.isNotEmpty ? area : road;
        _city = city;
        _region = [
          [city, if (state != city) state]
              .where((e) => e.isNotEmpty)
              .join(', '),
          postal,
        ].where((e) => e.isNotEmpty).join(' ');
        _isResolving = false;
      });
    } catch (_) {
      if (!mounted || target != _target) return;
      setState(() {
        _street = 'Pinned location';
        _area = '';
        _city = '';
        _region = "Couldn't look up this address";
        _isResolving = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _target = position.target;
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
    // onCameraIdle resolves the address once the animation settles.
  }

  Future<void> _locateMe() async {
    setState(() => _isLocating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Turn on location to use Locate me'),
          ));
        }
        return;
      }
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

  Future<void> _changeArea() async {
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

  Future<void> _save() async {
    if (!_canSave) return;
    if (widget.pickOnly) {
      Navigator.pop(context, {
        'city': _city,
        'area': _area.isNotEmpty ? _area : _street,
        'latitude': _target.latitude,
        'longitude': _target.longitude,
      });
      return;
    }
    setState(() => _isSaving = true);
    final landmark = _landmarkController.text.trim();
    final address = SavedAddress(
      id: widget.existing?.id ?? SavedAddressStore.newId(),
      label: _label,
      name: _label == SavedAddressLabel.other
          ? _nameController.text.trim()
          : null,
      flat: _flatController.text.trim(),
      landmark: landmark.isEmpty ? null : landmark,
      street: _street,
      area: _area,
      city: _city,
      region: _region,
      latitude: _target.latitude,
      longitude: _target.longitude,
    );
    await SavedAddressStore.upsert(address);
    if (!mounted) return;
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final mapHeight =
        MediaQuery.of(context).size.height * (widget.pickOnly ? 0.62 : 0.34);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: Column(
        children: [
          SizedBox(height: mapHeight, child: _buildMap(isDark)),
          Expanded(child: _buildForm(isDark)),
          _buildSaveBar(isDark),
        ],
      ),
    );
  }

  Widget _buildMap(bool isDark) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: _target, zoom: 17),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: _onCameraMove,
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
              offset: const Offset(0, -24),
              child: const _PinWithTooltip(),
            ),
          ),
        ),
        Positioned(
          top: topInset + AppSizes.paddingS,
          left: AppSizes.padding,
          child: _CircleButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          right: AppSizes.padding,
          bottom: AppSizes.paddingM,
          child: Material(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            elevation: 2,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: _isLocating ? null : _locateMe,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLocating
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PermissionColors.accent(isDark),
                            ),
                          )
                        : Icon(Icons.near_me_outlined,
                            size: 16, color: PermissionColors.accent(isDark)),
                    SizedBox(width: AppSizes.spaceXS + 2),
                    Text(
                      'Locate me',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PermissionColors.accent(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ListView(
      padding: EdgeInsets.all(AppSizes.padding),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isResolving ? 'Finding address…' : _street,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  if (!_isResolving && _region.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _region,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: _changeArea,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Change',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PermissionColors.accent(isDark),
                ),
              ),
            ),
          ],
        ),
        if (!widget.pickOnly) ...[
          SizedBox(height: AppSizes.spaceL),
          _AddressField(
            controller: _flatController,
            label: 'Flat / house no. *',
            hint: 'e.g. Flat 4B, Lotus Apartments',
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.space),
          _AddressField(
            controller: _landmarkController,
            label: 'Landmark (optional)',
            hint: 'e.g. Near Tower Park',
            isDark: isDark,
          ),
          SizedBox(height: AppSizes.spaceL),
          Text(
            'SAVE AS',
            style: context.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.spaceS),
          Wrap(
            spacing: AppSizes.spaceS,
            children: [
              for (final label in SavedAddressLabel.values)
                _LabelChip(
                  label: label.title,
                  selected: _label == label,
                  isDark: isDark,
                  onTap: () => setState(() => _label = label),
                ),
            ],
          ),
          if (_label == SavedAddressLabel.other) ...[
            SizedBox(height: AppSizes.space),
            _AddressField(
              controller: _nameController,
              label: 'Name this address *',
              hint: "e.g. Mom's place",
              isDark: isDark,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildSaveBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.paddingS,
        AppSizes.padding,
        AppSizes.padding + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        child: PermissionPrimaryButton(
          label: widget.pickOnly
              ? 'Confirm location'
              : (_isEditing ? 'Update address' : 'Save address'),
          onPressed: _canSave ? _save : null,
          height: 52,
        ),
      ),
    );
  }
}

class _PinWithTooltip extends StatelessWidget {
  const _PinWithTooltip();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingXS + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Text(
            'Your salon visits start here',
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(width: 2, height: 18, color: AppColors.textPrimary),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.onPrimary, width: 2),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: context.textTheme.bodyLarge?.copyWith(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: context.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        hintStyle: context.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.textHintDark : AppColors.textHint,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.padding,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: BorderSide(color: textPrimary, width: 1.5),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _LabelChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = PermissionColors.accent(isDark);
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.padding,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          border: Border.all(
            color: selected
                ? textPrimary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),
    );
  }
}
