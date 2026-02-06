import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Horizontally scrollable category section with sticky Premium category
class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 0; // 0 for Premium, 1+ for other categories

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: AppColors.background,
      child: Row(
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
                  'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=200',
                  index: 1,
                ),
                _buildCategory(
                  context,
                  'Massage',
                  'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=200',
                  index: 2,
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
            color: isActive ? AppColors.primary : Colors.transparent,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  child: Lottie.asset(
                    'assets/animations/premium_crown.json',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    // Fallback to icon if Lottie file not found
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.workspace_premium,
                        color: AppColors.warning,
                        size: 28,
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
                  color: isActive ? AppColors.primary : null,
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
            color: isActive ? AppColors.primary : Colors.transparent,
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
          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
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
                  color: isActive ? AppColors.primary : null,
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
}
