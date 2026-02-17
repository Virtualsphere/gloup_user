import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';
import 'package:tressy/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/salon_card.dart';

class SalonSearchPage extends StatefulWidget {
  const SalonSearchPage({super.key});

  @override
  State<SalonSearchPage> createState() => _SalonSearchPageState();
}

class _SalonSearchPageState extends State<SalonSearchPage> {
  late GoogleMapController mapController;

  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // Method to get current location
  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      double lat = position.latitude;
      double long = position.longitude;

      LatLng location = LatLng(lat, long);

      setState(() {
        _currentPosition = location;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _currentPosition = null;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map (Bottom Layer)
                _currentPosition != null ?
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 16.0,
                  ),
                ) :
                Text("Unable to track location", style: TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),),

                // Search Bar (Top Layer)
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: SearchBarWidget(),
                ),

                _buildDraggableSheet()
              ],
            ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.2, // Initial height (25% of screen)
      minChildSize: 0.2, // Minimum height
      maxChildSize: 0.5, // Maximum height (Half screen)
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              /// Drag Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),


              /// Scrollable Content
              Expanded(
                  child: ListView(
                controller: scrollController,
                children: [
                  _buildFilters(),
                  AppSizes.heightM,
                  BlocProvider(
                    create: (context) => sl<HomeBloc>()
                      ..add(const LoadAllHomeDataEvent(
                        latitude: 19.0760,
                        longitude: 72.8777,
                      )),
                    child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                      return SizedBox(
                        height: 300,
                        child: state.isPopularServicesLoading
                            ? HomeShimmers.buildSalonCardsShimmer(context)
                            : state.popularServices.isEmpty
                                ? const Center(
                                    child: Text('No popular services found'))
                                : ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingM),
                                    itemCount: state.popularServices.length,
                                    itemBuilder: (context, index) {
                                      final salon =
                                          state.popularServices[index];
                                      return Padding(
                                        padding: AppSizes.paddingAllM,
                                        child: SalonCard(
                                          salonName: salon.salonName,
                                          salonImage: salon.salonImage,
                                          images: salon.images,
                                          rating: salon.rating,
                                          reviewCount: salon.reviewCount,
                                          distance: salon.distance,
                                          isPremium: salon.isPremium,
                                          isFavorite: salon.isFavorite,
                                          serviceName: salon.serviceName,
                                          servicePrice: salon.servicePrice,
                                          categories: salon.categories,
                                          languageCodes: salon.languageCodes,
                                          onTap: () {
                                          },
                                        ),
                                      );
                                    },
                                  ),
                      );
                    }),
                  ),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  // Filters
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDropdownChip("Price"),
          AppSizes.widthM,
          _buildDropdownChip("Type"),
        ],
      ),
    );
  }

  // Dropdown chip
  Widget _buildDropdownChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          AppSizes.widthS,
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black,),
        ],
      ),
    );
  }
}