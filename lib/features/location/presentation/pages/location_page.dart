import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  
  // Google Places API Key
  static const String _googlePlacesApiKey = 'AIzaSyBACvmG9-ekKRhJYRhSTVa7Et10IArFzUs';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Add listener to rebuild UI when search text changes
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
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
          
          // Build full address
          String fullAddress = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            fullAddress = place.subLocality!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty ? place.locality! : ', ${place.locality!}';
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea!}';
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            fullAddress += ' - ${place.postalCode!}';
          }
          
          setState(() {
            _currentCity = place.locality ?? place.administrativeArea ?? 'Unknown';
            _currentArea = place.subLocality ?? place.thoroughfare ?? '';
            _currentFullAddress = fullAddress.isEmpty ? 'Unknown Location' : fullAddress;
            _isLoadingLocation = false;
          });
          
          // Load nearby locations
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
      // Use Google Places Nearby Search API to get real nearby locations
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000' // 5km radius
        '&type=locality' // Get nearby localities/neighborhoods
        '&key=$_googlePlacesApiKey'
      );

      debugPrint('Fetching nearby locations from Google Places API...');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          
          debugPrint('Found ${results.length} nearby locations');
          
          List<Map<String, dynamic>> locations = [];
          
          for (var i = 0; i < results.length && i < 10; i++) {
            final place = results[i];
            
            // Calculate distance from current location
            final placeLat = place['geometry']['location']['lat'];
            final placeLng = place['geometry']['location']['lng'];
            
            final distance = Geolocator.distanceBetween(
              lat,
              lng,
              placeLat,
              placeLng,
            );
            
            final distanceInKm = (distance / 1000).toStringAsFixed(1);
            
            // Get full address
            String fullAddress = place['vicinity'] ?? place['name'] ?? '';
            
            locations.add({
              'name': place['name'] ?? 'Unknown',
              'area': place['vicinity'] ?? '',
              'fullAddress': fullAddress,
              'distance': '$distanceInKm km away',
              'latitude': placeLat,
              'longitude': placeLng,
            });
          }
          
          // Sort by distance
          locations.sort((a, b) {
            final distA = double.parse(a['distance'].toString().replaceAll(' km away', ''));
            final distB = double.parse(b['distance'].toString().replaceAll(' km away', ''));
            return distA.compareTo(distB);
          });
          
          if (mounted) {
            setState(() {
              _nearbyLocations = locations;
            });
          }
          
          debugPrint('Successfully loaded ${locations.length} nearby locations');
        } else {
          debugPrint('Google Places API returned status: ${data['status']}');
          // Fallback to geocoding-based locations
          _loadFallbackNearbyLocations(lat, lng);
        }
      } else {
        debugPrint('Failed to fetch nearby locations: ${response.statusCode}');
        // Fallback to geocoding-based locations
        _loadFallbackNearbyLocations(lat, lng);
      }
    } catch (e) {
      debugPrint('Error loading nearby locations: $e');
      // Fallback to geocoding-based locations
      _loadFallbackNearbyLocations(lat, lng);
    }
  }

  // Fallback method if Google Places API fails
  Future<void> _loadFallbackNearbyLocations(double lat, double lng) async {
    // Generate nearby locations using geocoding
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

    // Get address for each nearby location
    for (var i = 0; i < _nearbyLocations.length; i++) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _nearbyLocations[i]['latitude'],
          _nearbyLocations[i]['longitude'],
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          // Build full address
          String fullAddress = '';
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            fullAddress = place.subLocality!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty ? place.locality! : ', ${place.locality!}';
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            fullAddress += fullAddress.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea!}';
          }
          
          setState(() {
            _nearbyLocations[i]['name'] = 
                place.subLocality ?? place.locality ?? place.administrativeArea ?? 'Location ${i + 1}';
            _nearbyLocations[i]['area'] = place.locality ?? '';
            _nearbyLocations[i]['fullAddress'] = fullAddress.isEmpty ? 'Unknown Location' : fullAddress;
          });
        }
      } catch (e) {
        debugPrint('Error getting nearby location address: $e');
      }
    }
  }

  // Handle place selection from Google Places
  void _handlePlaceSelection(Prediction prediction) async {
    if (prediction.lat == null || prediction.lng == null) {
      return;
    }

    try {
      final lat = double.parse(prediction.lat!);
      final lng = double.parse(prediction.lng!);
      
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        
        // Navigate back with selected location
        Navigator.pop(context, {
          'city': place.locality ?? place.administrativeArea ?? '',
          'area': place.subLocality ?? prediction.description ?? '',
          'latitude': lat,
          'longitude': lng,
        });
      }
    } catch (e) {
      debugPrint('Error handling place selection: $e');
    }
  }

  // Extract main name from full address
  String _extractMainName(String fullAddress) {
    if (fullAddress.isEmpty) return '';
    final parts = fullAddress.split(',');
    return parts.first.trim();
  }

  // Build prediction card widget
  Widget _buildPredictionCard(BuildContext context, Prediction prediction, bool isDarkMode) {
    // Calculate distance if current location is available
    String? distance;
    if (_currentLatitude != null && 
        _currentLongitude != null && 
        prediction.lat != null && 
        prediction.lng != null) {
      try {
        final searchLat = double.parse(prediction.lat!);
        final searchLng = double.parse(prediction.lng!);
        final distanceInMeters = Geolocator.distanceBetween(
          _currentLatitude!,
          _currentLongitude!,
          searchLat,
          searchLng,
        );
        final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(1);
        distance = '$distanceInKm km away';
      } catch (e) {
        debugPrint('Error calculating distance: $e');
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
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
            padding: const EdgeInsets.all(AppSizes.paddingS),
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
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _extractMainName(prediction.description ?? ''),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  prediction.description ?? '',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (distance != null) ...[
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
                        distance,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

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
            color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
          // Google Places Search Field with Card-Style Results
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: _googlePlacesApiKey,
              inputDecoration: InputDecoration(
                hintText: 'Search for area, street name...',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.textHintDark : AppColors.textHint,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
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
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingM,
                ),
              ),
              debounceTime: 400,
              countries: const ["in"],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _handlePlaceSelection(prediction);
              },
              itemClick: (Prediction prediction) {
                _handlePlaceSelection(prediction);
              },
              seperatedBuilder: const SizedBox(height: AppSizes.spaceS),
              // Show search results in card style with "Use Current Location" as first item
              itemBuilder: (context, index, Prediction prediction) {
                // Show "Use Current Location" card as the very first item (index 0)
                if (index == 0) {
                  return Column(
                    children: [
                      // Add spacing between search input and predictions
                      const SizedBox(height: AppSizes.spaceM),
                      // "Use Current Location" card
                      InkWell(
                        onTap: _isLoadingLocation
                            ? null
                            : () {
                                if (_currentLatitude != null && _currentLongitude != null) {
                                  Navigator.pop(context, {
                                    'city': _currentCity,
                                    'area': _currentArea,
                                    'latitude': _currentLatitude,
                                    'longitude': _currentLongitude,
                                  });
                                }
                              },
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: AppSizes.spaceM),
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
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceM),
                      // First prediction result
                      _buildPredictionCard(context, prediction, isDarkMode),
                    ],
                  );
                }
                
                // For all other items, just show the prediction card
                return _buildPredictionCard(context, prediction, isDarkMode);
              },
              // Only show the widget when searching
              isCrossBtnShown: false,
            ),
          ),

          // Show current location and nearby when not searching
          if (_searchController.text.isEmpty) ...[
            // Current Location Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: InkWell(
                onTap: _isLoadingLocation
                    ? null
                    : () {
                        if (_currentLatitude != null && _currentLongitude != null) {
                          Navigator.pop(context, {
                            'city': _currentCity,
                            'area': _currentArea,
                            'latitude': _currentLatitude,
                            'longitude': _currentLongitude,
                          });
                        }
                      },
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppSizes.spaceM),
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
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceL),

            // Nearby Locations
            if (_nearbyLocations.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Text(
                  'Nearby Locations',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
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

  Widget _buildLocationCard(
    BuildContext context,
    Map<String, dynamic> location,
    bool isDarkMode, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.pop(context, {
            'city': location['name'],
            'area': location['area'] ?? '',
            'latitude': location['latitude'],
            'longitude': location['longitude'],
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
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
              padding: const EdgeInsets.all(AppSizes.paddingS),
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
            const SizedBox(width: AppSizes.spaceM),
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
