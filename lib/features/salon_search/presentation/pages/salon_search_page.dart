import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/home/presentation/widgets/filter_badges.dart';
import 'package:tressy/features/salon_search/presentation/widgets/salon_search_card.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class SalonSearchPage extends StatefulWidget {
  const SalonSearchPage({super.key});

  @override
  State<SalonSearchPage> createState() => _SalonSearchPageState();
}

class _SalonSearchPageState extends State<SalonSearchPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _draggableController = DraggableScrollableController();
  final Set<Marker> _markers = {};

  CameraPosition? _initialPosition;

  // Sample salon data with Chennai-based locations
  final List<Map<String, dynamic>> _salonData = [
    {
      'name': 'Glam Studio & Spa',
      'image': 'https://images.unsplash.com/photo-1560066984-138dadb4c035',
      'imageUrl': 'https://images.unsplash.com/photo-1560066984-138dadb4c035',
      'rating': 4.8,
      'reviewCount': 245,
      'distance': 0.8,
      'isPremium': true,
      'isFavorite': false,
      'serviceName': 'Haircut',
      'servicePrice': 299.0,
      'address': '123 Beauty Street, Downtown',
      'categories': ['Hair', 'Spa', 'Makeup'],
      'languageCodes': ['en', 'hi', 'ta'],
    },
    {
      'name': 'Men\'s Grooming Lounge',
      'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70',
      'imageUrl': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70',
      'rating': 4.6,
      'reviewCount': 189,
      'distance': 1.2,
      'isPremium': false,
      'isFavorite': true,
      'serviceName': 'Beard Trim',
      'servicePrice': 149.0,
      'address': '456 Groom Avenue, City Center',
      'categories': ['Haircut', 'Beard', 'Facial'],
      'languageCodes': ['en', 'ml'],
    },
    {
      'name': 'Luxury Unisex Salon',
      'image': 'https://images.unsplash.com/photo-1562322140-8baeececf3df',
      'imageUrl': 'https://images.unsplash.com/photo-1562322140-8baeececf3df',
      'rating': 4.9,
      'reviewCount': 320,
      'distance': 1.5,
      'isPremium': true,
      'isFavorite': false,
      'serviceName': 'Full Service',
      'servicePrice': 599.0,
      'address': '789 Style Road, Fashion District',
      'categories': ['Hair', 'Spa', 'Nails', 'Makeup'],
      'languageCodes': ['en', 'gu', 'hi'],
    },
    {
      'name': 'Classic Barber Shop',
      'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
      'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
      'rating': 4.7,
      'reviewCount': 156,
      'distance': 2.0,
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Haircut',
      'servicePrice': 199.0,
      'address': '321 Main Street, Old Town',
      'categories': ['Haircut', 'Shave'],
      'languageCodes': ['en', 'kn'],
    },
    {
      'name': 'Beauty Paradise Salon',
      'image': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',
      'imageUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e',
      'rating': 4.5,
      'reviewCount': 98,
      'distance': 2.3,
      'isPremium': false,
      'isFavorite': true,
      'serviceName': 'Manicure',
      'servicePrice': 249.0,
      'address': '654 Beauty Lane, Suburb',
      'categories': ['Nails', 'Spa', 'Waxing'],
      'languageCodes': ['en', 'te', 'hi'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _getCurrentLocation();
    _createMarkers();
  }

  void _initializeLocation() {
    final locationProvider = context.read<LocationProvider>();
    _initialPosition = CameraPosition(
      target: LatLng(locationProvider.latitude, locationProvider.longitude),
      zoom: 15.0,
    );
  }

  Future<void> _createMarkers() async {
    // Chennai-based salon locations - focused around 13.038, 80.22292
    final salonLocations = [
      {'name': 'Glam Studio & Spa', 'lat': 13.038, 'lng': 80.22292},
      {'name': 'Men\'s Grooming Lounge', 'lat': 13.0395, 'lng': 80.2245},
      {'name': 'Luxury Unisex Salon', 'lat': 13.0365, 'lng': 80.2215},
      {'name': 'Classic Barber Shop', 'lat': 13.0405, 'lng': 80.2250},
      {'name': 'Beauty Paradise Salon', 'lat': 13.0355, 'lng': 80.2200},
    ];

    final markers = <Marker>{};
    
    for (var i = 0; i < salonLocations.length; i++) {
      final location = salonLocations[i];
      final salon = _salonData[i];
      
      // Create custom marker icon with salon image
      final BitmapDescriptor markerIcon = await _createCustomMarkerIcon(
        salon['imageUrl'],
        salon['isPremium'],
      );
      
      markers.add(
        Marker(
          markerId: MarkerId('salon_$i'),
          position: LatLng(location['lat'] as double, location['lng'] as double),
          infoWindow: InfoWindow(
            title: location['name'] as String,
            snippet: '${salon['rating']} ⭐ • ${salon['distance']} km',
          ),
          icon: markerIcon,
          onTap: () {
            // Handle marker tap - could show salon details or scroll to card
            debugPrint('Tapped marker: ${location['name']}');
          },
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(
    String imageUrl,
    bool isPremium,
  ) async {
    try {
      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List imageBytes = response.bodyBytes;
      
      // Decode the image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 120,
        targetHeight: 120,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      // Create a canvas to draw the custom marker
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final circleSize = 30.0; // Increased from 80
      final borderWidth = 1.0; // Increased border
      final dotHeight = 20.0; // Height of the pointer dot
      final totalHeight = circleSize + dotHeight;
      
      // Draw white background circle (border effect)
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(circleSize / 2, circleSize / 2),
        circleSize / 2,
        backgroundPaint,
      );
      
      // Draw primary color border
      final borderPaint = Paint()
        ..color = const Color.fromARGB(255, 9, 9, 9) // Primary color
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawCircle(
        Offset(circleSize / 2, circleSize / 2),
        circleSize / 2 - borderWidth / 2,
        borderPaint,
      );
      
      // Save canvas state before clipping
      canvas.save();
      
      // Clip to circle and draw the salon image
      final clipPath = Path()
        ..addOval(Rect.fromCircle(
          center: Offset(circleSize / 2, circleSize / 2),
          radius: circleSize / 2 - borderWidth,
        ));
      canvas.clipPath(clipPath);
      
      // Draw the image
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
          borderWidth,
          borderWidth,
          circleSize - borderWidth * 2,
          circleSize - borderWidth * 2,
        ),
        image: image,
        fit: BoxFit.cover,
      );
      
      // Restore canvas state
      canvas.restore();
      
      // Draw pointer dot below the circle
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      // Draw white dot shadow/background
      canvas.drawCircle(
        Offset(circleSize / 2, circleSize + dotHeight / 2),
        8.0,
        dotPaint,
      );
      
      // Draw colored dot (always primary color)
      final coloredDotPaint = Paint()
        ..color = const Color.fromARGB(255, 9, 9, 9) // Primary color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(circleSize / 2, circleSize + dotHeight / 2),
        6.0,
        coloredDotPaint,
      );
      
      // Convert canvas to image
      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(circleSize.toInt(), totalHeight.toInt());
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      return BitmapDescriptor.bytes(pngBytes);
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
      // Fallback to default marker
      return BitmapDescriptor.defaultMarkerWithHue(
        isPremium ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Update LocationProvider with current GPS location
      // Silent update (no toast) for GPS location
      await locationProvider.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        silent: true, // Don't show toast for GPS updates
      );

      // Update initial position and move camera
      final newPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      );

      if (mounted) {
        setState(() {
          _initialPosition = newPosition;
        });

        // Move camera if map is already created
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(newPosition),
        );
      }
    } catch (e) {
      // Handle error silently, use location from LocationProvider
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Google Map
            if (_initialPosition != null)
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialPosition!,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                compassEnabled: true,
              ),
        
            // Back button overlay
            Positioned(
              top: AppSizes.paddingM,
              left: AppSizes.paddingM,
              right: AppSizes.paddingM,
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: AppSizes.iconXXL,
                        height: AppSizes.iconXXL,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? AppColors.surfaceDark : AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceM),
                    Expanded(child: _buildSearchInput(context))
                    // _buildSearchInput(context)
                  ],
                ),
              ),
            ),
        
            // Search input field
            
            // Draggable Bottom Sheet
            _buildDraggableBottomSheet(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDraggableBottomSheet(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusL),
              topRight: Radius.circular(AppSizes.radiusL),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppSizes.paddingM, bottom: AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Filter badges
              FilterBadges(
                initialGender: 'all',
                onGenderSelected: (gender) {
                  // Handle gender filter selection
                  debugPrint('Selected gender: $gender');
                },
              ),
              // Salons count text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '500 Salons Nearby',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
                  itemCount: _salonData.length,
                  itemBuilder: (context, index) {
                    final salon = _salonData[index];
                    return SalonSearchCard(
                      salonName: salon['name'],
                      salonImage: salon['image'],
                      imageUrl: salon['imageUrl'],
                      rating: salon['rating'],
                      reviewCount: salon['reviewCount'],
                      distance: salon['distance'],
                      isPremium: salon['isPremium'],
                      isFavorite: salon['isFavorite'],
                      serviceName: salon['serviceName'],
                      servicePrice: salon['servicePrice'],
                      address: salon['address'],
                      categories: salon['categories'] != null
                          ? List<String>.from(salon['categories'])
                          : null,
                      languageCodes: salon['languageCodes'] != null
                          ? List<String>.from(salon['languageCodes'])
                          : null,
                      onTap: () {
                        // Navigate to salon details
                        debugPrint('Tapped on ${salon['name']}');
                      },
                      onFavoriteToggle: () {
                        // Handle favorite toggle
                        debugPrint('Toggled favorite for ${salon['name']}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInput(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.icSearch,
            width: AppSizes.iconS,
            height: AppSizes.iconS,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for salons, parlors, or massages...',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              style: context.textTheme.bodyLarge,
              onChanged: (value) {
                // Handle search
              },
            ),
          ),
        ],
      ),
    );
  }
}
