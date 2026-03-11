import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/home/presentation/widgets/filter_badges.dart';
import 'package:tressy/features/salon_search/presentation/widgets/salon_search_card.dart';
import 'package:tressy/features/salon_search/presentation/widgets/search_shimmer.dart';
import 'package:tressy/features/salon_search/presentation/widgets/map_marker_manager.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_bloc.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_event.dart';
import 'package:tressy/features/salon_search/presentation/bloc/search_state.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_bloc.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_event.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_state.dart';
import 'dart:async';

class SalonSearchPage extends StatelessWidget {
  const SalonSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // SearchBloc - ONLY for bottom sheet salon list
        BlocProvider<SearchBloc>(
          create: (context) => sl<SearchBloc>(),
        ),
        // MapMarkersBloc - ONLY for map markers
        BlocProvider<MapMarkersBloc>(
          create: (context) => sl<MapMarkersBloc>(),
        ),
      ],
      child: const _SalonSearchPageContent(),
    );
  }
}

class _SalonSearchPageContent extends StatefulWidget {
  const _SalonSearchPageContent();

  @override
  State<_SalonSearchPageContent> createState() =>
      _SalonSearchPageContentState();
}

class _SalonSearchPageContentState extends State<_SalonSearchPageContent> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final Set<Marker> _markers = {};
  String _selectedGender = 'all';

  // Map marker management
  final MapMarkerManager _markerManager = MapMarkerManager();
  Timer? _debounceTimer;
  bool _isLoadingMarkers = false;

  CameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _getCurrentLocation();
    _loadNearbySalons();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _markerManager.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeLocation() {
    final locationProvider = context.read<LocationProvider>();
    _initialPosition = CameraPosition(
      target: LatLng(locationProvider.latitude, locationProvider.longitude),
      zoom: 12.0,
    );
  }

  void _loadNearbySalons() {
    final locationProvider = context.read<LocationProvider>();
    context.read<SearchBloc>().add(
          LoadNearbySalonsEvent(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
            gender: _selectedGender == 'all' ? null : _selectedGender,
          ),
        );
  }

  /// Load map markers based on current camera position (with debouncing)
  void _onCameraMove(CameraPosition position) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set new timer - only trigger after user stops moving for 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadMapMarkersForCurrentView();
    });
  }

  /// Called when camera movement stops
  void _onCameraIdle() {
    // Ensure we load markers when camera is idle
    _loadMapMarkersForCurrentView();
  }

  /// Load map markers for current visible region
  Future<void> _loadMapMarkersForCurrentView() async {
    if (_mapController == null || _isLoadingMarkers) return;

    try {
      _isLoadingMarkers = true;

      // Get visible region
      final bounds = await _mapController!.getVisibleRegion();
      final zoom = await _mapController!.getZoomLevel();

      // Only load markers if zoom level is reasonable (not too far out)
      if (zoom < 8) {
        debugPrint('Zoom too far out, skipping marker load');
        return;
      }

      // Trigger map markers event to MapMarkersBloc (separate!)
      if (mounted) {
        context.read<MapMarkersBloc>().add(
              LoadMapMarkersEvent(
                northEastLat: bounds.northeast.latitude,
                northEastLng: bounds.northeast.longitude,
                southWestLat: bounds.southwest.latitude,
                southWestLng: bounds.southwest.longitude,
                zoom: zoom.round(),
                gender: _selectedGender == 'all' ? null : _selectedGender,
              ),
            );
      }
    } catch (e) {
      debugPrint('Error loading map markers: $e');
    } finally {
      _isLoadingMarkers = false;
    }
  }

  /// Handle cluster tap - zoom in to show individual markers
  void _onClusterTap(dynamic cluster) {
    if (_mapController == null) return;

    // Calculate center of cluster bounds
    final centerLat =
        (cluster.bounds.northEastLat + cluster.bounds.southWestLat) / 2;
    final centerLng =
        (cluster.bounds.northEastLng + cluster.bounds.southWestLng) / 2;

    // Zoom in to show individual salons
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(centerLat, centerLng),
          zoom: 15, // Higher zoom to break cluster into individual markers
        ),
      ),
    );
  }

  /// Handle individual marker tap - navigate to salon details
  void _onMarkerTap(int salonId) {
    debugPrint('Tapped salon marker: $salonId');
  }

  /// Update map markers from MapMarkersLoaded state
  Future<void> _updateMapMarkersFromState(MapMarkersLoaded state) async {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    Set<Marker> newMarkers = {};

    try {
      // RULE: zoom < 14 → Show ONLY clusters (hide individual markers)
      //       zoom >= 14 → Show ONLY individual markers (hide clusters)

      if (state.zoom < 14) {
        // Zoomed out - prefer clusters, fallback to markers if no clusters
        if (state.clusters.isNotEmpty) {
          final clusterMarkers = await _markerManager.createClusterMarkers(
            clusters: state.clusters,
            isDarkMode: isDarkMode,
            onClusterTap: _onClusterTap,
          );
          newMarkers.addAll(clusterMarkers);
        } else if (state.markers.isNotEmpty) {
          final individualMarkers =
              await _markerManager.createIndividualMarkers(
            markers: state.markers,
            isDarkMode: isDarkMode,
            onMarkerTap: _onMarkerTap,
          );
          newMarkers.addAll(individualMarkers);
        }
      } else {
        // Zoomed in - show ONLY individual markers
        if (state.markers.isNotEmpty) {
          final individualMarkers =
              await _markerManager.createIndividualMarkers(
            markers: state.markers,
            isDarkMode: isDarkMode,
            onMarkerTap: _onMarkerTap,
          );
          newMarkers.addAll(individualMarkers);
        } else {
          debugPrint(
              'Zoom ${state.zoom} >= 14 but no individual markers from backend');
        }
      }

      if (newMarkers.isEmpty) {
        debugPrint(
            'No markers to show: zoom=${state.zoom}, clusters=${state.clusters.length}, markers=${state.markers.length}');
      }

      // Update markers on map
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      debugPrint('❌ Error updating map markers: $e');
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocListener<MapMarkersBloc, MapMarkersState>(
      listener: (context, state) {
        if (state is MapMarkersLoaded) {
          _updateMapMarkersFromState(state);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
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
                        onTap: () => GoRouter.of(context).pop(),
                        child: Container(
                          width: AppSizes.iconXXL,
                          height: AppSizes.iconXXL,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.white,
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
            color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
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
                  margin: const EdgeInsets.only(
                      top: AppSizes.paddingM, bottom: AppSizes.paddingS),
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
                initialGender: _selectedGender,
                onGenderSelected: (gender) {
                  setState(() {
                    _selectedGender = gender;
                  });

                  final locationProvider = context.read<LocationProvider>();

                  // Update salon list in bottom sheet
                  context.read<SearchBloc>().add(
                        ApplyFiltersEvent(
                          latitude: locationProvider.latitude,
                          longitude: locationProvider.longitude,
                          gender: gender == 'all' ? null : gender,
                        ),
                      );

                  // Also update map markers with filter
                  _loadMapMarkersForCurrentView();
                },
              ),
              // Scrollable content with BlocBuilder
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  buildWhen: (previous, current) {
                    // Only rebuild for salon list states, ignore map marker states
                    return current is SearchInitial ||
                        current is SearchLoading ||
                        current is SearchLoaded ||
                        current is SearchEmpty ||
                        current is SearchFailure ||
                        current is SearchLoadingMore;
                  },
                  builder: (context, state) {
                    // Salons count text
                    Widget countWidget = const SizedBox.shrink();

                    if (state is SearchLoaded) {
                      countWidget = Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingL,
                          vertical: AppSizes.paddingM,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${state.salons.length} Salons ${state.isSearchActive ? "Found" : "Nearby"}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        countWidget,
                        Expanded(
                          child: _buildContent(
                              state, scrollController, isDarkMode),
                        ),
                      ],
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

  Widget _buildContent(
      SearchState state, ScrollController scrollController, bool isDarkMode) {
    if (state is SearchLoading) {
      return SearchShimmer(isDarkMode: isDarkMode);
    } else if (state is SearchLoaded) {
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
        itemCount: state.salons.length,
        itemBuilder: (context, index) {
        
          final salon = state.salons[index];
          return SalonSearchCard(
            salonName: salon.salonName,
            salonImage: salon.salonImage,
            imageUrl: salon.images.first,
            rating: salon.rating,
            reviewCount: salon.reviewCount,
            distance: salon.distance,
            isPremium: salon.isPremium,
            isFavorite: salon.isFavorite,
            serviceName: salon.serviceName,
            servicePrice: salon.servicePrice,
            address: salon.address,
            categories: salon.categories,
            languageCodes: salon.languageCodes,
            onTap: () {
              GoRouter.of(context).push(
                RouteNames.salonDetails,
                extra: {
                  'salonId': salon.id,
                  'salonName': salon.salonName,
                },
              );
              // Navigate to salon details
            },
            onFavoriteToggle: () {
              // Handle favorite toggle
              debugPrint('Toggled favorite for ${salon.salonName}');
            },
          );
        },
      );
    } else if (state is SearchEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Text(
            state.message,
            style: context.textTheme.bodyLarge?.copyWith(
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (state is SearchFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                state.message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
                if (value.trim().isEmpty) {
                  // Clear search and reload nearby salons
                  context.read<SearchBloc>().add(const ClearSearchEvent());
                } else {
                  // Trigger search
                  final locationProvider = context.read<LocationProvider>();
                  context.read<SearchBloc>().add(
                        SearchSalonsEvent(
                          latitude: locationProvider.latitude,
                          longitude: locationProvider.longitude,
                          query: value.trim(),
                          gender:
                              _selectedGender == 'all' ? null : _selectedGender,
                        ),
                      );
                }
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const ClearSearchEvent());
              },
              child: Icon(
                Icons.clear,
                size: AppSizes.iconS,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
