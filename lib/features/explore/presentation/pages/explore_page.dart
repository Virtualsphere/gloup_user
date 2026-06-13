import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:tressy/features/explore/presentation/bloc/explore_event.dart';
import 'package:tressy/features/explore/presentation/bloc/explore_state.dart';
import 'package:tressy/features/explore/presentation/widgets/explore_shimmers.dart';
import 'package:tressy/shared/widgets/explore_salon_card.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();

    return BlocProvider(
      create: (_) => sl<ExploreBloc>()
        ..add(LoadExploreSalonsEvent(
          latitude: locationProvider.latitude,
          longitude: locationProvider.longitude,
          limit: 20,
        )),
      child: const _ExplorePageContent(),
    );
  }
}

class _ExplorePageContent extends StatefulWidget {
  const _ExplorePageContent();

  @override
  State<_ExplorePageContent> createState() => _ExplorePageContentState();
}

class _ExplorePageContentState extends State<_ExplorePageContent> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double? _lastLatitude;
  double? _lastLongitude;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Store initial location
    final locationProvider = context.read<LocationProvider>();
    _lastLatitude = locationProvider.latitude;
    _lastLongitude = locationProvider.longitude;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkLocationChange() {
    final locationProvider = context.read<LocationProvider>();

    // Check if location has changed
    if (_lastLatitude != locationProvider.latitude ||
        _lastLongitude != locationProvider.longitude) {
      // Update stored location
      _lastLatitude = locationProvider.latitude;
      _lastLongitude = locationProvider.longitude;

      // Reload data with new location
      context.read<ExploreBloc>().add(LoadExploreSalonsEvent(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
            limit: 20,
          ));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      _loadMoreSalons();
    }
  }

  void _loadMoreSalons() {
    final bloc = context.read<ExploreBloc>();
    final locationProvider = context.read<LocationProvider>();

    if (!bloc.state.isLoadingMore && bloc.state.hasMore) {
      bloc.add(LoadExploreSalonsEvent(
        latitude: locationProvider.latitude,
        longitude: locationProvider.longitude,
        limit: 20,
        isLoadMore: true,
      ));
    }
  }

  void _onRefresh() {
    final locationProvider = context.read<LocationProvider>();

    context.read<ExploreBloc>().add(RefreshExploreSalonsEvent(
          latitude: locationProvider.latitude,
          longitude: locationProvider.longitude,
        ));
  }

  void _onSearch(String query) {
    final locationProvider = context.read<LocationProvider>();

    if (query.isEmpty) {
      context.read<ExploreBloc>().add(LoadExploreSalonsEvent(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
            limit: 20,
          ));
    } else {
      context.read<ExploreBloc>().add(LoadExploreSalonsEvent(
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude,
            limit: 20,
            search: query,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        // Check for location changes whenever LocationProvider notifies
        _checkLocationChange();

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.backgroundDark : AppColors.background,
          appBar: AppBar(
            backgroundColor:
                isDarkMode ? AppColors.backgroundDark : AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: AppSizes.appBarHeight,
            shape: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: AppSizes.borderWidthThin,
              ),
            ),
            title: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic_search.svg',
                    width: AppSizes.iconS,
                    height: AppSizes.iconS,
                    colorFilter: ColorFilter.mode(
                      isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceS),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for salons, parlors, or massages...',
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textHintDark
                              : AppColors.textHint,
                          fontSize: AppSizes.fontS,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      style: context.textTheme.bodyMedium,
                      onChanged: _onSearch,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Handle settings tap
                    },
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                    child: Container(
                      decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.primaryDark.withValues(alpha: 0.05)
                              : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusS)),
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        AppIcons.icSettings,
                        width: AppSizes.iconS,
                        height: AppSizes.iconS,
                        colorFilter: ColorFilter.mode(
                          isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  _onRefresh();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceL)),

                    // Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Salons',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Discover the best salons near you',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceL)),

                    // Loading state (initial load) - Show shimmer
                    if (state.isLoading && state.salons.isEmpty)
                      ...ExploreShimmers.explorePageShimmerSlivers(context),

                    // Error state
                    if (state.error != null && state.salons.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.paddingL),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: context.colorScheme.error,
                                ),
                                SizedBox(height: AppSizes.spaceM),
                                Text(
                                  state.error!,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyLarge,
                                ),
                                SizedBox(height: AppSizes.spaceM),
                                ElevatedButton(
                                  onPressed: _onRefresh,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Empty state
                    if (!state.isLoading &&
                        state.salons.isEmpty &&
                        state.error == null)
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.paddingL),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                SizedBox(height: AppSizes.spaceM),
                                Text(
                                  'No salons found',
                                  style: context.textTheme.titleMedium,
                                ),
                                SizedBox(height: AppSizes.spaceS),
                                Text(
                                  'Try adjusting your search or location',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Salon List
                    if (state.salons.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final salon = state.salons[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: AppSizes.paddingM),
                                child: ExploreSalonCard(
                                  storeId: int.tryParse(salon.id) ?? 0,
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
                                  address: salon.displayAddress,
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
                                  },
                                ),
                              );
                            },
                            childCount: state.salons.length,
                          ),
                        ),
                      ),

                    // Loading indicator at bottom
                    if (state.isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.paddingL),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(AppSizes.paddingM),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppColors.surfaceDark
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusCircular),
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
                      ),

                    // End of list message
                    if (!state.hasMore && state.salons.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.paddingL),
                          child: Center(
                            child: Text(
                              'No more salons to load',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bottom spacing
                    SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.spaceXXL)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
