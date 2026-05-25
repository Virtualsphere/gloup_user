import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/salon_card.dart';

class ServicesAt49Page extends StatefulWidget {
  final String initialCategory;

  const ServicesAt49Page({
    super.key,
    this.initialCategory = 'All',
  });

  @override
  State<ServicesAt49Page> createState() => _ServicesAt49PageState();
}

class _ServicesAt49PageState extends State<ServicesAt49Page> {
  late String _selectedCategory;
  
  final List<String> _categories = [
    'All',
    'Nails',
    'Massage',
    'Haircut',
    'Facial',
    'Coloring',
  ];

  final List<String> _filters = [
    '₹49-₹149',
    'Under 5km',
    'Top Rated',
    'Men',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDarkMode),
          SliverToBoxAdapter(
            child: _buildCategoriesRow(isDarkMode),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.spaceM),
          ),
          SliverToBoxAdapter(
            child: _buildFiltersRow(isDarkMode),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.spaceM),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Text(
                '8 Salons Available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.textSecondaryDark : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppSizes.spaceM),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
                    child: SalonCard(
                      storeId: index + 1000,
                      salonName: 'Super Luxury Hair Studio',
                      salonImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&q=80', // Beautiful salon interior
                      images: const [
                        'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&q=80',
                      ],
                      rating: 4.8,
                      reviewCount: 210,
                      distance: 1.2,
                      isPremium: true,
                      isFavorite: index % 2 == 0,
                      address: 'Koramangla, Bengaluru',
                      categories: const ['Haircut', 'Coloring', '+4'],
                      languageCodes: const ['hi', 'te', 'kn', 'ml'],
                      serviceName: 'Haircut',
                      servicePrice: 49.0,
                      isFullWidth: true,
                      isOfferCard: true,
                    ),
                  );
                },
                childCount: 8,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + AppSizes.spaceL),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180.0,
      backgroundColor: isDarkMode ? const Color(0xFF1A3326) : const Color(0xFFE8F5E9),
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: isDarkMode ? const Color(0xFF1A3326) : const Color(0xFFE8F5E9),
        ),
      ),
    );
  }

  Widget _buildCategoriesRow(bool isDarkMode) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              width: 75,
              margin: const EdgeInsets.only(left: AppSizes.paddingS, right: AppSizes.paddingXS),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected 
                        ? (isDarkMode ? Colors.white : Colors.black87) 
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.surfaceDark : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: isDarkMode ? AppColors.borderDark : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    // Placeholder for category icons (could use SVGs if provided)
                    child: Center(
                      child: isSelected
                          ? Icon(
                              Icons.check_circle_outline,
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected 
                          ? (isDarkMode ? Colors.white : Colors.black87) 
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersRow(bool isDarkMode) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.paddingS),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? AppColors.borderDark : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _filters[index],
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppColors.textSecondaryDark : const Color(0xFF4B5563),
              ),
            ),
          );
        },
      ),
    );
  }
}
