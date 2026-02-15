import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/salon_details/presentation/widgets/ambient_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/team_member_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/location_widget.dart';
import 'package:tressy/shared/widgets/review_summary_widget.dart';
import 'package:tressy/shared/widgets/review_card.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/features/salon_details/data/models/salon_detail_model.dart';
import 'package:tressy/features/salon_details/data/models/salon_mock_data.dart';

class SalonDetailsPage extends StatefulWidget {
  final String? salonId;

  const SalonDetailsPage({
    super.key,
    this.salonId,
  });

  @override
  State<SalonDetailsPage> createState() => _SalonDetailsPageState();
}

class _SalonDetailsPageState extends State<SalonDetailsPage> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  int _activeTabIndex = 0;
  int _activeServiceCategoryIndex = 0; // For service category badges
  int _activeReviewFilterIndex =
      0; // For review filter badges (0 = All, 1-5 = stars)
  bool _isLoading = true; // Loading state for shimmer
  
  // Salon data from mock
  late SalonDetailModel _salonData;
  
  // Track selected services
  final Map<String, ServiceModel> _selectedServices = {};
  
  // Method to add/remove service
  void _toggleService(ServiceModel service) {
    setState(() {
      if (_selectedServices.containsKey(service.id)) {
        _selectedServices.remove(service.id);
      } else {
        _selectedServices[service.id] = service;
      }
    });
  }
  
  // Calculate total price
  double get _totalPrice {
    return _selectedServices.values.fold(0.0, (sum, service) => sum + service.price);
  }
  
  // Get service count
  int get _serviceCount {
    return _selectedServices.length;
  }

  // Tab sections
  final List<String> _tabs = [
    'Services',
    'About',
    'Ambients',
    'Team',
    'Reviews',
    'Opening Hours',
    'Location',
  ];

  // Global keys for each section to track their positions
  final Map<String, GlobalKey> _sectionKeys = {
    'Services': GlobalKey(),
    'About': GlobalKey(),
    'Ambients': GlobalKey(),
    'Team': GlobalKey(),
    'Reviews': GlobalKey(),
    'Opening Hours': GlobalKey(),
    'Location': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSalonDetails();
  }

  Future<void> _loadSalonDetails() async {
    // Simulate loading delay (replace with actual API call)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _salonData = SalonMockData.getSalonDetails();
        _isLoading = false;
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
        _scrollController.offset > (carouselHeight * 0.5);

    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }

    // Update active tab based on scroll position
    _updateActiveTab();
  }

  void _updateActiveTab() {
    if (!_scrollController.hasClients) return;

    int newActiveIndex = 0;

    // Find which section is currently visible
    for (int i = _tabs.length - 1; i >= 0; i--) {
      final key = _sectionKeys[_tabs[i]];
      if (key?.currentContext != null) {
        final RenderBox renderBox =
            key!.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);

        // Check if section is visible in viewport (accounting for sticky headers ~400px)
        if (position.dy <= 450) {
          newActiveIndex = i;
          break;
        }
      }
    }

    if (newActiveIndex != _activeTabIndex) {
      setState(() {
        _activeTabIndex = newActiveIndex;
      });
    }
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[_tabs[index]];
    if (key?.currentContext != null) {
      final RenderBox renderBox =
          key!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final scrollOffset = _scrollController.offset;

      // Calculate target scroll position (offset for sticky headers ~400px)
      final targetScroll = scrollOffset + position.dy - 420;

      _scrollController.animateTo(
        targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.35;
    final collapsedHeight = screenHeight * 0.08; // 8% when collapsed
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar with carousel
              SliverAppBar(
                pinned: true,
                expandedHeight: carouselHeight,
                collapsedHeight: collapsedHeight,
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
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the shrink offset to determine collapse state
                    final currentHeight = constraints.maxHeight;
                    final isFullyExpanded = currentHeight > collapsedHeight + 50;

                    return FlexibleSpaceBar(
                      background: _isLoading
                          ? _buildCarouselShimmer(context, isDarkMode)
                          : _buildCarousel(
                              context, carouselHeight, isDarkMode, isFullyExpanded),
                      collapseMode: CollapseMode.pin,
                      centerTitle: false,
                      titlePadding: EdgeInsets.zero,
                      title: !isFullyExpanded
                          ? _buildCollapsedHeader(context, isDarkMode)
                          : null,
                    );
                  },
                ),
              ),

              // Sticky Title, Crown, Info Section, and Tab Bar (Combined)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: Container(
                    color: context.colorScheme.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoading
                            ? _buildHeaderShimmer(context, isDarkMode)
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingM,
                                  vertical: AppSizes.paddingM,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTitleAndCrownSection(context, isDarkMode),
                                    AppSizes.heightL,
                                    _buildInfoSection(context, isDarkMode),
                                  ],
                                ),
                              ),
                        AppSizes.heightS,
                        _buildTabBar(context, isDarkMode),
                      ],
                    ),
                  ),
                ),
              ),

              // Content sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ..._tabs.map((tab) => _buildSection(tab, isDarkMode)),
                    // Add bottom padding to prevent content from being hidden behind bottom nav
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          
          // Positioned bottom navigation bar
          _buildBottomNavBar(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, double carouselHeight,
      bool isDarkMode, bool isFullyExpanded) {
    final images = _isLoading ? [] : _salonData.images;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Carousel images
        CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            autoPlay: isFullyExpanded,
            // Only auto-play when expanded
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image,
                          color: AppColors.primary,
                          size: 80,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }).toList(),
        ),

        // Carousel indicators - only show when expanded
        if (isFullyExpanded && images.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: _currentImageIndex == entry.key ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == entry.key
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),

        // Back button - always visible
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
          left: AppSizes.paddingM,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: const EdgeInsets.all(AppSizes.paddingXS),
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
                size: AppSizes.iconS,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        // Share and Favorite buttons (top right) - always visible
        Positioned(
          top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
          right: AppSizes.paddingM,
          child: Row(
            children: [
              // Share button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(AppSizes.paddingXS),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.white,
                    size: AppSizes.iconS,
                  ),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              // Favorite button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: const EdgeInsets.all(AppSizes.paddingXS),
                  constraints: const BoxConstraints(),
                  icon: SvgPicture.asset(
                    _isFavorite
                        ? 'assets/icons/ic_heart_fill.svg'
                        : 'assets/icons/ic_heart.svg',
                    width: AppSizes.iconS,
                    height: AppSizes.iconS,
                    colorFilter: ColorFilter.mode(
                      _isFavorite ? Colors.red : AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build shimmer effect for carousel loading
  Widget _buildCarouselShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      ),
    );
  }

  /// Build shimmer effect for header (title, info, tabs)
  Widget _buildHeaderShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            // Badges shimmer
            Row(
              children: [
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AppSizes.widthS,
                Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            AppSizes.heightL,
            // Info shimmer lines
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
              width: 250,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppSizes.heightS,
            Container(
                width: 280,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                )),
            AppSizes.heightS,
          ],
        ),
      ),
    );
  }

  // Build collapsed header with buttons
  Widget _buildCollapsedHeader(BuildContext context, bool isDarkMode) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
      ),
      padding: EdgeInsets.only(
        left: AppSizes.paddingM,
        right: AppSizes.paddingM,
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            padding: const EdgeInsets.all(AppSizes.paddingXS),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDarkMode ? AppColors.white : AppColors.black,
              size: AppSizes.iconS,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Share and Favorite buttons
          Row(
            children: [
              // Share button
              IconButton(
                padding: const EdgeInsets.all(AppSizes.paddingXS),
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.share,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                  size: AppSizes.iconS,
                ),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
              const SizedBox(width: AppSizes.spaceXS),
              // Favorite button
              IconButton(
                padding: const EdgeInsets.all(AppSizes.paddingXS),
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  _isFavorite
                      ? 'assets/icons/ic_heart_fill.svg'
                      : 'assets/icons/ic_heart.svg',
                  width: AppSizes.iconS,
                  height: AppSizes.iconS,
                  colorFilter: ColorFilter.mode(
                    _isFavorite
                        ? Colors.red
                        : (isDarkMode ? AppColors.white : AppColors.black),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndCrownSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salon name with NEW badge
        Row(
          children: [
            Expanded(
              child: Text(
                _salonData.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  fontSize: AppSizes.fontXL,
                ),
              ),
            ),
            AppSizes.widthM,
            // NEW Badge
            if (_salonData.isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: Text(
                  'NEW',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        AppSizes.heightM,
        // Rating with crown and Gender
        Row(
          children: [
            // Premium crown badge
            if (_salonData.isPremium)
              Container(
                width: AppSizes.iconL,
                height: AppSizes.iconL,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFC02E),
                      Color(0xFFC88C00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_crown.svg',
                    width: AppSizes.iconXS,
                    height: AppSizes.iconXS,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            if (_salonData.isPremium) AppSizes.widthM,
            // Rating badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFA500),
                    size: AppSizes.iconS,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _salonData.rating.toString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '(${_salonData.reviewCount})',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AppSizes.widthM,
            // Gender (no badge)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wc, // Unisex icon
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _salonData.gender,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location and Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_location.svg',
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Expanded(
              child: Text(
                _salonData.address,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        AppSizes.heightM,
        // Open status and timing
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_clock.svg',
              width: AppSizes.iconXS,
              height: AppSizes.iconXS,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Text(
              _salonData.isOpen ? 'Open' : 'Closed',
              style: context.textTheme.bodyMedium?.copyWith(
                color: _salonData.isOpen ? AppColors.success : AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSizes.widthS,
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            AppSizes.widthS,
            Text(
              '${_salonData.openingTime} - ${_salonData.closingTime}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        AppSizes.heightM,
        // Languages
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_translate.svg',
              width: AppSizes.iconS,
              height: AppSizes.iconS,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Expanded(
              child: Wrap(
                spacing: AppSizes.spaceS,
                runSpacing: AppSizes.spaceS,
                children: _salonData.languages
                    .map((lang) => _buildLanguageBadge(lang, isDarkMode))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to build language badge
  Widget _buildLanguageBadge(String language, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.textSecondary.withValues(alpha: 0.2)
            : AppColors.textSecondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
      ),
      child: Text(
        language,
        style: TextStyle(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Build bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    // Only show if there are selected services
    if (_serviceCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(AppSizes.margin),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surface : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side - Service info and price
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_serviceCount ${_serviceCount == 1 ? 'service' : 'services'} added',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: AppSizes.fontS,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_totalPrice.toStringAsFixed(0)}',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryDark,
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.widthM,
              SizedBox(
                width: 130,
                child: PrimaryButton(
                  text: 'Book Now',
                  backgroundColor: AppColors.info,
                  onPressed: () {
                    // TODO: Navigate to booking page
                  },
                  height: 48,
                  fontSize: AppSizes.fontM,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a content section
  Widget _buildSection(String title, bool isDarkMode) {
    return Container(
      key: _sectionKeys[title],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with optional "View all"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              if (title == 'Team' || title == 'Reviews')
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to full team/reviews page
                  },
                  child: Text(
                    'See all',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          AppSizes.heightM,
          // Section content
          if (title == 'Services')
            _buildServicesSection(isDarkMode)
          else if (title == 'About')
            _buildAboutSection(isDarkMode)
          else if (title == 'Ambients')
            _buildAmbientsSection(isDarkMode)
          else if (title == 'Team')
            _buildTeamSection(isDarkMode)
          else if (title == 'Reviews')
            _buildReviewsSection(isDarkMode)
          else if (title == 'Opening Hours')
            _buildOpeningHoursSection(isDarkMode)
          else if (title == 'Location')
            _buildLocationSection(isDarkMode)
          else
            Container(
              height: 500,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.surfaceDark.withValues(alpha: 0.5)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  '$title content goes here...\n\n(Add your real content here)',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build About section
  Widget _buildAboutSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildAboutShimmer(context, isDarkMode);
    }

    return Text(
      _salonData.about,
      textAlign: TextAlign.left,
      style: context.textTheme.bodyMedium?.copyWith(
        color:
            isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  /// Build shimmer effect for opening hours section
  Widget _buildOpeningHoursShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        children: List.generate(
          7,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // Dot shimmer
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                // Day shimmer
                Expanded(
                  child: Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Hours shimmer
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build shimmer effect for reviews section
  Widget _buildReviewsShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review summary shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AppSizes.heightS,
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),
              // Right side - progress bars
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.spaceS),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingS),
                          Container(
                            width: 30,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSizes.heightL,
          // Filter badges shimmer
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                );
              },
            ),
          ),
          AppSizes.heightL,
          // Review cards shimmer
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      // Name and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stars
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  AppSizes.heightM,
                  // Review text
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AppSizes.heightS,
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AppSizes.heightS,
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for team section
  Widget _buildTeamShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

          return Wrap(
            spacing: AppSizes.paddingL,
            runSpacing: AppSizes.paddingL,
            children: List.generate(
              4,
              (index) => SizedBox(
                width: cardWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile circle shimmer
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSizes.heightS,
                    // Name shimmer
                    Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Role shimmer
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build shimmer effect for ambients section
  Widget _buildAmbientsShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth =
              (constraints.maxWidth - (AppSizes.paddingM * 2)) / 3;

          return Wrap(
            spacing: AppSizes.paddingM,
            runSpacing: AppSizes.paddingM,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: cardWidth,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build shimmer effect for about section
  Widget _buildAboutShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSizes.heightS,
          Container(
            width: 250,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  // Build Ambients section
  Widget _buildAmbientsSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildAmbientsShimmer(context, isDarkMode);
    }

    // Map icon names from model to IconData
    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'wifi':
          return Icons.wifi;
        case 'ac_unit':
          return Icons.ac_unit;
        case 'local_parking':
          return Icons.local_parking;
        case 'credit_card':
          return Icons.credit_card;
        case 'wheelchair_pickup':
          return Icons.wheelchair_pickup;
        case 'coffee':
          return Icons.coffee;
        default:
          return Icons.check_circle;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 3 cards per row
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingM * 2)) / 3;

        return Wrap(
          spacing: AppSizes.paddingM,
          runSpacing: AppSizes.paddingM,
          children: _salonData.ambients.map((ambient) {
            return SizedBox(
              width: cardWidth,
              child: AmbientCard(
                icon: getIconData(ambient.icon),
                label: ambient.label,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Build Team section
  Widget _buildTeamSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildTeamShimmer(context, isDarkMode);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 4 profiles per row
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

        return Wrap(
          spacing: AppSizes.paddingL,
          runSpacing: AppSizes.paddingL,
          children: _salonData.teamMembers.map((member) {
            return SizedBox(
              width: cardWidth,
              child: TeamMemberCard(
                name: member.name,
                role: member.role,
                imageUrl: member.imageUrl,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Build Location section
  Widget _buildLocationSection(bool isDarkMode) {
    return _isLoading
        ? _buildLocationShimmer(context, isDarkMode)
        : LocationWidget(
            latitude: _salonData.location.latitude,
            longitude: _salonData.location.longitude,
            address: _salonData.location.address,
          );
  }

  /// Build shimmer effect for services section
  Widget _buildServicesShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badges shimmer
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                );
              },
            ),
          ),
          AppSizes.heightL,
          // Service cards shimmer
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AppSizes.heightS,
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AppSizes.heightS,
                        Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for location section
  Widget _buildLocationShimmer(BuildContext context, bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? AppColors.surfaceDark : AppColors.divider,
      highlightColor: isDarkMode ? AppColors.borderDark : AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map shimmer
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
          ),
          AppSizes.heightL,
          // Address shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  shape: BoxShape.circle,
                ),
              ),
              AppSizes.widthS,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AppSizes.heightXS,
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.heightL,
          // Button shimmer
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
          ),
        ],
      ),
    );
  }

  // Build Opening Hours section
  Widget _buildOpeningHoursSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildOpeningHoursShimmer(context, isDarkMode);
    }

    // Get current day
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday

    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      children: daysOfWeek.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final dayNumber = index + 1; // 1-7 for Monday-Sunday
        final isToday = dayNumber == today;
        final hours = _salonData.openingHours[day] ?? 'Closed';

        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.info.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            children: [
              // Green dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              // Day name with Today text
              Expanded(
                child: isToday
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$day ',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Today',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.fontXS,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        day,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
              ),
              // Hours
              Text(
                hours,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Build Reviews section
  Widget _buildReviewsSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildReviewsShimmer(context, isDarkMode);
    }

    final starCounts = SalonMockData.getStarCounts();
    final totalReviews = _salonData.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Review summary
        ReviewSummaryWidget(
          averageRating: _salonData.rating,
          totalReviews: totalReviews,
          starCounts: starCounts,
        ),
        AppSizes.heightL,
        // Filter badges
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6, // All + 5 stars
            itemBuilder: (context, index) {
              final isActive = _activeReviewFilterIndex == index;
              String label;
              int count;

              if (index == 0) {
                label = 'All';
                count = totalReviews;
              } else {
                final stars = 6 - index; // 5, 4, 3, 2, 1
                label = '$stars ★';
                count = starCounts[stars] ?? 0;
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeReviewFilterIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : (isDarkMode
                            ? AppColors.textSecondary.withValues(alpha: 0.2)
                            : AppColors.textSecondary.withValues(alpha: 0.15)),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: isActive
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          index == 0
                              ? '$label ($count)'
                              : '${6 - index} ($count)',
                          style: TextStyle(
                            color: isActive
                                ? AppColors.white
                                : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AppSizes.heightL,
        // Reviews list (show only 5)
        Column(
          children: [
            ..._salonData.reviews.map((review) {
              return ReviewCard(
                userName: review.userName,
                userImage: review.userImage,
                timeAgo: review.timeAgo,
                rating: review.rating,
                reviewText: review.reviewText,
              );
            }),
            // See all button
            AppSizes.heightS,
            OutlinedButton(
              onPressed: () {
                // TODO: Navigate to all reviews page
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode
                      ? AppColors.textSecondary.withValues(alpha: 0.3)
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'See all ($totalReviews reviews)',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceS),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build Services section with category badges
  Widget _buildServicesSection(bool isDarkMode) {
    if (_isLoading) {
      return _buildServicesShimmer(context, isDarkMode);
    }

    final serviceCategories = SalonMockData.getServiceCategories();
    final currentCategory = serviceCategories[_activeServiceCategoryIndex];
    final filteredServices = SalonMockData.getServicesByCategory(currentCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable category badges
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: serviceCategories.length,
            itemBuilder: (context, index) {
              final category = serviceCategories[index];
              final isActive = _activeServiceCategoryIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeServiceCategoryIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: AppSizes.paddingM),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : (isDarkMode
                            ? AppColors.textSecondary.withValues(alpha: 0.2)
                            : AppColors.textSecondary.withValues(alpha: 0.15)),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.white
                            : (isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        fontSize: AppSizes.fontS,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AppSizes.heightL,
        // Services list
        Column(
          children: filteredServices
              .map((service) => _buildServiceCardWithCallback(
                    service: service,
                    isDarkMode: isDarkMode,
                  ))
              .toList(),
        ),
      ],
    );
  }
  
  // Helper method to build service card with callback
  Widget _buildServiceCardWithCallback({
    required ServiceModel service,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedServices.containsKey(service.id);
    
    return GestureDetector(
      onTap: () => _toggleService(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.surfaceDark.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: isDarkMode
                ? AppColors.textSecondary.withValues(alpha: 0.2)
                : AppColors.textSecondary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Expanded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Service title + Popular badge
                  Row(
                    children: [
                      // Service title
                      Flexible(
                        child: Text(
                          service.name,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Popular badge (optional)
                      if (service.isPopular) ...[
                        const SizedBox(width: AppSizes.spaceS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSizes.heightS,
                  // Row 2: Clock icon + duration
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_clock.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spaceXS),
                      Text(
                        service.duration,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.heightS,
                  // Row 3: Price + Discount badge
                  Row(
                    children: [
                      // Current price
                      Text(
                        '₹${service.price.toStringAsFixed(0)}',
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      // Original price (strikethrough)
                      if (service.originalPrice != null) ...[
                        const SizedBox(width: AppSizes.spaceS),
                        Text(
                          '₹${service.originalPrice!.toStringAsFixed(0)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      // Discount badge
                      if (service.discountPercentage != null) ...[
                        const SizedBox(width: AppSizes.spaceS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: AppColors.success,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${service.discountPercentage} Off',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            // Right side - Add/Selected button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDarkMode 
                        ? AppColors.borderDark 
                        : AppColors.border.withValues(alpha: 0.3))
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check : Icons.add,
                    color: isSelected
                        ? (isDarkMode ? AppColors.white : AppColors.black)
                        : AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSelected ? 'Selected' : 'Add',
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? AppColors.white : AppColors.black)
                          : AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build horizontal scrollable tab bar
  Widget _buildTabBar(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? AppColors.textSecondary.withValues(alpha: 0.2)
                : AppColors.textSecondary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = _activeTabIndex == index;

            return GestureDetector(
              onTap: () {
                _scrollToSection(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingS,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? AppColors.primary
                        : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Sticky Header Delegate for Title, Crown, Info Section, and Tab Bar (Combined)
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent =>
      280.0; // Height for combined sections + tab bar (250 + 56)

  @override
  double get maxExtent => 280.0; // Same as min for fixed height

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
