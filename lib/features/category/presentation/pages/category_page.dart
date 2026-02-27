import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/features/category/presentation/widgets/category_shimmers.dart';
import 'package:tressy/features/home/presentation/widgets/category_section.dart';
import 'package:tressy/shared/widgets/salon_card.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CategoryPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryIndex;

  const CategoryPage({
    super.key,
    this.categoryName,
    this.categoryIndex,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late int _selectedCategoryIndex;
  late String _selectedCategoryName;
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Location
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _locationLoaded = false;

  // Search debounce
  Timer? _debounceTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.categoryIndex ?? 1;
    _selectedCategoryName = widget.categoryName ?? 'Haircut';
    // Don't set _selectedCategoryId here - will be set from CategoryBloc
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Create new timer (500ms debounce)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        _searchQuery = query;
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    if (_selectedCategoryId != null && _locationLoaded) {
      context.read<CategoryBloc>().add(LoadCategorySalonsEvent(
        latitude: _latitude,
        longitude: _longitude,
        categoryId: _selectedCategoryId!,
        limit: 10,
        page: 1,
        search: query.isEmpty ? null : query,
      ));
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use default location if service is disabled
        _latitude = 13.0827;
        _longitude = 80.2707;
        setState(() => _locationLoaded = true);
        _loadInitialCategorySalons();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Use default location
          _latitude = 13.0827;
          _longitude = 80.2707;
          setState(() => _locationLoaded = true);
          _loadInitialCategorySalons();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoaded = true;
      });
      _loadInitialCategorySalons();
    } catch (e) {
      // Use default location on error
      _latitude = 13.0827;
      _longitude = 80.2707;
      setState(() => _locationLoaded = true);
      _loadInitialCategorySalons();
    }
  }

  void _loadInitialCategorySalons() {
    // Get category ID from CategoryBloc state
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState.categories.isNotEmpty && _selectedCategoryIndex < categoryState.categories.length) {
      final category = categoryState.categories[_selectedCategoryIndex];
      _selectedCategoryId = category.id;
      
      // Load salons for the initial category
      context.read<CategoryBloc>().add(LoadCategorySalonsEvent(
        latitude: _latitude,
        longitude: _longitude,
        categoryId: _selectedCategoryId!,
        limit: 10,
        page: 1,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ));
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScroll - currentScroll <= 200 && _selectedCategoryId != null && _locationLoaded) {
      // Trigger load more with search query
      context.read<CategoryBloc>().add(LoadCategorySalonsEvent(
        latitude: _latitude,
        longitude: _longitude,
        categoryId: _selectedCategoryId!,
        limit: 10,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        isLoadMore: true,
      ));
    }
  }

  void _onCategoryTap(String categoryName, int categoryIndex, String categoryId) {
    setState(() {
      _selectedCategoryIndex = categoryIndex;
      _selectedCategoryName = categoryName;
      _selectedCategoryId = categoryId;
    });

    // Load salons for selected category with search query
    if (_locationLoaded && _selectedCategoryId != null) {
      context.read<CategoryBloc>().add(LoadCategorySalonsEvent(
        latitude: _latitude,
        longitude: _longitude,
        categoryId: _selectedCategoryId!,
        limit: 10,
        page: 1,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ));
    }
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
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: AppSizes.iconM,
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.spaceM),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for salons, parlors, or massages...',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.textHintDark : AppColors.textHint,
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderWidthThin,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.colorScheme.onSurface,
          ),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(
          _selectedCategoryName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sticky Category Section
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategorySectionDelegate(
              selectedCategoryIndex: _selectedCategoryIndex,
              onCategoryTap: _onCategoryTap,
            ),
          ),
    
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceM)),
    
          // Search Input
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
              ),
              child: _buildSearchInput(context),
            ),
          ),
    
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceM)),
    
          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salons offering $_selectedCategoryName',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceS),
                  Text(
                    'Browse through our curated list of salons',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
    
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceM)),
    
          // Salon List with BlocBuilder
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              // Initial loading with shimmer
              if (state.isSalonsLoading && state.salons.isEmpty) {
                return CategoryShimmers.buildSliverSalonListShimmer(context, count: 5);
              }

              // Error state
              if (state.salonsError != null && state.salons.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    child: Center(
                      child: Text(
                        state.salonsError!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              // Empty state
              if (state.salons.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    child: Center(
                      child: Text(
                        'Select a category to view salons',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Display salons
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final salon = state.salons[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
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
                          address: salon.address,
                          categories: salon.categories,
                          languageCodes: salon.languageCodes,
                          isFullWidth: true,
                          onTap: () {
                            GoRouter.of(context).push(
                              RouteNames.salonDetails,
                              extra: {
                                'salonId': salon.id,
                                'salonName': salon.salonName,
                              },
                            );
                          },
                        ),
                      );
                    },
                    childCount: state.salons.length,
                  ),
                ),
              );
            },
          ),
    
          // Loading indicator for infinite scroll
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state.isLoadingMoreSalons) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
    
          // End of list message
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (!state.hasMoreSalons && state.salons.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Center(
                      child: Text(
                        'No more salons to load',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
    
          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceXXL)),
        ],
      ),
    );
  }
}

/// Delegate for sticky category section
class _CategorySectionDelegate extends SliverPersistentHeaderDelegate {
  final int selectedCategoryIndex;
  final Function(String categoryName, int categoryIndex, String categoryId) onCategoryTap;

  _CategorySectionDelegate({
    required this.selectedCategoryIndex,
    required this.onCategoryTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return CategorySection(
      selectedCategoryIndex: selectedCategoryIndex,
      onCategoryTap: onCategoryTap,
    );
  }

  @override
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
