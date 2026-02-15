import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/home/presentation/widgets/home_shimmers.dart';
import 'package:tressy/features/home/presentation/widgets/location_badge.dart';
import 'package:tressy/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:tressy/features/home/presentation/widgets/category_section.dart';
import 'package:tressy/features/home/presentation/widgets/filter_badges.dart';
import 'package:tressy/shared/widgets/section_header.dart';
import 'package:tressy/shared/widgets/salon_card.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentCarouselIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  bool _isCarouselLoading = true;
  bool _isSalonsLoading = true;

  final List<String> _carouselImages = [
    'https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExeTF4ZGU1M25uampzemN4N3RnOGJlNjR1NjFlZXN6OTZqMWJpZnRlbCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/35ELYo9Ng4PxpzWhwH/giphy.gif',
    // Modern salon interior
    'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
    // Hair styling
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
    // Manicure/nail service
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
    // Hair coloring
    'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=800',
    // Beauty spa treatment
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Simulate loading carousel images and salons
    _loadCarousel();
    _loadSalons();
  }

  Future<void> _loadCarousel() async {
    // Simulate loading delay (replace with actual API call)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isCarouselLoading = false;
      });
    }
  }

  Future<void> _loadSalons() async {
    // Simulate loading delay (replace with actual API call)
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isSalonsLoading = false;
      });
    }
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
    final carouselHeight = screenHeight * 0.35; // 30% for carousel

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // SliverAppBar with carousel
          SliverAppBar(
            pinned: true,
            expandedHeight: carouselHeight,
            collapsedHeight: 70,
            toolbarHeight: 70,
            backgroundColor: AppColors.background,
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
                    onTap: () {},
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
                  _isCarouselLoading
                      ? HomeShimmers.buildCarouselShimmer(context)
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: double.infinity,
                            viewportFraction: 1.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
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
                          items: _carouselImages.map((imageUrl) {
                            return Builder(
                              builder: (BuildContext context) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.cut,
                                            size: 80,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),

                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.9),
                          AppColors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
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
                                onTap: () {},
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
                                  child: const Center(
                                    child: Text(
                                      'D',
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
                          SearchBarWidget(onTap: () {}, onSettingsTap: () {}),
                          AppSizes.heightM,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _carouselImages.asMap().entries.map((
                              entry,
                            ) {
                              return Container(
                                width: _currentCarouselIndex == entry.key
                                    ? 24.0
                                    : 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentCarouselIndex == entry.key
                                      ? AppColors.white
                                      : AppColors.white.withValues(alpha: 0.4),
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
            delegate: _CategorySectionDelegate(),
          ),

          SliverToBoxAdapter(child: AppSizes.heightS),

          // Filter Badges Section
          const SliverToBoxAdapter(child: FilterBadges()),

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

          // Horizontal Scrollable Salon Cards
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: _isSalonsLoading
                  ? HomeShimmers.buildSalonCardsShimmer(context)
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM),
                      children: [
                        SalonCard(
                          salonName: 'Luxury Hair & Spa Studio',
                          salonImage:
                              'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
                            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
                            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
                          ],
                          rating: 4.5,
                          reviewCount: 201,
                          distance: 1.2,
                          isPremium: true,
                          serviceName: 'Haircut',
                          servicePrice: 59,
                          categories: ['Haircut', 'Spa', 'Massage', 'Facial'],
                          languageCodes: ['ta', 'en', 'hi'],
                          // Tamil, English, Hindi
                          onTap: () {
                            GoRouter.of(context).push(
                              RouteNames.salonDetails,
                              extra: {
                                'salonId': 'salon_1',
                                'salonName': 'Luxury Hair & Spa Studio',
                              },
                            );
                          },
                        ),
                        SalonCard(
                          salonName: 'Glamour Beauty Lounge',
                          salonImage:
                              'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                            'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
                          ],
                          rating: 4.8,
                          reviewCount: 156,
                          distance: 2.5,
                          isPremium: false,
                          isFavorite: true,
                          serviceName: 'Facial',
                          servicePrice: 299,
                          categories: ['Facial', 'Makeup'],
                          languageCodes: ['hi', 'en'],
                          // Hindi, English
                          onTap: () {
                            GoRouter.of(context).push(
                              RouteNames.salonDetails,
                              extra: {
                                'salonId': 'salon_2',
                                'salonName': 'Glamour Beauty Lounge',
                              },
                            );
                          },
                        ),
                        SalonCard(
                          salonName: 'Elite Gentleman\'s Barber Shop',
                          salonImage:
                              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
                            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
                          ],
                          rating: 4.7,
                          reviewCount: 89,
                          distance: 0.8,
                          isPremium: true,
                          serviceName: 'Trim',
                          servicePrice: 79,
                          categories: ['Haircut', 'Trim', 'Shave'],
                          languageCodes: ['ml', 'en', 'ta'],
                          // Malayalam, English, Tamil
                          onTap: () {
                            GoRouter.of(context).push(
                              RouteNames.salonDetails,
                              extra: {
                                'salonId': 'salon_3',
                                'salonName': 'Elite Gentleman\'s Barber Shop',
                              },
                            );
                          },
                        ),
                        SalonCard(
                          salonName: 'Serenity Spa & Wellness',
                          salonImage:
                              'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
                            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
                          ],
                          rating: 4.9,
                          reviewCount: 312,
                          distance: 3.1,
                          isPremium: false,
                          serviceName: 'Massage',
                          servicePrice: 499,
                          categories: ['Spa', 'Massage'],
                          languageCodes: ['te', 'hi', 'en'],
                          // Telugu, Hindi, English
                          onTap: () {},
                        ),
                      ],
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
              child: _isSalonsLoading
                  ? HomeShimmers.buildSalonCardsShimmer(context)
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM),
                      children: [
                        SalonCard(
                          salonName: 'Royal Beauty Parlour',
                          salonImage:
                              'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
                          ],
                          rating: 4.9,
                          reviewCount: 458,
                          distance: 2.3,
                          isPremium: true,
                          serviceName: 'Bridal Makeup',
                          servicePrice: 1999,
                          categories: ['Makeup', 'Bridal', 'Facial', 'Spa'],
                          languageCodes: ['kn', 'en', 'hi', 'ta'],
                          // Kannada, English, Hindi, Tamil
                          onTap: () {},
                        ),
                        SalonCard(
                          salonName: 'Modern Hair Studio',
                          salonImage:
                              'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                          ],
                          rating: 4.8,
                          reviewCount: 324,
                          distance: 1.5,
                          isPremium: false,
                          serviceName: 'Hair Color',
                          servicePrice: 399,
                          categories: ['Haircut', 'Color'],
                          languageCodes: ['bn', 'en', 'hi'],
                          // Bengali, English, Hindi
                          onTap: () {},
                        ),
                        SalonCard(
                          salonName: 'Bliss Spa & Wellness Center',
                          salonImage:
                              'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
                            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
                            'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
                          ],
                          rating: 4.9,
                          reviewCount: 567,
                          distance: 3.8,
                          isPremium: true,
                          isFavorite: true,
                          serviceName: 'Thai Massage',
                          servicePrice: 899,
                          categories: ['Spa', 'Massage', 'Therapy'],
                          languageCodes: ['gu', 'hi', 'en'],
                          // Gujarati, Hindi, English
                          onTap: () {},
                        ),
                        SalonCard(
                          salonName: 'Gentlemen\'s Club Barbershop',
                          salonImage:
                              'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
                          images: [
                            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
                            'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
                          ],
                          rating: 4.7,
                          reviewCount: 198,
                          distance: 1.9,
                          isPremium: false,
                          serviceName: 'Beard Style',
                          servicePrice: 149,
                          categories: ['Haircut', 'Beard', 'Shave'],
                          languageCodes: ['hi', 'en'],
                          // Hindi, English
                          onTap: () {},
                        ),
                      ],
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
          _isSalonsLoading
              ? SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSizes.paddingM),
                        child: HomeShimmers.buildVerticalSalonCardShimmer(context),
                      ),
                      childCount: 3,
                    ),
                  ),
                )
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SalonCard(
                        salonName: 'Naturals Unisex Salon & Spa',
                        salonImage:
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
                        images: [
                          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                          'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
                          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
                          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
                        ],
                        rating: 4.6,
                        reviewCount: 892,
                        distance: 1.8,
                        isPremium: true,
                        serviceName: 'Hair Spa',
                        servicePrice: 799,
                        categories: ['Haircut', 'Spa', 'Facial', 'Massage'],
                        languageCodes: ['hi', 'en', 'ta'],
                        // Hindi, English, Tamil
                        isFullWidth: true,
                        onTap: () {},
                      ),
                      AppSizes.heightM,
                      SalonCard(
                        salonName: 'Lakme Salon',
                        salonImage:
                            'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=200',
                        images: [
                          'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
                          'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
                          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
                        ],
                        rating: 4.5,
                        reviewCount: 1234,
                        distance: 2.1,
                        isPremium: false,
                        isFavorite: true,
                        serviceName: 'Manicure',
                        servicePrice: 349,
                        categories: ['Nail Art', 'Pedicure'],
                        languageCodes: ['hi', 'en', 'bn'],
                        // Hindi, English, Bengali
                        isFullWidth: true,
                        onTap: () {},
                      ),
                      AppSizes.heightM,
                      SalonCard(
                        salonName: 'Groom & Style Men\'s Salon',
                        salonImage:
                            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
                        images: [
                          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
                          'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=400',
                        ],
                        rating: 4.7,
                        reviewCount: 456,
                        distance: 0.9,
                        isPremium: true,
                        serviceName: 'Royal Shave',
                        servicePrice: 199,
                        categories: ['Haircut', 'Shave', 'Trim'],
                        languageCodes: ['hi', 'en'],
                        // Hindi, English
                        isFullWidth: true,
                        onTap: () {},
                      ),
                      AppSizes.heightM,
                      SalonCard(
                        salonName: 'Aroma Thai Spa',
                        salonImage:
                            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=200',
                        images: [
                          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400',
                          'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=400',
                          'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
                        ],
                        rating: 4.8,
                        reviewCount: 678,
                        distance: 3.2,
                        isPremium: false,
                        serviceName: 'Body Massage',
                        servicePrice: 1299,
                        categories: ['Spa', 'Massage', 'Therapy', 'Wellness'],
                        languageCodes: ['en', 'ta', 'ml'],
                        // English, Tamil, Malayalam
                        isFullWidth: true,
                        onTap: () {},
                      ),
                      AppSizes.heightM,
                      SalonCard(
                        salonName: 'Enrich Salon & Academy',
                        salonImage:
                            'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=200',
                        images: [
                          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
                          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
                        ],
                        rating: 4.6,
                        reviewCount: 543,
                        distance: 2.7,
                        isPremium: true,
                        serviceName: 'Keratin',
                        servicePrice: 2499,
                        categories: ['Hair Treatment', 'Smoothing'],
                        languageCodes: ['kn', 'te', 'en', 'hi'],
                        // Kannada, Telugu, English, Hindi
                        isFullWidth: true,
                        onTap: () {},
                      ),
                    ]),
                  ),
                ),

          // Bottom spacing
          SliverToBoxAdapter(child: AppSizes.heightXXL),
        ],
      ),
    );
  }
}

/// Delegate for sticky category section
class _CategorySectionDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const CategorySection();
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
