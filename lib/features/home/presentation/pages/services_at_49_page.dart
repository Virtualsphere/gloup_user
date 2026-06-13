import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/shared/data/models/salon_model.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/core/utils/category_image_resolver.dart';
import 'package:tressy/shared/widgets/category_image.dart';
import 'package:tressy/shared/widgets/salon_card.dart';

/// Data model for a service category fetched from the API
class _ServiceCategory {
  final String id;
  final String name;
  final String searchCategory;
  final int discountedAmount;
  final String? imageUrl;

  const _ServiceCategory({
    required this.id,
    required this.name,
    required this.searchCategory,
    required this.discountedAmount,
    this.imageUrl,
  });

  factory _ServiceCategory.fromJson(Map<String, dynamic> json) {
    return _ServiceCategory(
      id: json['category_id'].toString(),
      name: json['category_name']?.toString() ?? '',
      searchCategory: json['search_category']?.toString() ?? '',
      discountedAmount: (json['discounted_amount'] as num?)?.toInt() ?? 0,
      imageUrl: CategoryImageResolver.apiImageFromJson(json),
    );
  }
}

class ServicesAt49Page extends StatefulWidget {
  final String initialCategory;
  final String? categoryId;
  final String? sex;

  const ServicesAt49Page({
    super.key,
    this.initialCategory = 'All',
    this.categoryId,
    this.sex,
  });

  @override
  State<ServicesAt49Page> createState() => _ServicesAt49PageState();
}

class _ServicesAt49PageState extends State<ServicesAt49Page> {
  // --- Categories state ---
  bool _isCategoriesLoading = true;
  List<_ServiceCategory> _categories = [];
  String? _selectedCategoryId;
  String _selectedCategoryName = 'All';

  // --- Salons state ---
  bool _isSalonsLoading = false;
  List<SalonModel> _salons = [];
  String? _salonsError;

  // --- Filter state ---
  int? _selectedFilterIndex;

  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = [
    '₹49-₹149',
    'Under 5km',
    'Top Rated',
    'Men',
  ];

  // --- Carousel state ---
  int _currentCarouselIndex = 0;
  final List<String> _carouselImages = [
    'assets/images/png/banner_for_service.png',
    'assets/images/png/banner_for_service_2.png',
    'assets/images/png/banner_for_service_3.png',
    'assets/images/png/banner_for_service_4.png'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedCategoryName = widget.initialCategory;
    _fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetch service categories from the top-categories API
  Future<void> _fetchCategories() async {
    try {
      final dio = sl<DioClient>();
      final Map<String, dynamic> payload = {};
      if (widget.sex != null && widget.sex!.isNotEmpty) {
        payload['sex'] = widget.sex;
      }

      final response = await dio.post(
        ApiRoutes.getTopCategories,
        data: payload.isEmpty ? null : payload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        final List<_ServiceCategory> fetchedCategories =
            data.map((e) => _ServiceCategory.fromJson(e)).toList();

        // Prepend an "All" category
        _categories = [
          const _ServiceCategory(
              id: 'all', name: 'All', searchCategory: '', discountedAmount: 0),
          ...fetchedCategories
        ];
      }
    } catch (e) {
      debugPrint('Error fetching service categories: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCategoriesLoading = false;
        });

        // If a categoryId was passed, fetch salons for it.
        // Otherwise, default to "All"
        if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
          _fetchSalons(_selectedCategoryId!);
        } else if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
          _selectedCategoryName = _categories.first.name;
          _fetchSalons(_selectedCategoryId!);
        }
      }
    }
  }

  /// Fetch salons for a given category_id
  Future<void> _fetchSalons(String categoryId) async {
    setState(() {
      _isSalonsLoading = true;
      _salonsError = null;
      _salons = [];
    });

    try {
      final dio = sl<DioClient>();

      String budget = "";
      String rating = "";
      String sex = widget.sex ?? "";

      if (_selectedFilterIndex != null) {
        if (_selectedFilterIndex == 0) {
          budget = "49-99";
        } else if (_selectedFilterIndex == 2) {
          rating = "5";
        } else if (_selectedFilterIndex == 3) {
          sex = "male";
        }
      }

      final Map<String, dynamic> payload = {
        "category_id": categoryId == 'all' ? "" : categoryId,
        "budget": budget,
        "sex": sex,
        "rating": rating,
      };

      final response = await dio.post(
        ApiRoutes.getStoresByCategory,
        data: payload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        _salons = data
            .map((e) =>
                SalonModel.fromJson(e, imageBaseUrl: ApiRoutes.imageBaseUrl))
            .toList();
      } else {
        _salonsError =
            response.data['message']?.toString() ?? 'Failed to load salons';
      }
    } catch (e) {
      _salonsError = 'Something went wrong. Please try again.';
      debugPrint('Error fetching salons by category: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSalonsLoading = false;
        });
      }
    }
  }

  void _onCategoryTap(_ServiceCategory category) {
    if (_selectedCategoryId == category.id) return;

    setState(() {
      _selectedCategoryId = category.id;
      _selectedCategoryName = category.name;
    });
    _fetchSalons(category.id);
  }

  /// Get the discounted price for the currently selected category
  double? _getSelectedCategoryPrice() {
    if (_selectedCategoryId == null || _selectedCategoryId == 'all') {
      return null;
    }
    final match = _categories.where((c) => c.id == _selectedCategoryId);
    if (match.isEmpty) return null;
    return match.first.discountedAmount.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Green header banner ──
          _buildSliverAppBar(isDarkMode),

          // ── Category image placeholders row ──
          SliverToBoxAdapter(
            child: _buildCategoriesRow(isDarkMode),
          ),

          // ── Thin divider under categories ──
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              color:
                  isDarkMode ? AppColors.borderDark : const Color(0xFFE5E7EB),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Filter chips row ──
          SliverToBoxAdapter(
            child: _buildFiltersRow(isDarkMode),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── "X Salons Available" status ──
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: _buildStatusText(isDarkMode),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Salon cards list ──
          _buildSalonList(isDarkMode),

          SliverToBoxAdapter(
            child: SizedBox(
                height:
                    MediaQuery.of(context).padding.bottom + AppSizes.spaceL),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SLIVER APP BAR — Carousel banner with back arrow
  // ─────────────────────────────────────────────
  Widget _buildSliverAppBar(bool isDarkMode) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = 180.0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: appBarHeight,
      backgroundColor:
          isDarkMode ? const Color(0xFF1A3326) : const Color(0xFFE8F5E9),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: appBarHeight + topPadding,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              items: _carouselImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                    );
                  },
                );
              }).toList(),
            ),
            // Dots indicator at the bottom
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _carouselImages.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentCarouselIndex == entry.key ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: _currentCarouselIndex == entry.key
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STATUS TEXT — "X Salons Available" in green
  // ─────────────────────────────────────────────
  Widget _buildStatusText(bool isDarkMode) {
    if (_isCategoriesLoading || _isSalonsLoading) {
      return const SizedBox.shrink();
    }

    if (_salonsError != null) {
      return Text(
        _salonsError!,
        style: context.textTheme.bodyMedium?.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Text(
      '${_salons.length} Salon${_salons.length != 1 ? 's' : ''} Available',
      style: GoogleFonts.inter(
        color: const Color(0xFF6E7287),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 17 / 14,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FILTER CHIPS — "₹49-₹149", "Under 5km", etc.
  // ─────────────────────────────────────────────
  Widget _buildFiltersRow(bool isDarkMode) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isActive = _selectedFilterIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex =
                    _selectedFilterIndex == index ? null : index;
              });
              if (_selectedCategoryId != null) {
                _fetchSalons(_selectedCategoryId!);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDarkMode
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE8F5E9))
                    : (isDarkMode ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? (isDarkMode
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFF2E7D32))
                      : (isDarkMode
                          ? AppColors.borderDark
                          : const Color(0xFFE5E7EB)),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index],
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? (isDarkMode ? Colors.white : const Color(0xFF2E7D32))
                      : (isDarkMode
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF4B5563)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  CATEGORIES — horizontal scrollable row
  // ─────────────────────────────────────────────
  Widget _buildCategoriesRow(bool isDarkMode) {
    if (_isCategoriesLoading) {
      return _buildCategoryShimmer(isDarkMode);
    }

    if (_categories.isEmpty) {
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'No categories available',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryId == category.id;

          return GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: Container(
              width: 62,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ── Category image (fills card) ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: ColoredBox(
                        color: isDarkMode
                            ? AppColors.surfaceDark
                            : const Color(0xFFF3F4F6),
                        child: CategoryImage(
                          categoryName: category.name,
                          imageUrl: category.imageUrl,
                          width: 52,
                          height: 52,
                          fit: category.name.toLowerCase() == 'all'
                              ? BoxFit.contain
                              : BoxFit.cover,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),

                  // ── Category name ──
                  Text(
                    category.name,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 3),

                  // ── Underline indicator for selected category ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.5,
                    width: isSelected ? 30 : 0,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Shimmer placeholder while categories load ──
  Widget _buildCategoryShimmer(bool isDarkMode) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS, vertical: 8),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 72,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.surfaceDark
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 42,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.surfaceDark
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SALON LIST — cards with loading / error / empty
  // ─────────────────────────────────────────────
  Widget _buildSalonList(bool isDarkMode) {
    if (_isCategoriesLoading || _isSalonsLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_salonsError != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                SizedBox(height: AppSizes.spaceM),
                Text(
                  _salonsError!,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.spaceL),
                OutlinedButton(
                  onPressed: () {
                    if (_selectedCategoryId != null) {
                      _fetchSalons(_selectedCategoryId!);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_salons.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 48,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                SizedBox(height: AppSizes.spaceM),
                Text(
                  'No salons found for $_selectedCategoryName',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final categoryPrice = _getSelectedCategoryPrice();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final salon = _salons[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppSizes.paddingL),
              child: SalonCard(
                storeId: int.tryParse(salon.id) ?? index + 1000,
                salonName: salon.salonName,
                salonImage: salon.salonImage,
                images:
                    salon.images.isNotEmpty ? salon.images : [salon.salonImage],
                rating: salon.rating,
                reviewCount: salon.reviewCount,
                distance: salon.distance,
                isPremium: salon.isPremium,
                isFavorite: salon.isFavorite,
                address: salon.displayAddress,
                categories: salon.categories,
                languageCodes: salon.languageCodes,
                serviceName: salon.serviceName ?? _selectedCategoryName,
                servicePrice: salon.servicePrice ?? categoryPrice,
                isFullWidth: true,
                isOfferCard: true,
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
          childCount: _salons.length,
        ),
      ),
    );
  }
}
