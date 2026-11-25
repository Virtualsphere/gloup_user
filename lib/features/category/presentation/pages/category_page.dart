import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/home_design_tokens.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/providers/location_provider.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/category/presentation/bloc/category_bloc.dart';
import 'package:tressy/features/category/presentation/bloc/category_event.dart';
import 'package:tressy/features/category/presentation/bloc/category_state.dart';
import 'package:tressy/features/category/presentation/widgets/category_salon_row.dart';
import 'package:tressy/features/category/presentation/widgets/category_shimmers.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/features/home/domain/entities/filter_state.dart';
import 'package:tressy/features/home/presentation/widgets/category_section.dart';
import 'package:tressy/features/home/presentation/widgets/filters_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/home_sort_sheet.dart';
import 'package:tressy/features/home/presentation/widgets/salon_list_header.dart';
import 'package:tressy/shared/domain/usecases/get_salons_usecase.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/custom_toast.dart';

class CategoryPage extends StatefulWidget {
  final String? categoryName;
  final int? categoryIndex;
  final String? categoryId;

  const CategoryPage({
    super.key,
    this.categoryName,
    this.categoryIndex,
    this.categoryId,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  static const int _pageSize = 10;

  late int _selectedCategoryIndex;
  late String _selectedCategoryName;
  String? _selectedCategoryId;
  final ScrollController _scrollController = ScrollController();

  FilterState _filters = FilterState.empty;

  /// Salons in this category with an offer, for the "N salons have offers" strip.
  int? _offerCount;

  // Track location changes
  double? _lastLatitude;
  double? _lastLongitude;
  LocationProvider? _locationProvider;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.categoryIndex ?? 1;
    _selectedCategoryName = widget.categoryName ?? 'Haircut';
    _selectedCategoryId = widget.categoryId;
    _scrollController.addListener(_onScroll);

    // Use LocationProvider's current location; don't fetch GPS here.
    _resolveCategoryId();
    _loadSalons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<LocationProvider>();
    if (_locationProvider != provider) {
      _locationProvider?.removeListener(_onLocationProviderChanged);
      _locationProvider = provider;
      _lastLatitude = provider.latitude;
      _lastLongitude = provider.longitude;
      provider.addListener(_onLocationProviderChanged);
    }
  }

  void _onLocationProviderChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final location = context.read<LocationProvider>();
      if (_lastLatitude != location.latitude ||
          _lastLongitude != location.longitude) {
        _lastLatitude = location.latitude;
        _lastLongitude = location.longitude;
        _resolveCategoryId();
        _loadSalons();
      }
    });
  }

  @override
  void dispose() {
    _locationProvider?.removeListener(_onLocationProviderChanged);
    _scrollController.dispose();
    super.dispose();
  }

  /// Falls back to the category list when Home did not pass an id.
  void _resolveCategoryId() {
    if (_selectedCategoryId != null) return;
    final categories = context.read<CategoryBloc>().state.categories;
    if (categories.isNotEmpty && _selectedCategoryIndex < categories.length) {
      _selectedCategoryId = categories[_selectedCategoryIndex].id;
    }
  }

  void _loadSalons({bool loadMore = false}) {
    final id = _selectedCategoryId;
    if (id == null) return;
    final location = context.read<LocationProvider>();
    context.read<CategoryBloc>().add(LoadCategorySalonsEvent(
          latitude: location.latitude,
          longitude: location.longitude,
          categoryId: id,
          limit: _pageSize,
          page: loadMore ? null : 1,
          isLoadMore: loadMore,
          filters: _filters.toRequest(),
        ));
    if (!loadMore) _loadOfferCount();
  }

  /// Salons in this category that have an offer, ignoring the offers filter
  /// itself so the strip does not flip while it is toggled.
  Future<void> _loadOfferCount() async {
    final id = _selectedCategoryId;
    if (id == null) return;
    final count = await _countSalons(
      _filters.copyWith(hasOffers: true),
    );
    if (!mounted || id != _selectedCategoryId) return;
    setState(() => _offerCount = count);
  }

  /// Number of salons matching a draft filter in this category.
  Future<int?> _countSalons(FilterState draft) async {
    final id = _selectedCategoryId;
    if (id == null) return null;
    final location = context.read<LocationProvider>();
    final result = await sl<GetSalonsUseCase>().callPage(GetSalonsParams(
      latitude: location.latitude,
      longitude: location.longitude,
      category: id,
      limit: 1,
      page: 1,
      filters: draft.toRequest(),
    ));
    return result.fold((_) => null, (page) => page.totalRecords);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final remaining = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining <= 200) _loadSalons(loadMore: true);
  }

  void _onCategoryTap(
      String categoryName, int categoryIndex, String categoryId) {
    setState(() {
      _selectedCategoryIndex = categoryIndex;
      _selectedCategoryName = categoryName;
      _selectedCategoryId = categoryId;
      _offerCount = null;
    });
    _loadSalons();
  }

  void _onFiltersChanged(FilterState next) {
    if (next == _filters) return;
    setState(() => _filters = next);
    _loadSalons();
  }

  Future<void> _openFilters() async {
    final picked = await FiltersSheet.show(
      context,
      initial: _filters,
      countFor: _countSalons,
    );
    if (picked != null) _onFiltersChanged(picked);
  }

  Future<void> _openSort() async {
    final picked = await HomeSortSheet.show(context, _filters.sort);
    if (picked != null) _onFiltersChanged(_filters.copyWith(sort: picked));
  }

  void _openSalon(String id, String name) {
    GoRouter.of(context).push(
      RouteNames.salonDetails,
      extra: {'salonId': id, 'salonName': name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;
    return _buildContent(context, isDarkMode);
  }

  Widget _buildTitle(BuildContext context, CategoryState state) {
    final location = context.watch<LocationProvider>();
    final area = location.area.trim().isNotEmpty
        ? location.area.trim()
        : location.city.trim();
    final subtitle = [
      if (state.totalSalons != null)
        state.totalSalons == 1 ? '1 salon' : '${state.totalSalons} salons',
      if (area.isNotEmpty) area,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedCategoryName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            key: const Key('category_subtitle'),
            style: context.textTheme.bodySmall?.copyWith(
              color: HomeDesignTokens.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildOffersStrip() {
    final count = _offerCount;
    if (count == null || count <= 0) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.paddingM, AppSizes.spaceM,
          AppSizes.paddingM, 0),
      child: GestureDetector(
        key: const Key('offers_strip'),
        onTap: () => _onFiltersChanged(
          _filters.copyWith(hasOffers: !_filters.hasOffers),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS + 2,
          ),
          decoration: BoxDecoration(
            color: HomeDesignTokens.accentBlueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  size: 18, color: HomeDesignTokens.accentBlue),
              SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 salon has offers on $_selectedCategoryName today'
                      : '$count salons have offers on $_selectedCategoryName today',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: HomeDesignTokens.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDarkMode) {
    return BlocListener<FavoritesBloc, FavoritesState>(
      listenWhen: (previous, current) =>
          current.toastCounter != previous.toastCounter,
      listener: (context, state) {
        if (state.status == FavoritesStatus.success) {
          CustomToast.showSuccess(context, state.message ?? 'Favorite updated');
        } else if (state.status == FavoritesStatus.failure) {
          CustomToast.showError(
              context, state.errorMessage ?? 'Failed to update favorite');
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
        appBar: AppBar(
          backgroundColor:
              isDarkMode ? AppColors.surfaceDark : AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: isDarkMode ? AppColors.borderDark : AppColors.border,
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
          title: BlocBuilder<CategoryBloc, CategoryState>(
            buildWhen: (a, b) => a.totalSalons != b.totalSalons,
            builder: (context, state) => _buildTitle(context, state),
          ),
          actions: [
            IconButton(
              key: const Key('category_search'),
              icon: const Icon(Icons.search),
              onPressed: () =>
                  GoRouter.of(context).push(RouteNames.salonSearch),
            ),
          ],
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Sticky category avatar row
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategorySectionDelegate(
                selectedCategoryIndex: _selectedCategoryIndex,
                onCategoryTap: _onCategoryTap,
              ),
            ),

            // Filters / Sort / quick picks
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: AppSizes.spaceS),
                child: SalonListHeader(
                  showHeading: false,
                  totalRecords: null,
                  filters: _filters,
                  onChanged: _onFiltersChanged,
                  onSortTap: _openSort,
                  onFiltersTap: _openFilters,
                ),
              ),
            ),

            SliverToBoxAdapter(child: _buildOffersStrip()),

            SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceM)),

            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state.isSalonsLoading && state.salons.isEmpty) {
                  return CategoryShimmers.buildSliverSalonListShimmer(context,
                      count: 5);
                }

                if (state.salonsError != null && state.salons.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingXL),
                      child: Column(
                        children: [
                          Text(
                            state.salonsError!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            key: const Key('category_retry'),
                            onPressed: _loadSalons,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.salons.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingXL),
                      child: Center(
                        child: Text(
                          _filters.activeCount > 0
                              ? 'No salons match these filters'
                              : 'No salons offer $_selectedCategoryName nearby',
                          key: const Key('category_empty'),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final salon = state.salons[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSizes.spaceM),
                          child: CategorySalonRow(
                            salon: salon,
                            categoryName: _selectedCategoryName,
                            onTap: () =>
                                _openSalon(salon.id, salon.salonName),
                            onBook: () =>
                                _openSalon(salon.id, salon.salonName),
                          ),
                        );
                      },
                      childCount: state.salons.length,
                    ),
                  ),
                );
              },
            ),

            // Loading indicator for infinite scroll
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (!state.isLoadingMoreSalons) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingL),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                );
              },
            ),

            SliverToBoxAdapter(child: SizedBox(height: AppSizes.spaceXXL)),
          ],
        ),
      ),
    );
  }
}

/// Delegate for sticky category section
class _CategorySectionDelegate extends SliverPersistentHeaderDelegate {
  final int selectedCategoryIndex;
  final Function(String categoryName, int categoryIndex, String categoryId)
      onCategoryTap;

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
