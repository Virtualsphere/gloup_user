import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/utils/app_logger.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingLocation = false;
  String _currentCity = '';
  String _currentArea = '';
  String _currentFullAddress = '';
  double? _currentLatitude;
  double? _currentLongitude;

  // Nearby locations
  List<Map<String, dynamic>> _nearbyLocations = [];

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
    _getCurrentLocation();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

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
          setState(() {
            _isLoadingLocation = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
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

  Widget _buildPredictionCard(
      BuildContext context, Map<String, dynamic> prediction, bool isDarkMode) {
    final description = prediction['description'] as String? ?? '';
    final mainText =
        (prediction['structured_formatting']?['main_text'] as String?) ??
            _extractMainName(description);

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.surfaceDark.withValues(alpha: 0.5)
                  : AppColors.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Icon(
              Icons.location_on,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
          SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color:
                isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Select Location',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderWidthThin,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingL),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for area, street name...',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color:
                      isDarkMode ? AppColors.textHintDark : AppColors.textHint,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDarkMode
                    ? AppColors.surfaceDark
                    : AppColors.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: AppColors.border,
                    width: AppSizes.borderWidthThin,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: context.onSurfaceEmphasis,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
          ),

          // Search results
          if (isSearching) ...[
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                itemCount: _predictions.length + 1,
                separatorBuilder: (_, __) => SizedBox(height: AppSizes.spaceS),
                itemBuilder: (context, index) {
                  // First item: "Use current location"
                  if (index == 0) {
                    return InkWell(
                      onTap: _isLoadingLocation
                          ? null
                          : () {
                              if (_currentLatitude != null &&
                                  _currentLongitude != null) {
                                Navigator.pop(context, {
                                  'city': _currentCity,
                                  'area': _currentArea,
                                  'latitude': _currentLatitude,
                                  'longitude': _currentLongitude,
                                });
                              }
                            },
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      child: _buildCurrentLocationCard(context, isDarkMode),
                    );
                  }

                  final prediction = _predictions[index - 1];
                  return InkWell(
                    onTap: () => _handlePredictionTap(prediction),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child:
                        _buildPredictionCard(context, prediction, isDarkMode),
                  );
                },
              ),
            ),
          ] else ...[
            // Current Location Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: InkWell(
                onTap: _isLoadingLocation
                    ? null
                    : () {
                        if (_currentLatitude != null &&
                            _currentLongitude != null) {
                          Navigator.pop(context, {
                            'city': _currentCity,
                            'area': _currentArea,
                            'latitude': _currentLatitude,
                            'longitude': _currentLongitude,
                          });
                        }
                      },
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: _buildCurrentLocationCard(context, isDarkMode),
              ),
            ),

            SizedBox(height: AppSizes.spaceL),

            // Nearby Locations
            if (_nearbyLocations.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Text(
                  'Nearby Locations',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.spaceM),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                  itemCount: _nearbyLocations.length,
                  itemBuilder: (context, index) {
                    final location = _nearbyLocations[index];
                    return _buildLocationCard(context, location, isDarkMode);
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentLocationCard(BuildContext context, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: context.onSurfaceEmphasis,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.white, size: 24),
          SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use current location',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoadingLocation)
                  Text(
                    'Getting your location...',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  )
                else if (_currentFullAddress.isNotEmpty)
                  Text(
                    _currentFullAddress,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    Map<String, dynamic> location,
    bool isDarkMode, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spaceM),
      child: InkWell(
        onTap: onTap ??
            () {
              Navigator.pop(context, {
                'city': location['name'],
                'area': location['area'] ?? '',
                'latitude': location['latitude'],
                'longitude': location['longitude'],
              });
            },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.surfaceDark.withValues(alpha: 0.5)
                      : AppColors.surface.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.location_on,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location['name'] ?? '',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (location['fullAddress'] != null) ...[
                      Text(
                        location['fullAddress'],
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (location['distance'] != null) ...[
                      if (location['fullAddress'] != null)
                        const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.navigation,
                            size: 12,
                            color: isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location['distance'],
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
