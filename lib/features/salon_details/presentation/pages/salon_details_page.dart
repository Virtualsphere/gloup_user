import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/di/injection_container.dart';
import 'package:tressy/core/router/route_names.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_bloc.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_event.dart';
import 'package:tressy/features/salon_details/presentation/bloc/salon_detail_state.dart';
import 'package:tressy/features/salon_details/presentation/widgets/salon_details_shimmers.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/salon_details/presentation/widgets/ambient_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/team_member_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/location_widget.dart';
import 'package:tressy/shared/widgets/review_summary_widget.dart';
import 'package:tressy/shared/widgets/review_card.dart';
import 'package:tressy/shared/widgets/primary_button.dart';
import 'package:tressy/shared/widgets/offer_banner.dart';
import 'package:tressy/shared/widgets/error_widget.dart' as custom;

class SalonDetailsPage extends StatefulWidget {
  final String? salonId;

  const SalonDetailsPage({
    super.key,
    this.salonId,
  });

  @override
  State<SalonDetailsPage> createState() => _SalonDetailsPageState();
}

/// Wrapper widget with BlocProvider
class SalonDetailsPageWrapper extends StatelessWidget {
  final String? salonId;

  const SalonDetailsPageWrapper({
    super.key,
    this.salonId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<SalonDetailBloc>()..add(LoadSalonDetailEvent(salonId ?? '')),
      child: SalonDetailsPage(salonId: salonId),
    );
  }
}

class _SalonDetailsPageState extends State<SalonDetailsPage>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  int _activeTabIndex = 0;
  int _activeServiceCategoryIndex = 0; // For service category badges
  int _activeReviewFilterIndex =
      0; // For review filter badges (0 = All, 1-5 = stars)

  // Track selected services
  final Map<int, ServiceEntity> _selectedServices = {};

  // Animation controller for bottom nav bar
  late AnimationController _bottomNavController;
  late Animation<Offset> _bottomNavAnimation;

  // Method to add/remove service
  void _toggleService(ServiceEntity service) {
    setState(() {
      final wasEmpty = _selectedServices.isEmpty;

      if (_selectedServices.containsKey(service.id)) {
        _selectedServices.remove(service.id);
        // If removing last service, animate out
        if (_selectedServices.isEmpty) {
          _bottomNavController.reverse();
        }
      } else {
        _selectedServices[service.id] = service;
        // If adding first service, animate in
        if (wasEmpty) {
          _bottomNavController.forward();
        }
      }
    });
  }

  // Calculate total price
  double get _totalPrice {
    return _selectedServices.values
        .fold(0.0, (sum, service) => sum + service.price);
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

    // Initialize animation controller for bottom nav bar
    _bottomNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bottomNavAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _bottomNavController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bottomNavController.dispose();
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
    final carouselHeight = screenHeight * 0.28;
    final collapsedHeight = screenHeight * 0.08; // 8% when collapsed
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocConsumer<SalonDetailBloc, SalonDetailState>(
      listener: (context, state) {
        // Show error message if any
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
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
                        final isFullyExpanded =
                            currentHeight > collapsedHeight + 50;

                        return FlexibleSpaceBar(
                          background: state.isLoading
                              ? SalonDetailsShimmers.buildCarouselShimmer(
                                  context, isDarkMode)
                              : state.salonDetail != null
                                  ? _buildCarousel(
                                      context,
                                      carouselHeight,
                                      isDarkMode,
                                      isFullyExpanded,
                                      state.salonDetail!)
                                  : const SizedBox.shrink(),
                          collapseMode: CollapseMode.pin,
                          centerTitle: false,
                          titlePadding: EdgeInsets.zero,
                          title: !isFullyExpanded
                              ? _buildCollapsedHeader(
                                  context, isDarkMode, state)
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
                            state.isLoading
                                ? SalonDetailsShimmers.buildHeaderShimmer(
                                    context, isDarkMode)
                                : state.salonDetail != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSizes.paddingM,
                                          vertical: AppSizes.paddingM,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildTitleAndCrownSection(context,
                                                isDarkMode, state.salonDetail!),
                                            AppSizes.heightL,
                                            _buildInfoSection(context,
                                                isDarkMode, state.salonDetail!),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                            AppSizes.heightS,
                            _buildTabBar(context, isDarkMode),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content sections
                  SliverToBoxAdapter(
                    child: state.isLoading
                        ? Column(
                            children: [
                              ..._tabs.map((tab) =>
                                  _buildSectionShimmer(tab, isDarkMode)),
                              const SizedBox(height: 100),
                            ],
                          )
                        : state.errorMessage != null &&
                                state.salonDetail == null
                            ? Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(AppSizes.paddingXL),
                                  child: custom.ErrorDisplayWidget(
                                    message: state.errorMessage!,
                                    onRetry: () {
                                      context.read<SalonDetailBloc>().add(
                                          LoadSalonDetailEvent(
                                              widget.salonId ?? ''));
                                    },
                                  ),
                                ),
                              )
                            : state.salonDetail != null
                                ? Column(
                                    children: [
                                      ..._tabs.map((tab) => _buildSection(
                                          tab, isDarkMode, state.salonDetail!)),
                                      // Add bottom padding to prevent content from being hidden behind bottom nav
                                      const SizedBox(height: 100),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                  ),
                ],
              ),

              // Sticky action buttons (Back, Share, Favorite) - Always visible on top
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSizes.paddingM,
                left: 0,
                right: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Container(
                        decoration: BoxDecoration(
                          color: _isCollapsed
                              ? Colors.transparent
                              : AppColors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(AppSizes.paddingXS),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: _isCollapsed
                                ? (isDarkMode
                                    ? AppColors.white
                                    : AppColors.black)
                                : AppColors.white,
                            size: AppSizes.iconS,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Share and Favorite buttons
                      Row(
                        children: [
                          // Share button
                          Container(
                            decoration: BoxDecoration(
                              color: _isCollapsed
                                  ? Colors.transparent
                                  : AppColors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(AppSizes.paddingXS),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.share,
                                color: _isCollapsed
                                    ? (isDarkMode
                                        ? AppColors.white
                                        : AppColors.black)
                                    : AppColors.white,
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
                              color: _isCollapsed
                                  ? Colors.transparent
                                  : AppColors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child:
                                BlocBuilder<SalonDetailBloc, SalonDetailState>(
                              builder: (context, state) {
                                return IconButton(
                                  padding:
                                      const EdgeInsets.all(AppSizes.paddingXS),
                                  constraints: const BoxConstraints(),
                                  icon: SvgPicture.asset(
                                    state.isFavorite
                                        ? 'assets/icons/ic_heart_fill.svg'
                                        : 'assets/icons/ic_heart.svg',
                                    width: AppSizes.iconS,
                                    height: AppSizes.iconS,
                                    colorFilter: ColorFilter.mode(
                                      state.isFavorite
                                          ? Colors.red
                                          : (_isCollapsed
                                              ? (isDarkMode
                                                  ? AppColors.white
                                                  : AppColors.black)
                                              : AppColors.white),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<SalonDetailBloc>()
                                        .add(const ToggleFavoriteEvent());
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarousel(BuildContext context, double carouselHeight,
      bool isDarkMode, bool isFullyExpanded, SalonDetailEntity salonDetail) {
    final images = salonDetail.images;

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
                return SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.content_cut,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withValues(alpha: 0.85),
                                AppColors.black.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
      ],
    );
  }

  // Build collapsed header with buttons
  Widget _buildCollapsedHeader(
      BuildContext context, bool isDarkMode, SalonDetailState state) {
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
                  state.isFavorite
                      ? 'assets/icons/ic_heart_fill.svg'
                      : 'assets/icons/ic_heart.svg',
                  width: AppSizes.iconS,
                  height: AppSizes.iconS,
                  colorFilter: ColorFilter.mode(
                    state.isFavorite
                        ? Colors.red
                        : (isDarkMode ? AppColors.white : AppColors.black),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  context
                      .read<SalonDetailBloc>()
                      .add(const ToggleFavoriteEvent());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndCrownSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Salon name with NEW badge
        Row(
          children: [
            Expanded(
              child: Text(
                salonDetail.name,
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
            if (salonDetail.isNew)
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
            if (salonDetail.isPremium)
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
            if (salonDetail.isPremium) AppSizes.widthM,
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
                    salonDetail.rating.toString(),
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
                    '(${salonDetail.reviewCount})',
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
                  salonDetail.gender,
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

  Widget _buildInfoSection(
      BuildContext context, bool isDarkMode, SalonDetailEntity salonDetail) {
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
              colorFilter: ColorFilter.mode(
                isDarkMode ? AppColors.primaryDark : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Expanded(
              child: Text(
                salonDetail.address,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
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
              colorFilter: ColorFilter.mode(
                isDarkMode ? AppColors.primaryDark : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Text(
              salonDetail.isOpen ? 'Open' : 'Closed',
              style: context.textTheme.bodyMedium?.copyWith(
                color: salonDetail.isOpen ? AppColors.success : AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (salonDetail.openingTime.isNotEmpty &&
                salonDetail.closingTime.isNotEmpty) ...[
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
                '${salonDetail.openingTime} - ${salonDetail.closingTime}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ] else ...[
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
                'Hours not set',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
              colorFilter: ColorFilter.mode(
                isDarkMode ? AppColors.primaryDark : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            AppSizes.widthS,
            Expanded(
              child: salonDetail.languages.isEmpty
                  ? Text(
                      'Language not set',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: AppSizes.spaceS,
                      runSpacing: AppSizes.spaceS,
                      children: salonDetail.languages
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

  // Helper method to extract unique categories from services
  List<String> _getUniqueCategories(List<ServiceEntity> services) {
    final categories = services
        .map((service) => service.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    // Sort categories alphabetically for consistent display
    categories.sort();

    return categories;
  }

  // Helper method to calculate star counts from reviews
  Map<int, int> _calculateStarCounts(List<ReviewEntity> reviews) {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final review in reviews) {
      final rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        counts[rating] = (counts[rating] ?? 0) + 1;
      }
    }

    return counts;
  }

  // Calculate highest offer percentage from selected services
  int get _highestOfferPercentage {
    if (_selectedServices.isEmpty) return 0;

    return _selectedServices.values
        .where((service) => service.discountPercentage != null)
        .map((service) {
      // Parse discount percentage from string
      final discountStr = service.discountPercentage!;
      final discountInt =
          int.tryParse(discountStr.replaceAll('%', '').trim()) ?? 0;
      return discountInt;
    }).fold<int>(0, (max, discount) => discount > max ? discount : max);
  }

  // Build bottom navigation bar
  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    // Only show if there are selected services
    if (_serviceCount == 0) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SalonDetailBloc, SalonDetailState>(
      builder: (context, state) {
        return SlideTransition(
          position: _bottomNavAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Offer banner (conditionally shown)
              OfferBanner(discountPercentage: _highestOfferPercentage),
              // Main bottom nav bar
              Container(
                padding: EdgeInsets.only(
                  left: AppSizes.paddingM,
                  right: AppSizes.paddingM,
                  top: AppSizes.paddingM,
                  bottom: AppSizes.paddingM + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surface : AppColors.surfaceDark,
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
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryDark,
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
                      width: 150,
                      child: PrimaryButton(
                        text: 'Book Now',
                        onPressed: () {
                          // Prepare data to pass to slot booking page
                          final salonData = {
                            'salonId': widget.salonId,
                            'salonName': state.salonDetail?.name,
                            'salonImage':
                                state.salonDetail?.images.isNotEmpty == true
                                    ? state.salonDetail!.images.first
                                    : null,
                            'rating': state.salonDetail?.rating,
                            'reviewCount': state.salonDetail?.reviewCount,
                            'isPremium': state.salonDetail?.isPremium,
                            'gender': state.salonDetail?.gender,
                            'address': state.salonDetail?.address,
                            'openingTime': state.salonDetail?.openingTime,
                            'closingTime': state.salonDetail?.closingTime,
                            'selectedServices': _selectedServices.values
                                .map((service) => {
                                      'id': service.id,
                                      'name': service.name,
                                      'price': service.price,
                                      'duration': service.duration,
                                      'discountPercentage':
                                          service.discountPercentage,
                                      'isPopular': service.isPopular,
                                    })
                                .toList(),
                            'allServices': state.salonDetail?.services
                                .map((service) => {
                                      'id': service.id,
                                      'name': service.name,
                                      'price': service.price,
                                      'duration': service.duration,
                                      'discountPercentage':
                                          service.discountPercentage,
                                      'isPopular': service.isPopular,
                                    })
                                .toList()
                          };

                          context.pushNamed(
                            RouteNames.slotBooking,
                            extra: salonData,
                          );
                        },
                        backgroundColor: isDarkMode
                            ? AppColors.primary
                            : AppColors.onPrimary,
                        textColor:
                            isDarkMode ? AppColors.onPrimary : AppColors.primary,
                        height: 56,
                        fontSize: AppSizes.fontL,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build section shimmer during loading
  Widget _buildSectionShimmer(String title, bool isDarkMode) {
    return Container(
      key: _sectionKeys[title],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          AppSizes.heightM,
          // Section content shimmer
          if (title == 'Services')
            SalonDetailsShimmers.buildServicesShimmer(context, isDarkMode)
          else if (title == 'About')
            SalonDetailsShimmers.buildAboutShimmer(context, isDarkMode)
          else if (title == 'Ambients')
            SalonDetailsShimmers.buildAmbientsShimmer(context, isDarkMode)
          else if (title == 'Team')
            SalonDetailsShimmers.buildTeamShimmer(context, isDarkMode)
          else if (title == 'Reviews')
            SalonDetailsShimmers.buildReviewsShimmer(context, isDarkMode)
          else if (title == 'Opening Hours')
            SalonDetailsShimmers.buildOpeningHoursShimmer(context, isDarkMode)
          else if (title == 'Location')
            SalonDetailsShimmers.buildLocationShimmer(context, isDarkMode)
          else
            const SizedBox(height: 200),
        ],
      ),
    );
  }

  // Build a content section
  Widget _buildSection(
      String title, bool isDarkMode, SalonDetailEntity salonDetail) {
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
                      color: isDarkMode
                          ? AppColors.primaryDark
                          : AppColors.primary,
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
            _buildServicesSection(isDarkMode, salonDetail)
          else if (title == 'About')
            _buildAboutSection(isDarkMode, salonDetail)
          else if (title == 'Ambients')
            _buildAmbientsSection(isDarkMode, salonDetail)
          else if (title == 'Team')
            _buildTeamSection(isDarkMode, salonDetail)
          else if (title == 'Reviews')
            _buildReviewsSection(isDarkMode, salonDetail)
          else if (title == 'Opening Hours')
            _buildOpeningHoursSection(isDarkMode, salonDetail)
          else if (title == 'Location')
            _buildLocationSection(isDarkMode, salonDetail)
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
  Widget _buildAboutSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.about.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                'About information not available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Text(
      salonDetail.about,
      textAlign: TextAlign.left,
      style: context.textTheme.bodyMedium?.copyWith(
        color:
            isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  // Build Ambients section
  Widget _buildAmbientsSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.ambients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                'No amenities available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
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
          children: salonDetail.ambients.map((ambient) {
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
  Widget _buildTeamSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.teamMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                'No team members added',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 4 profiles per row
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

        return Wrap(
          spacing: AppSizes.paddingL,
          runSpacing: AppSizes.paddingL,
          children: salonDetail.teamMembers.map((member) {
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
  Widget _buildLocationSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    return LocationWidget(
      latitude: salonDetail.location.latitude,
      longitude: salonDetail.location.longitude,
      address: salonDetail.location.address,
    );
  }

  // Build Opening Hours section
  Widget _buildOpeningHoursSection(
      bool isDarkMode, SalonDetailEntity salonDetail) {
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
        final hours = salonDetail.openingHours[day] ?? 'Closed';

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
  Widget _buildReviewsSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                'No reviews yet',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                'Be the first to review this salon',
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
      );
    }

    final starCounts = _calculateStarCounts(salonDetail.reviews);
    final totalReviews = salonDetail.reviewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Review summary
        ReviewSummaryWidget(
          averageRating: salonDetail.rating,
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
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary)
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
                                ? (isDarkMode
                                    ? AppColors.black
                                    : AppColors.white)
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
                                ? (isDarkMode
                                    ? AppColors.black
                                    : AppColors.white)
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
            ...salonDetail.reviews.map((review) {
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
  Widget _buildServicesSection(bool isDarkMode, SalonDetailEntity salonDetail) {
    if (salonDetail.services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.content_cut,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSizes.spaceM),
              Text(
                'No services available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Extract unique categories from services
    final serviceCategories = _getUniqueCategories(salonDetail.services);

    // Add "All" at the beginning
    final categoriesWithAll = ['All', ...serviceCategories];

    final currentCategory = categoriesWithAll[_activeServiceCategoryIndex];

    // Filter services based on selected category
    final filteredServices = currentCategory == 'All'
        ? salonDetail.services
        : salonDetail.services
            .where((service) => service.category == currentCategory)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable category badges
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoriesWithAll.length,
            itemBuilder: (context, index) {
              final category = categoriesWithAll[index];
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
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary)
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
                            ? (isDarkMode
                                ? AppColors.primary
                                : AppColors.primaryDark)
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
    required ServiceEntity service,
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
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusS),
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
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusS),
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
                    : (isDarkMode ? AppColors.primaryDark : AppColors.primary),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.check : Icons.add,
                    color: isSelected
                        ? (isDarkMode ? AppColors.white : AppColors.black)
                        : (isDarkMode ? AppColors.black : AppColors.white),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSelected ? 'Selected' : 'Add',
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? AppColors.white : AppColors.black)
                          : (isDarkMode ? AppColors.black : AppColors.white),
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
                      color: isActive
                          ? (isDarkMode
                              ? AppColors.primaryDark
                              : AppColors.primary)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary)
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
      270.0; // Height for combined sections + tab bar (250 + 56)

  @override
  double get maxExtent => 270.0; // Same as min for fixed height

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
