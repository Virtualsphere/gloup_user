import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Simulate loading delay (replace with actual API call)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: context.colorScheme.surface,
      child: _isLoading
          ? _buildCategoryShimmer()
          : Row(
              children: [
                // Sticky Premium Category
                // _buildPremiumCategory(context, isActive: _selectedIndex == 0),
                // Horizontally Scrollable Categories
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    children: [
                      _buildCategory(
                        context,
                        'Haircut',
                        'https://static.vecteezy.com/system/resources/previews/058/263/014/large_2x/men-s-hairstyle-and-beard-grooming-guide-a-perfect-look-for-modern-men-free-png.png',
                        index: 1,
                      ),
                      _buildCategory(
                        context,
                        'Trim',
                        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=200',
                        index: 3,
                      ),
                      _buildCategory(
                        context,
                        'Facial',
                        'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=200',
                        index: 4,
                      ),
                      _buildCategory(
                        context,
                        'Manicure',
                        'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=200',
                        index: 5,
                      ),
                      _buildCategory(
                        context,
                        'Spa',
                        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=200',
                        index: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPremiumCategory(BuildContext context, {required bool isActive}) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      width: 75,
      margin: const EdgeInsets.only(
        left: AppSizes.paddingM,
        top: AppSizes.paddingS,
        bottom: 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:  isActive ?  ( isDarkMode ?  AppColors.primaryDark : AppColors.primary) : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingXS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.8),
                      width: AppSizes.borderWidthThick,
                    )),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Lottie.asset(
                    'assets/animations/premium_crown.json',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    // Fallback to icon if Lottie file not found
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.workspace_premium,
                        color: AppColors.warning,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                'Premium',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontS,
                  color: isActive ? isDarkMode ?  AppColors.primaryDark : AppColors.primary : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, String imageUrl,
      {required int index}) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final bool isActive = _selectedIndex == index;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(
        left: AppSizes.paddingS,
        top: AppSizes.paddingS,
        bottom: 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ?  ( isDarkMode ?  AppColors.primaryDark : AppColors.primary) : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                title,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppSizes.fontS,
                  color: isDarkMode ?  AppColors.primaryDark : AppColors.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build shimmer effect for categories loading
  Widget _buildCategoryShimmer() {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Row(
        children: [
          // Premium Category Shimmer
          _buildCategoryItemShimmer(isPremium: true),
          // Regular Categories Shimmer
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: AppSizes.paddingS),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildCategoryItemShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build single category item shimmer
  Widget _buildCategoryItemShimmer({bool isPremium = false}) {
    return Container(
      width: isPremium ? 75 : 80,
      margin: EdgeInsets.only(
        left: isPremium ? AppSizes.paddingM : AppSizes.paddingS,
        top: AppSizes.paddingS,
        bottom: 0,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            // Text placeholder
            Container(
              width: isPremium ? 50 : 60,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
