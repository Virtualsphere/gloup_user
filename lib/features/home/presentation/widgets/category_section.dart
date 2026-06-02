import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/category_image.dart';

class CategorySection extends StatefulWidget {
  final Function(String categoryName, int categoryIndex, String categoryId)?
      onCategoryTap;
  final int? selectedCategoryIndex;
  final bool showActiveBorder;
  final List<CategoryEntity>?
      categories; // Optional categories passed from parent
  final bool? isLoading; // Optional loading state
  final String? error; // Optional error message

  const CategorySection({
    super.key,
    this.onCategoryTap,
    this.selectedCategoryIndex,
    this.showActiveBorder = true,
    this.categories,
    this.isLoading,
    this.error,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedCategoryIndex ?? 0;

    // Load categories if not passed directly
    if (widget.categories == null) {
      context.read<CategoryBloc>().add(const LoadCategoriesEvent());
    }
  }

  @override
  void didUpdateWidget(CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategoryIndex != null &&
        widget.selectedCategoryIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedCategoryIndex!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If categories are passed directly, use them (for standalone usage)
    if (widget.categories != null ||
        widget.isLoading != null ||
        widget.error != null) {
      return _buildCategoryContent(
        context,
        categories: widget.categories ?? [],
        isLoading: widget.isLoading ?? false,
        error: widget.error,
      );
    }

    // Otherwise, use CategoryBloc (shared across app)
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        return _buildCategoryContent(
          context,
          categories: state.categories,
          isLoading: state.status == CategoryStatus.loading,
          error: state.errorMessage,
        );
      },
    );
  }

  Widget _buildCategoryContent(
    BuildContext context, {
    required List<CategoryEntity> categories,
    required bool isLoading,
    String? error,
  }) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return Container(
      height: 120,
      color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      child: isLoading
          ? _buildCategoryShimmer()
          : error != null
              ? _buildErrorWidget(error)
              : Builder(
                  builder: (context) {
                    final displayCategories = [
                      const CategoryEntity(id: 'all', label: 'All', imageUrl: ''),
                      ...categories,
                    ];
                    return Row(
                      children: [
                        // Sticky Premium Category
                        // _buildPremiumCategory(context, isActive: _selectedIndex == 0),
                        // Horizontally Scrollable Categories
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.only(right: AppSizes.paddingS),
                            itemCount: displayCategories.length,
                            itemBuilder: (context, index) {
                              final category = displayCategories[index];
                              return _buildCategory(
                                context,
                                category.label,
                                category.imageUrl,
                                id: category.id,
                                index: index,
                                apiCategories: categories,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                ),
    );
  }

  // ignore: unused_element
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
            color: isActive
                ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                : Colors.transparent,
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
                  color: isActive
                      ? isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    String imageUrl, {
    required String id,
    required int index,
    required List<CategoryEntity> apiCategories,
  }) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    final bool isActive = _selectedIndex == index;

    return Container(
      width: 70,
      margin: const EdgeInsets.only(
        left: AppSizes.paddingS,
        top: AppSizes.paddingS,
        bottom: 0,
      ),
      decoration: BoxDecoration(
        border: widget.showActiveBorder
            ? Border(
                bottom: BorderSide(
                  color: isActive
                      ? (isDarkMode ? AppColors.primaryDark : AppColors.primary)
                      : Colors.transparent,
                  width: 2.5,
                ),
              )
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          widget.onCategoryTap?.call(title, index, id);
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
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: ColoredBox(
                      color: title == 'All'
                          ? (isDarkMode
                              ? AppColors.surfaceDark
                              : const Color(0xFFF5F5F5))
                          : (isDarkMode
                              ? AppColors.primaryDark.withValues(alpha: 0.08)
                              : const Color(0xFFF3F4F6)),
                      child: CategoryImage(
                        categoryName: title,
                        imageUrl: imageUrl,
                        apiCategories: apiCategories,
                        width: 64,
                        height: 64,
                        fit: title == 'All' ? BoxFit.contain : BoxFit.cover,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                title,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppSizes.fontS,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
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

  /// Build error widget when categories fail to load
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: AppColors.borderDark,
              size: 32,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              'Failed to load categories',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            Text(
              error,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
