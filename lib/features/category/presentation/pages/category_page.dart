import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/home/presentation/widgets/category_section.dart';
import 'package:tressy/shared/widgets/explore_salon_card.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  static const int _itemsPerPage = 6;
  List<Map<String, dynamic>> _displayedSalons = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.categoryIndex ?? 1;
    _selectedCategoryName = widget.categoryName ?? 'Haircut';
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Load first page
    _displayedSalons = _mockSalons.take(_itemsPerPage).toList();
    _hasMoreData = _mockSalons.length > _itemsPerPage;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      _loadMoreSalons();
    }
  }

  Future<void> _loadMoreSalons() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentPage++;
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      
      if (startIndex < _mockSalons.length) {
        final newSalons = _mockSalons
            .skip(startIndex)
            .take(_itemsPerPage)
            .toList();
        _displayedSalons.addAll(newSalons);
        _hasMoreData = endIndex < _mockSalons.length;
      } else {
        _hasMoreData = false;
      }
      
      _isLoadingMore = false;
    });
  }

  void _onCategoryTap(String categoryName, int categoryIndex) {
    setState(() {
      _selectedCategoryIndex = categoryIndex;
      _selectedCategoryName = categoryName;
    });
  }

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockSalons = [
    {
      'name': 'Elite Hair Studio',
      'image': 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      'images': [
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
        'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      ],
      'rating': 4.8,
      'reviewCount': 234,
      'distance': 2.5,
      'location': 'Koramangala',
      'isPremium': true,
      'isFavorite': false,
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
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      ],
      'rating': 4.6,
      'reviewCount': 189,
      'distance': 3.2,
      'location': 'Indiranagar',
      'isPremium': false,
      'isFavorite': true,
      'serviceName': 'Facial',
      'servicePrice': 499.0,
      'categories': ['Facial', 'Makeup'],
      'languageCodes': ['en', 'ta'],
    },
    {
      'name': 'Glamour Salon',
      'image': 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      'images': [
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      ],
      'rating': 4.9,
      'reviewCount': 312,
      'distance': 1.8,
      'location': 'MG Road',
      'isPremium': true,
      'isFavorite': false,
      'serviceName': 'Massage',
      'servicePrice': 799.0,
      'categories': ['Spa', 'Massage'],
      'languageCodes': ['en', 'hi', 'ml', 'kn'],
    },
    {
      'name': 'Style Hub',
      'image': 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
      'images': [
        'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      ],
      'rating': 4.5,
      'reviewCount': 156,
      'distance': 4.1,
      'location': 'Whitefield',
      'isPremium': false,
      'isFavorite': false,
      'categories': ['Hair'],
      'languageCodes': ['en'],
    },
    {
      'name': 'Chic Cuts',
      'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      'images': [
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      ],
      'rating': 4.7,
      'reviewCount': 278,
      'distance': 2.9,
      'location': 'HSR Layout',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Styling',
      'servicePrice': 399.0,
      'categories': ['Hair', 'Color'],
      'languageCodes': ['en', 'te', 'kn'],
    },
    {
      'name': 'Urban Salon',
      'image': 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      'images': [
        'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      ],
      'rating': 4.4,
      'reviewCount': 142,
      'distance': 3.7,
      'location': 'BTM Layout',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Shave',
      'servicePrice': 149.0,
      'categories': ['Beard', 'Shave'],
      'languageCodes': ['en', 'hi'],
    },
    {
      'name': 'Royal Cuts',
      'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      'images': [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      ],
      'rating': 4.6,
      'reviewCount': 198,
      'distance': 2.2,
      'location': 'Jayanagar',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Hair Color',
      'servicePrice': 599.0,
      'categories': ['Color', 'Hair'],
      'languageCodes': ['en', 'kn'],
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
      'location': 'Rajajinagar',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Facial',
      'servicePrice': 699.0,
      'categories': ['Facial', 'Spa'],
      'languageCodes': ['en', 'hi', 'ta'],
    },
    {
      'name': 'Modern Barber',
      'image': 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
      'images': [
        'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
        'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      ],
      'rating': 4.3,
      'reviewCount': 176,
      'distance': 3.8,
      'location': 'JP Nagar',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Beard Trim',
      'servicePrice': 199.0,
      'categories': ['Beard'],
      'languageCodes': ['en'],
    },
    {
      'name': 'Luxe Beauty',
      'image': 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      'images': [
        'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      ],
      'rating': 4.8,
      'reviewCount': 321,
      'distance': 2.1,
      'location': 'Malleshwaram',
      'isPremium': true,
      'isFavorite': false,
      'serviceName': 'Manicure',
      'servicePrice': 399.0,
      'categories': ['Nails', 'Spa'],
      'languageCodes': ['en', 'hi', 'kn', 'te'],
    },
    {
      'name': 'Quick Cuts',
      'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      'images': [
        'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=400',
      ],
      'rating': 4.2,
      'reviewCount': 134,
      'distance': 4.5,
      'location': 'Electronic City',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Haircut',
      'servicePrice': 249.0,
      'categories': ['Hair'],
      'languageCodes': ['en', 'ta'],
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
      'location': 'Banashankari',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Spa',
      'servicePrice': 899.0,
      'categories': ['Spa', 'Massage'],
      'languageCodes': ['en', 'ml', 'kn'],
    },
    {
      'name': 'Trendy Cuts',
      'image': 'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      'images': [
        'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=400',
      ],
      'rating': 4.5,
      'reviewCount': 189,
      'distance': 3.3,
      'location': 'Marathahalli',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Styling',
      'servicePrice': 349.0,
      'categories': ['Hair', 'Styling'],
      'languageCodes': ['en', 'hi'],
    },
    {
      'name': 'Elite Grooming',
      'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      'images': [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
        'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?w=400',
        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      ],
      'rating': 4.9,
      'reviewCount': 356,
      'distance': 1.2,
      'location': 'Sadashivanagar',
      'isPremium': true,
      'isFavorite': true,
      'serviceName': 'Grooming',
      'servicePrice': 999.0,
      'categories': ['Hair', 'Beard', 'Spa'],
      'languageCodes': ['en', 'hi', 'kn', 'ta'],
    },
    {
      'name': 'Style Studio',
      'image': 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
      'images': [
        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=400',
        'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?w=400',
      ],
      'rating': 4.4,
      'reviewCount': 167,
      'distance': 3.9,
      'location': 'Yelahanka',
      'isPremium': false,
      'isFavorite': false,
      'serviceName': 'Makeup',
      'servicePrice': 799.0,
      'categories': ['Makeup', 'Facial'],
      'languageCodes': ['en', 'kn'],
    },
  ];

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
    
          // Salon List (1 column)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final salon = _displayedSalons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spaceM),
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
                        address: salon['location'],
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
                          // Handle favorite toggle
                        },
                      ),
                    ),
                  );
                },
                childCount: _displayedSalons.length,
              ),
            ),
          ),
    
          // Loading indicator at bottom
          if (_isLoadingMore)
            SliverToBoxAdapter(
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
            ),
    
          // End of list message
          if (!_hasMoreData && _displayedSalons.isNotEmpty)
            SliverToBoxAdapter(
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
  final Function(String categoryName, int categoryIndex) onCategoryTap;

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
