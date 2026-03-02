import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/widgets/explore_salon_card.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/login_required_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mock favorite salons data
  final List<Map<String, dynamic>> _favoriteSalons = [
    {
      'name': 'Elite Hair Studio',
      'image': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      'images': [
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      ],
      'rating': 4.8,
      'reviewCount': 234,
      'distance': 2.5,
      'address': 'Koramangala, Bangalore',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Haircut',
      'servicePrice': 299.0,
      'categories': ['Hair', 'Beard', 'Spa'],
      'languageCodes': ['en', 'hi', 'kn'],
    },
    {
      'name': 'Beauty Lounge',
      'image': 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      'images': [
        'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      ],
      'rating': 4.6,
      'reviewCount': 189,
      'distance': 3.2,
      'address': 'Indiranagar, Bangalore',
      'isPremium': false,
      'isFavorite': true,
      'serviceName': 'Facial',
      'servicePrice': 499.0,
      'categories': ['Facial', 'Makeup'],
      'languageCodes': ['en', 'ta'],
    },
    {
      'name': 'Chic Cuts',
      'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      'images': [
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      ],
      'rating': 4.7,
      'reviewCount': 278,
      'distance': 2.9,
      'address': 'HSR Layout, Bangalore',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Styling',
      'servicePrice': 399.0,
      'categories': ['Hair', 'Color'],
      'languageCodes': ['en', 'te', 'kn'],
    },
    {
      'name': 'Glow Spa',
      'image': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
      'images': [
        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
      ],
      'rating': 4.9,
      'reviewCount': 287,
      'distance': 1.5,
      'address': 'Rajajinagar, Bangalore',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Facial',
      'servicePrice': 699.0,
      'categories': ['Facial', 'Spa'],
      'languageCodes': ['en', 'hi', 'ta'],
    },
    {
      'name': 'Premium Salon',
      'image': 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      'images': [
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
        'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      ],
      'rating': 4.7,
      'reviewCount': 245,
      'distance': 2.8,
      'address': 'Banashankari, Bangalore',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Spa',
      'servicePrice': 899.0,
      'categories': ['Spa', 'Massage'],
      'languageCodes': ['en', 'ml', 'kn'],
    },
    {
      'name': 'Elite Grooming',
      'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      'images': [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
      ],
      'rating': 4.9,
      'reviewCount': 356,
      'distance': 1.2,
      'address': 'Sadashivanagar, Bangalore',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Grooming',
      'servicePrice': 999.0,
      'categories': ['Hair', 'Beard', 'Spa'],
      'languageCodes': ['en', 'hi', 'kn', 'ta'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return LoginRequiredWidget(
      title: 'Login to View Favorites',
      message: 'Please login to save and view your favorite salons.',
      showBrowseAsGuest: false, // Don't show "Browse as Guest" in bottom nav screens
      child: Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
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
          padding: const EdgeInsets.symmetric(
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
              const SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
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
                  onChanged: (value) {
                    // Handle search
                  },
                ),
              ),
              InkWell(
                onTap: () {
                  // Handle settings tap
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primaryDark.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    AppIcons.icSettings,
                    width: AppSizes.iconS,
                    height: AppSizes.iconS,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? AppColors.primaryDark : AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Favorites',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    '${_favoriteSalons.length} saved salons',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),

          // Empty state or Salon List
          if (_favoriteSalons.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSizes.spaceL),
                    Text(
                      'No favorites yet',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceS),
                    Text(
                      'Start adding salons to your favorites',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                            : AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final salon = _favoriteSalons[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
                      child: SizedBox(
                        height: 140,
                        child: ExploreSalonCard(
                          salonName: salon['name'],
                          salonImage: salon['image'],
                          images: List<String>.from(salon['images']),
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
                          },
                          onFavoriteToggle: () {
                            // Handle favorite toggle - remove from favorites
                            setState(() {
                              _favoriteSalons.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  childCount: _favoriteSalons.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceL)),
        ],
      ),
      ),
    );
  }
}
