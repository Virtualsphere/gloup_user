import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/features/salon_details/presentation/widgets/service_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/ambient_card.dart';
import 'package:tressy/features/salon_details/presentation/widgets/team_member_card.dart';
import 'package:tressy/shared/widgets/review_summary_widget.dart';
import 'package:tressy/shared/widgets/review_card.dart';

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
  int _activeReviewFilterIndex = 0; // For review filter badges (0 = All, 1-5 = stars)

  // Carousel images from Unsplash
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
    'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
  ];

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

  // Service categories
  final List<String> _serviceCategories = [
    'Featured',
    'Combo Offers',
    'Men\'s Package',
    'Women\'s Package',
    'Hair Styling',
    'Spa & Massage',
    'Facial',
    'Makeup',
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.30;

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
        final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
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
      final RenderBox renderBox = key!.currentContext!.findRenderObject() as RenderBox;
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
    final carouselHeight = screenHeight * 0.30;
    final collapsedHeight = screenHeight * 0.08; // 8% when collapsed
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
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
                  background: _buildCarousel(
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
                    Padding(
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
              children: _tabs.map((tab) => _buildSection(tab, isDarkMode)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, double carouselHeight,
      bool isDarkMode, bool isFullyExpanded) {
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
          items: _carouselImages.map((imageUrl) {
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
        if (isFullyExpanded)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _carouselImages.asMap().entries.map((entry) {
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
                'Luxury Hair & Spa Studio',
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
            AppSizes.widthM,
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
                    '4.5',
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
                    '(201)',
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
                  'Unisex',
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
                '123 Main Street, Downtown Area, City Center, State 12345',
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
              'Open',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
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
              '06:30 AM - 9:30 PM',
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
                children: [
                  _buildLanguageBadge('Tamil', isDarkMode),
                  _buildLanguageBadge('English', isDarkMode),
                  _buildLanguageBadge('Hindi', isDarkMode),
                ],
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
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
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
    return Text(
      'We offer premium salon and spa services exclusively for men. Our experienced team provides top-quality haircuts, grooming, facials, and relaxation treatments in a modern, comfortable environment. Walk-ins welcome.',
      textAlign: TextAlign.left,
      style: context.textTheme.bodyMedium?.copyWith(
        color: isDarkMode
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  // Build Ambients section
  Widget _buildAmbientsSection(bool isDarkMode) {
    final List<Map<String, dynamic>> ambients = [
      {'icon': Icons.wifi, 'label': 'Free WiFi'},
      {'icon': Icons.ac_unit, 'label': 'Air Conditioned'},
      {'icon': Icons.local_parking, 'label': 'Parking Available'},
      {'icon': Icons.credit_card, 'label': 'Card Payment'},
      {'icon': Icons.wheelchair_pickup, 'label': 'Wheelchair Accessible'},
      {'icon': Icons.coffee, 'label': 'Complimentary Beverages'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 3 cards per row
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingM * 2)) / 3;

        return Wrap(
          spacing: AppSizes.paddingM,
          runSpacing: AppSizes.paddingM,
          children: ambients.map((ambient) {
            return SizedBox(
              width: cardWidth,
              child: AmbientCard(
                icon: ambient['icon'] as IconData,
                label: ambient['label'] as String,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Build Team section
  Widget _buildTeamSection(bool isDarkMode) {
    final List<Map<String, String>> teamMembers = [
      {
        'name': 'John Doe',
        'role': 'Senior Stylist',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      },
      {
        'name': 'Mike Smith',
        'role': 'Hair Specialist',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      },
      {
        'name': 'David Brown',
        'role': 'Barber',
        'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      },
      {
        'name': 'Robert Wilson',
        'role': 'Spa Therapist',
        'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for 4 profiles per row
        final cardWidth = (constraints.maxWidth - (AppSizes.paddingL * 3)) / 4;

        return Wrap(
          spacing: AppSizes.paddingL,
          runSpacing: AppSizes.paddingL,
          children: teamMembers.map((member) {
            return SizedBox(
              width: cardWidth,
              child: TeamMemberCard(
                name: member['name']!,
                role: member['role']!,
                imageUrl: member['image']!,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Build Opening Hours section
  Widget _buildOpeningHoursSection(bool isDarkMode) {
    // Get current day
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    
    final List<Map<String, dynamic>> openingHours = [
      {'day': 'Monday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 1},
      {'day': 'Tuesday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 2},
      {'day': 'Wednesday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 3},
      {'day': 'Thursday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 4},
      {'day': 'Friday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 5},
      {'day': 'Saturday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 6},
      {'day': 'Sunday', 'hours': '6:00 AM - 9:00 PM', 'dayNumber': 7},
    ];

    return Column(
      children: openingHours.map((dayInfo) {
        final isToday = dayInfo['dayNumber'] == today;

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
                              text: '${dayInfo['day']} ',
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
                        dayInfo['day'] as String,
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
                dayInfo['hours'] as String,
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
    final Map<int, int> starCounts = {
      5: 120,
      4: 50,
      3: 20,
      2: 8,
      1: 3,
    };
    final int totalReviews = 201;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Review summary
        ReviewSummaryWidget(
          averageRating: 4.5,
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
                    borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
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
                          index == 0 ? '$label ($count)' : '${6 - index} ($count)',
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
            ReviewCard(
              userName: 'John Doe',
              timeAgo: '2 days ago',
              rating: 5.0,
              reviewText: 'Excellent service! The staff was very professional and friendly. My haircut turned out perfect. Highly recommend this salon!',
            ),
            ReviewCard(
              userName: 'Sarah Miller',
              userImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
              timeAgo: '5 days ago',
              rating: 4.5,
              reviewText: 'Great experience overall. The ambiance is nice and the service was good. Will definitely come back!',
            ),
            ReviewCard(
              userName: 'Mike Johnson',
              timeAgo: '1 week ago',
              rating: 5.0,
              reviewText: 'Best salon in town! The stylist really understood what I wanted. Very happy with the result.',
            ),
            ReviewCard(
              userName: 'Emily Davis',
              userImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
              timeAgo: '2 weeks ago',
              rating: 4.0,
              reviewText: 'Good service and reasonable prices. The place is clean and well-maintained.',
            ),
            ReviewCard(
              userName: 'Robert Brown',
              timeAgo: '3 weeks ago',
              rating: 5.0,
              reviewText: 'Amazing experience! The team is skilled and attentive. Highly recommended!',
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrollable category badges
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _serviceCategories.length,
            itemBuilder: (context, index) {
              final category = _serviceCategories[index];
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
                    borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
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
          children: [
            ServiceCard(
              serviceName: "Men's Haircut",
              duration: '30 min',
              price: 299,
              isPopular: true,
            ),
            ServiceCard(
              serviceName: "Hair Styling & Spa Treatment",
              duration: '45 min',
              price: 599,
              originalPrice: 799,
              discountPercentage: '25%',
            ),
            ServiceCard(
              serviceName: "Beard Trim & Styling",
              duration: '20 min',
              price: 149,
            ),
            ServiceCard(
              serviceName: "Premium Hair Color",
              duration: '90 min',
              price: 1499,
              originalPrice: 1999,
              discountPercentage: '25%',
              isPopular: true,
            ),
            ServiceCard(
              serviceName: "Hair Spa & Deep Conditioning",
              duration: '60 min',
              price: 899,
            ),
          ],
        ),
      ],
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
  double get minExtent => 280.0; // Height for combined sections + tab bar (250 + 56)

  @override
  double get maxExtent => 280.0; // Same as min for fixed height

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
