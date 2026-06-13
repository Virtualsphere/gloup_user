import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
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
    'Amenities',
    'Team',
    'Reviews',
    'Opening Hours',
    'Location',
  ];

  // Global keys for each section to track their positions
  final Map<String, GlobalKey> _sectionKeys = {
    'Services': GlobalKey(),
    'About': GlobalKey(),
    'Amenities': GlobalKey(),
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
    final carouselHeight =
        screenHeight * SalonDetailDesignTokens.carouselHeightFraction;

    // Check if scrolled past the carousel
    final isCollapsed = _scrollController.hasClients &&
        _scrollController.offset > (carouselHeight * 0.5);

    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
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

      final targetScroll = scrollOffset +
          position.dy -
          (SalonDetailDesignTokens.stickyHeaderExtent +
              SalonDetailDesignTokens.infoSheetOverlap +
              80);

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
    final carouselHeight =
        screenHeight * SalonDetailDesignTokens.carouselHeightFraction;
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
          backgroundColor: isDarkMode
              ? AppColors.surfaceDark
              : SalonDetailDesignTokens.pageBackground,
          bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
          body: Stack(
            children: [
              // Main scrollable content
              CustomScrollView(
                controller: _scrollController,
                clipBehavior: Clip.none,
                slivers: [
                  // SliverAppBar with carousel
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: carouselHeight,
                    collapsedHeight: collapsedHeight,
                    backgroundColor: isDarkMode
                        ? AppColors.surfaceDark
                        : SalonDetailDesignTokens.pageBackground,
                    surfaceTintColor: Colors.transparent,
                    clipBehavior: Clip.none,
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
                        );
                      },
                    ),
                  ),

                  // Sticky Title, Crown, Info Section, and Tab Bar (Combined)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      extent: SalonDetailDesignTokens.stickyHeaderExtent,
                      child: _buildInfoSheet(
                        isDarkMode: isDarkMode,
                        state: state,
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
                                      EdgeInsets.all(AppSizes.paddingXL),
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
                                      _buildSection(
                                          _tabs[_activeTabIndex], isDarkMode, state.salonDetail!),
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
                      EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Container(
                        decoration: BoxDecoration(
                          color: _isCollapsed
                              ? Colors.transparent
                              : SalonDetailDesignTokens.heroControlBg,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(AppSizes.paddingXS),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: _isCollapsed
                                ? (isDarkMode
                                    ? AppColors.white
                                    : AppColors.black)
                                : SalonDetailDesignTokens.heroControlIcon,
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
                                  : SalonDetailDesignTokens.heroControlBg,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.all(AppSizes.paddingXS),
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.share,
                                color: _isCollapsed
                                    ? (isDarkMode
                                        ? AppColors.white
                                        : AppColors.black)
                                    : SalonDetailDesignTokens.heroControlIcon,
                                size: AppSizes.iconS,
                              ),
                              onPressed: () {
                                // TODO: Implement share functionality
                              },
                            ),
                          ),
                          SizedBox(width: AppSizes.spaceS),
                          // Favorite button
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: _isCollapsed
                          //         ? Colors.transparent
                          //         : AppColors.black.withValues(alpha: 0.5),
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child:
                          //       BlocBuilder<SalonDetailBloc, SalonDetailState>(
                          //     builder: (context, state) {
                          //       return IconButton(
                          //         padding:
                          //             EdgeInsets.all(AppSizes.paddingXS),
                          //         constraints: const BoxConstraints(),
                          //         icon: SvgPicture.asset(
                          //           state.isFavorite
                          //               ? 'assets/icons/ic_heart_fill.svg'
                          //               : 'assets/icons/ic_heart.svg',
                          //           width: AppSizes.iconS,
                          //           height: AppSizes.iconS,
                          //           colorFilter: ColorFilter.mode(
                          //             state.isFavorite
                          //                 ? Colors.red
                          //                 : (_isCollapsed
                          //                     ? (isDarkMode
                          //                         ? AppColors.white
                          //                         : AppColors.black)
                          //                     : AppColors.white),
                          //             BlendMode.srcIn,
                          //           ),
                          //         ),
                          //         onPressed: () {
                          //           context
                          //               .read<SalonDetailBloc>()
                          //               .add(const ToggleFavoriteEvent());
                          //         },
                          //       );
                          //     },
                          //   ),
                          // ),
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
      clipBehavior: Clip.none,
      children: [
        // Carousel images - extended down by the radius amount to sit behind the corners
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -SalonDetailDesignTokens.infoSheetTopRadius,
          child: CarouselSlider(
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
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          memCacheWidth: 800,
                          memCacheHeight: 800,
                          errorWidget: (context, url, error) {
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
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: -SalonDetailDesignTokens.infoSheetTopRadius,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: SalonDetailDesignTokens.carouselGradient,
            ),
          ),
        ),

        if (isFullyExpanded && images.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                final isActive = _currentImageIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: isActive
                        ? SalonDetailDesignTokens.dotActive
                        : SalonDetailDesignTokens.dotTrack,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Figma — white sheet with 32px top radius overlapping hero.
  Widget _buildInfoSheet({
    required bool isDarkMode,
    required SalonDetailState state,
  }) {
    final sheetColor = isDarkMode
        ? AppColors.surfaceDark
        : SalonDetailDesignTokens.pageBackground;

    // No Transform.translate here — it breaks SliverPersistentHeader geometry.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(SalonDetailDesignTokens.infoSheetTopRadius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SalonDetailDesignTokens.infoSheetTopRadius),
          ),
          boxShadow:
              isDarkMode ? null : SalonDetailDesignTokens.infoSheetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: state.isLoading || state.salonDetail == null
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.padding,
                          AppSizes.paddingS,
                          AppSizes.padding,
                          0,
                        ),
                        child: SalonDetailsShimmers.buildHeaderShimmer(
                          context,
                          isDarkMode,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.padding,
                          AppSizes.paddingS,
                          AppSizes.padding,
                          0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndCrownSection(
                              context,
                              isDarkMode,
                              state.salonDetail!,
                            ),
                            const SizedBox(
                              height:
                                  SalonDetailDesignTokens.infoSheetSectionGap,
                            ),
                            _buildInfoSection(
                              context,
                              isDarkMode,
                              state.salonDetail!,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            _buildTabBar(context, isDarkMode),
          ],
        ),
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
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  height: 28 / 18,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : const Color(0xFF171717),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // NEW Badge
            if (salonDetail.isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C8CE9),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    height: 15 / 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4), // Info sheet gap will handle the rest, let's keep a small gap or use the design token
        // Rating with crown and Gender
        Row(
          children: [
            // Premium crown badge
            if (salonDetail.isPremium)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFC02E),
                      Color(0xFFC88C00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_crown.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            if (salonDetail.isPremium) const SizedBox(width: 12),
            // Rating badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0x1A21C45D)
                    : const Color(0x1A21C45D), // rgba(33, 196, 93, 0.1)
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC02E),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    salonDetail.rating.toString(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: isDarkMode
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${salonDetail.reviewCount})',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildSalonGenderTag(salonDetail.gender, isDarkMode),
          ],
        ),
      ],
    );
  }

  /// Salon header gender: unisex → both icons; men → male; women → female.
  Widget _buildSalonGenderTag(String gender, bool isDarkMode) {
    final normalized = gender.toLowerCase().trim();
    final labelColor = isDarkMode
        ? AppColors.textSecondaryDark
        : const Color(0xFF727272);

    final List<Widget> icons;
    if (normalized.contains('unisex')) {
      icons = [
        SvgPicture.asset(AppIcons.icMale, width: 20, height: 20, fit: BoxFit.fitHeight),
        SvgPicture.asset(AppIcons.icFemale, width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else if ((normalized.contains('male') || normalized.contains('men')) &&
        !normalized.contains('women') &&
        !normalized.contains('female')) {
      icons = [
        SvgPicture.asset(AppIcons.icMale, width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else if (normalized.contains('women') || normalized.contains('female')) {
      icons = [
        SvgPicture.asset(AppIcons.icFemale, width: 20, height: 20, fit: BoxFit.fitHeight),
      ];
    } else {
      icons = [
        Icon(Icons.wc, size: 20, color: labelColor),
      ];
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...icons,
        const SizedBox(width: 4),
        Text(
          gender,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: labelColor,
            height: 24 / 12,
          ),
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
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SvgPicture.asset(
                'assets/icons/ic_location.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                salonDetail.address,
                style: GoogleFonts.inter(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 20 / 12,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Info Sheet row gap
        // Open status and timing
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_clock.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF737373),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            if (salonDetail.openingTime.isNotEmpty &&
                salonDetail.closingTime.isNotEmpty) ...[
              Text(
                '${salonDetail.isOpen ? 'Open' : 'Closed'} · ${salonDetail.openingTime} - ${salonDetail.closingTime}',
                style: GoogleFonts.inter(
                  color: salonDetail.isOpen ? const Color(0xFF21C45D) : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                ),
              ),
            ] else ...[
              Text(
                'Hours not set',
                style: GoogleFonts.inter(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF737373),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 16 / 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Languages
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_translate.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                isDarkMode
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF737373),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: salonDetail.languages.isEmpty
                  ? Text(
                      'Language not set',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF737373),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 20 / 12,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
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
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFFEDEDED).withValues(alpha: 0.2)
            : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        language,
        style: GoogleFonts.inter(
          color: isDarkMode
              ? AppColors.textSecondaryDark
              : const Color(0xFF737373),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 15 / 10,
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
                  bottom:
                      AppSizes.paddingM + MediaQuery.of(context).padding.bottom,
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
                                      'originalPrice': service.originalPrice,
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
                                      'originalPrice': service.originalPrice,
                                      'duration': service.duration,
                                      'discountPercentage':
                                          service.discountPercentage,
                                      'isPopular': service.isPopular,
                                    })
                                .toList()
                          };

                          // print('salonData: $salonData');

                          context.pushNamed(
                            RouteNames.slotBooking,
                            extra: salonData,
                          );
                        },
                        backgroundColor: isDarkMode
                            ? AppColors.primary
                            : AppColors.onPrimary,
                        textColor: isDarkMode
                            ? AppColors.onPrimary
                            : AppColors.primary,
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
      padding: EdgeInsets.symmetric(
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
          else if (title == 'Amenities')
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

  // Build a content section (Services: chips + cards only — tabs are the nav)
  Widget _buildSection(
      String title, bool isDarkMode, SalonDetailEntity salonDetail) {
    final isServices = title == 'Services';

    return Container(
      key: _sectionKeys[title],
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingM,
        isServices ? 12 : AppSizes.paddingM,
        AppSizes.paddingM,
        AppSizes.paddingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isServices) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : SalonDetailDesignTokens.textPrimary,
                  ),
                ),
                if (title == 'Team' || title == 'Reviews')
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : SalonDetailDesignTokens.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (title == 'Services')
            _buildServicesSection(isDarkMode, salonDetail)
          else if (title == 'About')
            _buildAboutSection(isDarkMode, salonDetail)
          else if (title == 'Amenities')
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
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
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
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
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
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
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
      salonName: salonDetail.name,
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
          margin: EdgeInsets.only(bottom: AppSizes.paddingS),
          padding: EdgeInsets.all(AppSizes.paddingM),
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
              SizedBox(width: AppSizes.paddingM),
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
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
              Text(
                'No reviews yet',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: AppSizes.spaceS),
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
                  margin: EdgeInsets.only(right: AppSizes.paddingM),
                  padding: EdgeInsets.symmetric(
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
                padding: EdgeInsets.symmetric(
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
                  SizedBox(width: AppSizes.spaceS),
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
          padding: EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              Icon(
                Icons.content_cut,
                size: 48,
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSizes.spaceM),
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

    // Build tabs: Featured + unique categories from services
    final serviceCategories = _getUniqueCategories(salonDetail.services);
    final categoriesWithAll = ['Featured', ...serviceCategories];

    final currentCategory = categoriesWithAll[
        _activeServiceCategoryIndex.clamp(0, categoriesWithAll.length - 1)];

    // Filter services based on selected category
    List<ServiceEntity> filteredServices;
    if (currentCategory == 'Featured') {
      // Show popular services first, then all
      final popular =
          salonDetail.services.where((s) => s.isPopular).toList();
      final others =
          salonDetail.services.where((s) => !s.isPopular).toList();
      filteredServices = [...popular, ...others];
    } else {
      filteredServices = salonDetail.services
          .where((service) => service.category == currentCategory)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  margin: EdgeInsets.only(right: AppSizes.paddingS),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDarkMode
                            ? AppColors.primaryDark
                            : SalonDetailDesignTokens.textPrimary)
                        : (isDarkMode
                            ? AppColors.textSecondary.withValues(alpha: 0.15)
                            : SalonDetailDesignTokens.chipCategoryBg),
                    borderRadius: BorderRadius.circular(99),
                    border: isActive
                        ? null
                        : Border.all(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : SalonDetailDesignTokens.serviceCardBorder,
                            width: 1,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isActive
                            ? Colors.white
                            : (isDarkMode
                                ? AppColors.textSecondaryDark
                                : SalonDetailDesignTokens.chipCategoryText),
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredServices
              .map((service) => _buildServiceCardWithCallback(
                    service: service,
                    isDarkMode: isDarkMode,
                    salonGender: salonDetail.gender,
                  ))
              .toList(),
        ),
      ],
    );
  }

  /// Figma 2573:5136 — male/female icon + card tint
  String _resolveServiceGender(ServiceEntity service, String salonGender) {
    final raw = service.serviceFor?.toLowerCase().trim();
    if (raw != null && raw.isNotEmpty) {
      if (raw.contains('female') || raw == 'women' || raw == 'f') {
        return 'female';
      }
      if (raw.contains('male') || raw == 'men' || raw == 'm') {
        return 'male';
      }
    }

    final name = service.name.toLowerCase();
    if (RegExp(r'\bfemale\b').hasMatch(name) || name.contains(' women')) {
      return 'female';
    }
    if (RegExp(r'\bmale\b').hasMatch(name) && !name.contains('female')) {
      return 'male';
    }

    final salon = salonGender.toLowerCase();
    if (salon.contains('women') || salon.contains('female')) {
      return 'female';
    }
    if (salon.contains('men') || salon.contains('male')) {
      return 'male';
    }
    return 'male';
  }

  String _formatDiscountLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return raw.trim();
    return '$cleaned% off';
  }

  Widget _buildServiceGenderIcon(String gender) {
    return SvgPicture.asset(
      gender == 'female' ? AppIcons.icFemale : AppIcons.icMale,
      height: 18,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _buildDiscountSeal() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: SalonDetailDesignTokens.priceGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '%',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildServiceCardWithCallback({
    required ServiceEntity service,
    required bool isDarkMode,
    required String salonGender,
  }) {
    final isSelected = _selectedServices.containsKey(service.id);
    final gender = _resolveServiceGender(service, salonGender);
    final hasStrikePrice = service.originalPrice != null &&
        service.originalPrice! > service.price;
    final showGreenPrice = hasStrikePrice || service.isPopular;

    final cardBg = isDarkMode
        ? AppColors.surfaceDark.withValues(alpha: 0.5)
        : (service.isPopular
            ? SalonDetailDesignTokens.serviceCardPopularBg
            : SalonDetailDesignTokens.serviceCardDefaultBg);

    final primaryText = isDarkMode
        ? AppColors.textPrimaryDark
        : const Color(0xFF171717);
    final secondaryText = isDarkMode
        ? AppColors.textSecondaryDark
        : const Color(0xFF737373);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? SalonDetailDesignTokens.accentBlue.withValues(alpha: 0.4)
              : const Color(0xFFE6E6E6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildServiceGenderIcon(gender),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        service.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (service.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A0C8CE9), // rgba(12, 140, 233, 0.1)
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0C8CE9),
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            height: 14 / 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.icClock,
                      width: 12,
                      height: 12,
                      colorFilter: ColorFilter.mode(
                        secondaryText,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      service.duration,
                      style: GoogleFonts.inter(
                        color: secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹${service.price.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 20 / 14,
                        color: showGreenPrice
                            ? SalonDetailDesignTokens.priceGreen
                            : primaryText,
                      ),
                    ),
                    if (hasStrikePrice) ...[
                      const SizedBox(width: 4),
                      Text(
                        '₹${service.originalPrice!.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF727272),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFF727272),
                          height: 20 / 10,
                        ),
                      ),
                    ],
                    if (service.discountPercentage != null &&
                        service.discountPercentage!.trim().isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SalonDetailDesignTokens.discountBadgeBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDiscountSeal(),
                            const SizedBox(width: 4),
                            Text(
                              _formatDiscountLabel(
                                service.discountPercentage,
                              ),
                              style: GoogleFonts.inter(
                                color: SalonDetailDesignTokens.priceGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                height: 20 / 10,
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
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _toggleService(service),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                        ? AppColors.borderDark.withValues(alpha: 0.6)
                        : SalonDetailDesignTokens.addedButtonBg)
                    : const Color(0xFF171717),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDarkMode
                          ? AppColors.borderDark
                          : SalonDetailDesignTokens.addedButtonBorder)
                      : const Color(0xFF171717),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSelected) ...[
                    const Icon(Icons.add, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Add',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Added',
                      style: GoogleFonts.inter(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : SalonDetailDesignTokens.addedButtonText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.check,
                      size: 14,
                      color: isDarkMode
                          ? AppColors.textSecondaryDark
                          : SalonDetailDesignTokens.addedButtonText,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build horizontal scrollable tab bar
  Widget _buildTabBar(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.surfaceDark
            : SalonDetailDesignTokens.pageBackground,
        border: const Border(
          bottom: BorderSide(
            color: SalonDetailDesignTokens.tabBarDivider,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = _activeTabIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _activeTabIndex = index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: 6,
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
  final double extent;

  _StickyHeaderDelegate({
    required this.child,
    required this.extent,
  });

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Child must report [extent] height so pinned overlap geometry stays valid
    // (layoutExtent must not exceed paintExtent when only tabs would shrink-wrap).
    return SizedBox(
      height: extent,
      width: double.infinity,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return extent != oldDelegate.extent || child != oldDelegate.child;
  }
}
