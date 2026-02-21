import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/home/presentation/bloc/home_bloc.dart';
import 'package:tressy/features/home/presentation/bloc/home_event.dart';
import 'package:tressy/features/home/presentation/bloc/home_state.dart';
import 'package:tressy/features/home/presentation/widgets/category_section.dart';
import 'package:tressy/features/home/presentation/widgets/filter_badges.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';
import 'package:tressy/features/home/presentation/widgets/location_badge.dart';
import 'package:tressy/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/profile/presentation/pages/profile_page.dart';
import 'package:tressy/shared/widgets/salon_card.dart';
import 'package:tressy/shared/widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentCarouselIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  String? _selectedGender; // No default filter
  HomeBloc? _homeBloc;

  // Chennai coordinates
  static const double _latitude = 13.0827;
  static const double _longitude = 80.2707;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onGenderChanged(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    // Reload popular services with new gender filter
    _homeBloc?.add(LoadPopularServicesEvent(
      latitude: _latitude,
      longitude: _longitude,
      gender: gender,
    ));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.35;

    // Check if scrolled past the carousel
    final isCollapsed = _scrollController.hasClients &&
        _scrollController.offset > (carouselHeight - kToolbarHeight);

    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.35; // 35% for carousel

    return BlocProvider(
      create: (context) {
        _homeBloc = sl<HomeBloc>()
          ..add(LoadAllHomeDataEvent(
            latitude: _latitude,
            longitude: _longitude,
          ));
        return _homeBloc!;
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // SliverAppBar with carousel
                SliverAppBar(
                  pinned: true,
                  expandedHeight: carouselHeight,
                  collapsedHeight: 70,
                  toolbarHeight: 70,
                  backgroundColor: context.colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shape: _isCollapsed
                      ? Border(
                          bottom: BorderSide(
                            color: AppColors.border,
                            width: AppSizes.borderWidthThin,
                          ),
                        )
                      : null,
                  // Show only search bar when collapsed
                  title: _isCollapsed
                      ? SearchBarWidget(
                          onTap: () {
                            GoRouter.of(context).push(
                              RouteNames.salonSearch ,
                            );
                          },
                          onSettingsTap: () {},
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingS,
                          ),
                        )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Carousel with shimmer loading
                        state.isCarouselLoading
                            ? HomeShimmers.buildCarouselShimmer(context)
                            : state.carouselBanners.isEmpty
                                ? HomeShimmers.buildCarouselShimmer(context)
                                : CarouselSlider(
                                    options: CarouselOptions(
                                      height: double.infinity,
                                      viewportFraction: 1.0,
                                      autoPlay: true,
                                      autoPlayInterval:
                                          const Duration(seconds: 3),
                                      autoPlayAnimationDuration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentCarouselIndex = index;
                                        });
                                      },
                                    ),
                                    items: state.carouselBanners.map((banner) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            width: double.infinity,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Image.network(
                                                    banner.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        color: AppColors.primary
                                                            .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.cut,
                                                            size: 80,
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          AppColors.black
                                                              .withValues(
                                                                  alpha: 0.85),
                                                          AppColors.black
                                                              .withValues(
                                                                  alpha: 0.05),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),

                        // Location and Profile on top of carousel
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSizes.spaceS),
                                // Location and profile row
                                Row(
                                  children: [
                                    LocationBadge(
                                      location: 'Mumbai',
                                      addressLine2: 'Andheri West',
                                      onTap: () {},
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfilePage(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusCircular,
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            ProfilePage.userName[0],
                                            style: TextStyle(
                                              fontSize: AppSizes.fontL,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // Search bar below location
                                SearchBarWidget(
                                    onTap: () {}, onSettingsTap: () {}),
                                AppSizes.heightM,
                                if (state.carouselBanners.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: state.carouselBanners
                                        .asMap()
                                        .entries
                                        .map((
                                      entry,
                                    ) {
                                      return Container(
                                        width:
                                            _currentCarouselIndex == entry.key
                                                ? 24.0
                                                : 8.0,
                                        height: 8.0,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color:
                                              _currentCarouselIndex == entry.key
                                                  ? AppColors.white
                                                  : AppColors.white
                                                      .withValues(alpha: 0.4),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                AppSizes.heightM,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),

                // Sticky Category Section
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategorySectionDelegate(
                    onCategoryTap: (categoryName, categoryIndex) {
                      GoRouter.of(context).push(
                        RouteNames.category,
                        extra: {
                          'categoryName': categoryName,
                          'categoryIndex': categoryIndex,
                        },
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),

                // Filter Badges Section
                SliverToBoxAdapter(
                  child: FilterBadges(
                    initialGender: _selectedGender,
                    onGenderSelected: _onGenderChanged,
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),

                // Popular Services Nearby Section Header
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Popular Services Nearby',
                    subtitle: 'Based on your location',
                    onSeeAllTap: () {
                      // Navigate to see all popular services
                    },
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),

                // Horizontal Scrollable Salon Cards - Popular Services
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: state.isPopularServicesLoading
                        ? HomeShimmers.buildSalonCardsShimmer(context)
                        : state.popularServices.isEmpty
                            ? const Center(
                                child: Text('No popular services found'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingM),
                                itemCount: state.popularServices.length,
                                itemBuilder: (context, index) {
                                  final salon = state.popularServices[index];
                                  return SalonCard(
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
                                      GoRouter.of(context).push(
                                        RouteNames.salonDetails,
                                        extra: {
                                          'salonId': salon.id,
                                          'salonName': salon.salonName,
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
                ),

                // Content spacing
                SliverToBoxAdapter(child: AppSizes.heightL),

                // Top Salons Section Header
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Top Salons',
                    subtitle: 'Highest rated salons in your area',
                    onSeeAllTap: () {
                      // Navigate to see all top salons
                    },
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),
                // Horizontal Scrollable Salon Cards - Top Salons
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: state.isTopSalonsLoading
                        ? HomeShimmers.buildSalonCardsShimmer(context)
                        : state.topSalons.isEmpty
                            ? const Center(child: Text('No top salons found'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingM),
                                itemCount: state.topSalons.length,
                                itemBuilder: (context, index) {
                                  final salon = state.topSalons[index];
                                  return SalonCard(
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
                                      GoRouter.of(context).push(
                                        RouteNames.salonDetails,
                                        extra: {
                                          'salonId': salon.id,
                                          'salonName': salon.salonName,
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
                ),

                // Bottom spacing
                SliverToBoxAdapter(child: AppSizes.heightXXL),

                // Recommended for You Section Header
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Recommended for You',
                    subtitle: 'Based on your preferences',
                    onSeeAllTap: () {
                      // Navigate to see all recommendations
                    },
                  ),
                ),

                SliverToBoxAdapter(child: AppSizes.heightS),

                // Vertical Full-Width Salon Cards
                state.isRecommendedSalonsLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingM),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSizes.paddingM),
                              child: HomeShimmers.buildVerticalSalonCardShimmer(
                                  context),
                            ),
                            childCount: 3,
                          ),
                        ),
                      )
                    : state.recommendedSalons.isEmpty
                        ? const SliverToBoxAdapter(
                            child:
                                Center(child: Text('No recommendations found')),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingM),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final salon = state.recommendedSalons[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSizes.paddingM),
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
                                childCount: state.recommendedSalons.length,
                              ),
                            ),
                          ),

                // Bottom spacing
                SliverToBoxAdapter(child: AppSizes.heightXXL),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Delegate for sticky category section
class _CategorySectionDelegate extends SliverPersistentHeaderDelegate {
  final Function(String categoryName, int categoryIndex)? onCategoryTap;

  _CategorySectionDelegate({this.onCategoryTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return CategorySection(
      onCategoryTap: onCategoryTap,
      showActiveBorder: false,
      selectedCategoryIndex: -1, // No category selected by default on home
    );
  }

  @override
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
