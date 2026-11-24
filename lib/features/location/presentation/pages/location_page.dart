import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/utils/app_logger.dart';
import 'package:tressy/features/location/data/saved_address.dart';
import 'package:tressy/features/location/presentation/pages/add_address_page.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/location_required_dialog.dart';
import 'package:tressy/shared/widgets/permission_bottom_sheet.dart';

/// Why "Use current location" is unavailable (Figma 21d).
enum _LocationIssue {
  none,
  serviceOff,
  lookupFailed,
  permissionDenied,
  permissionBlocked,
}

class LocationPage extends StatefulWidget {
  /// Hide "Add address" and saved addresses (used when picking an area from
  /// the add-address screen itself).
  final bool showSavedAddresses;

  const LocationPage({super.key, this.showSavedAddresses = true});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoadingLocation = false;
  _LocationIssue _issue = _LocationIssue.none;
  String _currentCity = '';
  String _currentArea = '';
  String _currentFullAddress = '';
  double? _currentLatitude;
  double? _currentLongitude;

  // Nearby locations
  List<Map<String, dynamic>> _nearbyLocations = [];

  List<SavedAddress> _savedAddresses = [];

  // Autocomplete predictions
  List<Map<String, dynamic>> _predictions = [];
  Timer? _debounceTimer;

  // Google Places API Key
  static const String _googlePlacesApiKey =
      'AIzaSyBACvmG9-ekKRhJYRhSTVa7Et10IArFzUs';

  static String _logSafeUri(Uri uri) {
    final params = Map<String, String>.from(uri.queryParameters);
    if (params.containsKey('key')) params['key'] = '***';
    return uri.replace(queryParameters: params).toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.showSavedAddresses) {
      _savedAddresses = SavedAddressStore.load();
    }
    _getCurrentLocation();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check after the user returns from device / app settings.
    if (state == AppLifecycleState.resumed &&
        (_issue == _LocationIssue.serviceOff ||
            _issue == _LocationIssue.permissionBlocked)) {
      _getCurrentLocation(requestIfDenied: false);
    }
  }

  void _setIssue(_LocationIssue issue) {
    if (!mounted) return;
    setState(() {
      _issue = issue;
      _isLoadingLocation = false;
    });
  }

  Future<void> _getCurrentLocation({bool requestIfDenied = true}) async {
    setState(() {
      _isLoadingLocation = true;
      _issue = _LocationIssue.none;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setIssue(_LocationIssue.serviceOff);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestIfDenied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _setIssue(_LocationIssue.permissionDenied);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setIssue(_LocationIssue.permissionBlocked);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          String fullAddress = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            fullAddress = place.subLocality!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            fullAddress +=
                fullAddress.isEmpty ? place.locality! : ', ${place.locality!}';
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty
                ? place.administrativeArea!
                : ', ${place.administrativeArea!}';
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            fullAddress += ' - ${place.postalCode!}';
          }

          if (!mounted) return;
          setState(() {
            _currentCity =
                place.locality ?? place.administrativeArea ?? 'Unknown';
            _currentArea = place.subLocality ?? place.thoroughfare ?? '';
            _currentFullAddress =
                fullAddress.isEmpty ? 'Unknown Location' : fullAddress;
            _isLoadingLocation = false;
          });

          _loadNearbyLocations(position.latitude, position.longitude);
        } else {
          _setIssue(_LocationIssue.lookupFailed);
        }
      } catch (e) {
        _setIssue(_LocationIssue.lookupFailed);
      }
    } catch (e) {
      _setIssue(_LocationIssue.lookupFailed);
    }
  }

  Future<void> _loadNearbyLocations(double lat, double lng) async {
    try {
      final url = Uri.parse(
        '${ApiRoutes.externalEndpoints['googlePlacesNearbySearch']}'
        '?location=$lat,$lng'
        '&radius=5000'
        '&type=locality'
        '&key=$_googlePlacesApiKey',
      );

      AppLogger.info(
        '→ GET ${_logSafeUri(url)} [googlePlacesNearbySearch]',
        tag: 'API',
      );
      final stopwatch = Stopwatch()..start();
      final response = await http.get(url);
      AppLogger.info(
        '← ${response.statusCode} googlePlacesNearbySearch (${stopwatch.elapsedMilliseconds}ms)',
        tag: 'API',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          List<Map<String, dynamic>> locations = [];

          for (var i = 0; i < results.length && i < 10; i++) {
            final place = results[i];
            final placeLat = place['geometry']['location']['lat'];
            final placeLng = place['geometry']['location']['lng'];

            final distance =
                Geolocator.distanceBetween(lat, lng, placeLat, placeLng);
            final distanceInKm = (distance / 1000).toStringAsFixed(1);
            final fullAddress = place['vicinity'] ?? place['name'] ?? '';

            locations.add({
              'name': place['name'] ?? 'Unknown',
              'area': place['vicinity'] ?? '',
              'fullAddress': fullAddress,
              'distance': '$distanceInKm km away',
              'latitude': placeLat,
              'longitude': placeLng,
            });
          }

          locations.sort((a, b) {
            final distA = double.parse(
                a['distance'].toString().replaceAll(' km away', ''));
            final distB = double.parse(
                b['distance'].toString().replaceAll(' km away', ''));
            return distA.compareTo(distB);
          });

          if (mounted) {
            setState(() {
              _nearbyLocations = locations;
            });
          }
        } else {
          _loadFallbackNearbyLocations(lat, lng);
        }
      } else {
        _loadFallbackNearbyLocations(lat, lng);
      }
    } catch (e) {
      AppLogger.error('googlePlacesNearbySearch failed', error: e, tag: 'API');
      _loadFallbackNearbyLocations(lat, lng);
    }
  }

  Future<void> _loadFallbackNearbyLocations(double lat, double lng) async {
    setState(() {
      _nearbyLocations = List.generate(5, (index) {
        final latOffset = (index + 1) * 0.01;
        final lngOffset = (index + 1) * 0.01;
        return {
          'name': 'Location ${index + 1}',
          'distance': '${(index + 1) * 0.5} km away',
          'latitude': lat + latOffset,
          'longitude': lng + lngOffset,
        };
      });
    });

    for (var i = 0; i < _nearbyLocations.length; i++) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _nearbyLocations[i]['latitude'],
          _nearbyLocations[i]['longitude'],
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          String fullAddress = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            fullAddress = place.subLocality!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            fullAddress +=
                fullAddress.isEmpty ? place.locality! : ', ${place.locality!}';
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty
                ? place.administrativeArea!
                : ', ${place.administrativeArea!}';
          }

          if (!mounted) return;
          setState(() {
            _nearbyLocations[i]['name'] = place.subLocality ??
                place.locality ??
                place.administrativeArea ??
                'Location ${i + 1}';
            _nearbyLocations[i]['area'] = place.locality ?? '';
            _nearbyLocations[i]['fullAddress'] =
                fullAddress.isEmpty ? 'Unknown Location' : fullAddress;
          });
        }
      } catch (e) {
        debugPrint('Error getting nearby location address: $e');
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    try {
      String locationBias = '';
      if (_currentLatitude != null && _currentLongitude != null) {
        locationBias =
            '&location=$_currentLatitude,$_currentLongitude&radius=50000';
      }

      final url = Uri.parse(
        '${ApiRoutes.externalEndpoints['googlePlacesAutocomplete']}'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:in'
        '&key=$_googlePlacesApiKey'
        '$locationBias',
      );

      AppLogger.info(
        '→ GET ${_logSafeUri(url)} [googlePlacesAutocomplete]',
        tag: 'API',
      );
      final stopwatch = Stopwatch()..start();
      final response = await http.get(url);
      AppLogger.info(
        '← ${response.statusCode} googlePlacesAutocomplete (${stopwatch.elapsedMilliseconds}ms)',
        tag: 'API',
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          setState(() {
            _predictions = List<Map<String, dynamic>>.from(data['predictions']);
          });
        } else {
          setState(() {
            _predictions = [];
          });
        }
      }
    } catch (e) {
      AppLogger.error('googlePlacesAutocomplete failed', error: e, tag: 'API');
    }
  }

  Future<void> _handlePredictionTap(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'];
    if (placeId == null) return;

    try {
      final url = Uri.parse(
        '${ApiRoutes.externalEndpoints['googlePlacesDetails']}'
        '?place_id=$placeId'
        '&fields=geometry,name,formatted_address'
        '&key=$_googlePlacesApiKey',
      );

      AppLogger.info(
        '→ GET ${_logSafeUri(url)} [googlePlacesDetails]',
        tag: 'API',
      );
      final stopwatch = Stopwatch()..start();
      final response = await http.get(url);
      AppLogger.info(
        '← ${response.statusCode} googlePlacesDetails (${stopwatch.elapsedMilliseconds}ms)',
        tag: 'API',
      );
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final lat = (result['geometry']['location']['lat'] as num).toDouble();
          final lng = (result['geometry']['location']['lng'] as num).toDouble();

          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty && mounted) {
            Placemark place = placemarks[0];
            Navigator.pop(context, {
              'city': place.locality ?? place.administrativeArea ?? '',
              'area': place.subLocality ?? prediction['description'] ?? '',
              'latitude': lat,
              'longitude': lng,
            });
          }
        }
      }
    } catch (e) {
      AppLogger.error('googlePlacesDetails failed', error: e, tag: 'API');
    }
  }

  String _extractMainName(String fullAddress) {
    if (fullAddress.isEmpty) return '';
    final parts = fullAddress.split(',');
    return parts.first.trim();
  }

  void _useCurrentLocation() {
    if (_isLoadingLocation ||
        _currentLatitude == null ||
        _currentLongitude == null) {
      return;
    }
    Navigator.pop(context, {
      'city': _currentCity,
      'area': _currentArea,
      'latitude': _currentLatitude,
      'longitude': _currentLongitude,
    });
  }

  Future<void> _openAddressEditor([SavedAddress? existing]) async {
    final provider = context.read<LocationProvider>();
    final saved = await Navigator.push<SavedAddress>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressPage(
          existing: existing,
          initialLatitude: _currentLatitude ?? provider.latitude,
          initialLongitude: _currentLongitude ?? provider.longitude,
        ),
      ),
    );
    if (saved != null && mounted) {
      setState(() => _savedAddresses = SavedAddressStore.load());
    }
  }

  /// "Pin on map" (Figma 21d): pick a spot on the map and return it.
  Future<void> _pinOnMap() async {
    final provider = context.read<LocationProvider>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressPage(
          pickOnly: true,
          initialLatitude: _currentLatitude ?? provider.latitude,
          initialLongitude: _currentLongitude ?? provider.longitude,
        ),
      ),
    );
    if (result is Map<String, dynamic> && mounted) {
      Navigator.pop(context, result);
    }
  }

  Future<void> _deleteAddress(SavedAddress address) async {
    final list = await SavedAddressStore.remove(address.id);
    if (!mounted) return;
    setState(() => _savedAddresses = list);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${address.title} address deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final restored = await SavedAddressStore.upsert(address);
            if (mounted) setState(() => _savedAddresses = restored);
          },
        ),
      ));
  }

  Future<void> _shareAddress(SavedAddress address) async {
    final mapsUrl = 'https://maps.google.com/?q='
        '${address.latitude},${address.longitude}';
    await SharePlus.instance.share(ShareParams(
      text: '${address.title}\n${address.fullLine}\n$mapsUrl',
    ));
  }

  Future<void> _openBlockedPermissionSheet() async {
    final openSettings = await LocationRequiredDialog.show(
      context,
      type: LocationRequiredDialogType.permissionDeniedForever,
    );
    if (openSettings == true) {
      await Geolocator.openAppSettings();
    }
  }

  // ---------------------------------------------------------------------------
  // UI (Figma 21b "Select location" / 21d "GPS off & lookup failed")
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: PermissionColors.page(isDark),
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSizes.padding,
                AppSizes.padding,
                AppSizes.padding,
                AppSizes.padding + MediaQuery.of(context).padding.bottom,
              ),
              children: isSearching
                  ? _buildSearchResults(isDark)
                  : _buildDefaultContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingS,
        MediaQuery.of(context).padding.top + AppSizes.paddingS,
        AppSizes.padding,
        AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: textPrimary, size: 28),
                tooltip: 'Close',
              ),
              Expanded(
                child: Text(
                  'Select a location',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spaceS),
          Padding(
            padding: EdgeInsets.only(left: AppSizes.paddingS),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: context.textTheme.bodyMedium?.copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Search area, street or locality',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
                prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                          });
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
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
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultContent(bool isDark) {
    return [
      if (_issue == _LocationIssue.none)
        _Card(
          isDark: isDark,
          child: Column(
            children: [
              _buildCurrentLocationRow(isDark),
              if (widget.showSavedAddresses) ...[
                _divider(isDark),
                _buildAddAddressRow(isDark),
              ],
            ],
          ),
        )
      else ...[
        _buildIssueCard(isDark),
        if (widget.showSavedAddresses) ...[
          SizedBox(height: AppSizes.spaceM),
          _Card(isDark: isDark, child: _buildAddAddressRow(isDark)),
        ],
      ],
      if (_savedAddresses.isNotEmpty) ...[
        SizedBox(height: AppSizes.spaceL),
        _SectionLabel(text: 'Saved addresses', isDark: isDark),
        SizedBox(height: AppSizes.spaceS),
        for (final address in _savedAddresses) ...[
          _buildSavedAddressCard(address, isDark),
          SizedBox(height: AppSizes.spaceS),
        ],
      ],
      if (_nearbyLocations.isNotEmpty) ...[
        SizedBox(height: AppSizes.spaceL),
        _SectionLabel(text: 'Nearby localities', isDark: isDark),
        SizedBox(height: AppSizes.spaceS),
        _Card(
          isDark: isDark,
          child: Column(
            children: [
              for (var i = 0; i < _nearbyLocations.length; i++) ...[
                if (i > 0) _divider(isDark),
                _buildLocalityRow(_nearbyLocations[i], isDark),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildSearchResults(bool isDark) {
    return [
      _Card(
        isDark: isDark,
        child: Column(
          children: [
            if (_issue == _LocationIssue.none) ...[
              _buildCurrentLocationRow(isDark),
              if (_predictions.isNotEmpty) _divider(isDark),
            ],
            for (var i = 0; i < _predictions.length; i++) ...[
              if (i > 0) _divider(isDark),
              _buildPredictionRow(_predictions[i], isDark),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildAddAddressRow(bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return _Row(
      isDark: isDark,
      onTap: () => _openAddressEditor(),
      leading: _IconTile(
        icon: Icons.add,
        color: textPrimary,
        background: PermissionColors.page(isDark),
      ),
      title: 'Add address',
    );
  }

  Widget _buildSavedAddressCard(SavedAddress address, bool isDark) {
    final provider = context.read<LocationProvider>();
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final isSelected = Geolocator.distanceBetween(
          provider.latitude,
          provider.longitude,
          address.latitude,
          address.longitude,
        ) <
        50;
    final switchesCity = address.city.isNotEmpty &&
        provider.city.isNotEmpty &&
        address.city.toLowerCase() != provider.city.toLowerCase();

    String? distance;
    if (_currentLatitude != null && _currentLongitude != null) {
      final km = Geolocator.distanceBetween(
            _currentLatitude!,
            _currentLongitude!,
            address.latitude,
            address.longitude,
          ) /
          1000;
      distance = km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
    }

    final icon = switch (address.label) {
      SavedAddressLabel.home => Icons.home_outlined,
      SavedAddressLabel.work => Icons.work_outline,
      SavedAddressLabel.other => Icons.location_on_outlined,
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: isSelected
            ? Border.all(color: textPrimary, width: 1.2)
            : Border.all(color: Colors.transparent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, address.toLocationResult()),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Icon(icon, size: 20, color: textPrimary),
                      if (distance != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          distance,
                          textAlign: TextAlign.center,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.spaceS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: AppSizes.spaceS),
                            const _SelectedBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address.fullLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      if (distance == null &&
                          _issue != _LocationIssue.none) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Distance unavailable while location is off',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                      if (switchesCity) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Switches city to ${address.city}',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: PermissionColors.accent(isDark),
                          ),
                        ),
                      ],
                      SizedBox(height: AppSizes.spaceS),
                      Wrap(
                        spacing: AppSizes.spaceS,
                        runSpacing: AppSizes.spaceXS,
                        children: [
                          _PillButton(
                            label: 'Edit',
                            onTap: () => _openAddressEditor(address),
                          ),
                          _PillButton(
                            label: 'Share',
                            icon: Icons.share_outlined,
                            onTap: () => _shareAddress(address),
                          ),
                          _PillButton(
                            label: 'Delete',
                            onTap: () => _deleteAddress(address),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        thickness: 1,
        indent: AppSizes.padding,
        endIndent: AppSizes.padding,
        color: isDark ? AppColors.borderDark : AppColors.border,
      );

  Widget _buildCurrentLocationRow(bool isDark) {
    final accent = PermissionColors.accent(isDark);
    final String subtitle;
    if (_isLoadingLocation) {
      subtitle = 'Getting your location...';
    } else {
      subtitle = _currentFullAddress;
    }

    return _Row(
      isDark: isDark,
      onTap: _isLoadingLocation ? null : _useCurrentLocation,
      leading: _IconTile(
        icon: Icons.near_me_outlined,
        color: accent,
        background: accent.withValues(alpha: 0.1),
      ),
      title: 'Use current location',
      titleColor: accent,
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailing: _isLoadingLocation
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            )
          : null,
    );
  }

  Widget _buildLocalityRow(Map<String, dynamic> location, bool isDark) {
    return _Row(
      isDark: isDark,
      onTap: () {
        Navigator.pop(context, {
          'city': location['name'],
          'area': location['area'] ?? '',
          'latitude': location['latitude'],
          'longitude': location['longitude'],
        });
      },
      leading: Icon(
        Icons.location_on_outlined,
        size: 20,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      title: location['name']?.toString() ?? '',
      subtitle: location['distance']?.toString(),
      showChevron: false,
    );
  }

  Widget _buildPredictionRow(Map<String, dynamic> prediction, bool isDark) {
    final description = prediction['description'] as String? ?? '';
    final mainText =
        (prediction['structured_formatting']?['main_text'] as String?) ??
            _extractMainName(description);

    return _Row(
      isDark: isDark,
      onTap: () => _handlePredictionTap(prediction),
      leading: Icon(
        Icons.location_on_outlined,
        size: 20,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      title: mainText,
      subtitle: description,
    );
  }

  Widget _buildIssueCard(bool isDark) {
    switch (_issue) {
      case _LocationIssue.serviceOff:
        return _IssueCard(
          isDark: isDark,
          icon: Icons.near_me_outlined,
          iconColor: const Color(0xFFD97706),
          title: 'Device location is off',
          message: 'Turn on GPS to use your current location',
          primaryLabel: 'Turn on GPS',
          onPrimary: Geolocator.openLocationSettings,
          secondaryLabel: 'Search instead',
          onSecondary: _searchFocusNode.requestFocus,
        );
      case _LocationIssue.lookupFailed:
        return _IssueCard(
          isDark: isDark,
          icon: Icons.location_on_outlined,
          iconColor: const Color(0xFFE11D48),
          title: "Couldn't find your address",
          message: 'GPS is on, but the lookup timed out (weak signal).',
          primaryLabel: 'Retry',
          onPrimary: _getCurrentLocation,
          primaryOutlined: true,
          secondaryLabel: 'Pin on map',
          onSecondary: _pinOnMap,
        );
      case _LocationIssue.permissionDenied:
      case _LocationIssue.permissionBlocked:
        return _IssueCard(
          isDark: isDark,
          icon: Icons.shield_outlined,
          iconColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          title: 'Location permission denied',
          message: _savedAddresses.isNotEmpty
              ? 'You can still pick a saved address or search.'
              : 'You can still search for your area.',
          inlineActionLabel: 'Allow',
          onInlineAction: _issue == _LocationIssue.permissionBlocked
              ? _openBlockedPermissionSheet
              : _getCurrentLocation,
        );
      case _LocationIssue.none:
        return const SizedBox.shrink();
    }
  }
}

// -----------------------------------------------------------------------------
// Building blocks
// -----------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _Card({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
      ),
      child: Text(
        'Selected',
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PillButton({required this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _IconTile({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _Row extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onTap;
  final Widget leading;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;

  const _Row({
    required this.isDark,
    required this.onTap,
    required this.leading,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.padding,
          vertical: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            leading,
            SizedBox(width: AppSizes.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppSizes.spaceS),
              trailing!,
            ] else if (showChevron) ...[
              SizedBox(width: AppSizes.spaceS),
              Icon(Icons.chevron_right, size: 20, color: textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

/// A problem card with either two buttons or an inline text action (Figma 21d).
class _IssueCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryOutlined;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? inlineActionLabel;
  final VoidCallback? onInlineAction;

  const _IssueCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.primaryOutlined = false,
    this.secondaryLabel,
    this.onSecondary,
    this.inlineActionLabel,
    this.onInlineAction,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return _Card(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _IconTile(
                  icon: icon,
                  color: iconColor,
                  background: iconColor.withValues(alpha: 0.12),
                ),
                SizedBox(width: AppSizes.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (inlineActionLabel != null)
                  TextButton(
                    onPressed: onInlineAction,
                    child: Text(
                      inlineActionLabel!,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PermissionColors.accent(isDark),
                      ),
                    ),
                  ),
              ],
            ),
            if (primaryLabel != null && secondaryLabel != null) ...[
              SizedBox(height: AppSizes.spaceM),
              Row(
                children: [
                  Expanded(
                    child: primaryOutlined
                        ? PermissionSecondaryButton(
                            label: primaryLabel!,
                            onPressed: onPrimary,
                            height: 40,
                          )
                        : PermissionPrimaryButton(
                            label: primaryLabel!,
                            onPressed: onPrimary,
                            height: 40,
                          ),
                  ),
                  SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: PermissionSecondaryButton(
                      label: secondaryLabel!,
                      onPressed: onSecondary,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
