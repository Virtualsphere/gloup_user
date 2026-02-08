import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

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
  int _selectedTabIndex = 0;
  final ScrollController _tabScrollController = ScrollController();
  final ScrollController _contentScrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];

  // Carousel images from Unsplash
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
    'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
  ];

  // Tab items
  final List<String> _tabItems = [
    'Services',
    'About',
    'Ambients',
    'Team',
    'Reviews',
    'Opening Hours',
    'Location',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize section keys
    _sectionKeys.addAll(List.generate(_tabItems.length, (_) => GlobalKey()));

    // Listen to content scroll to update active tab
    _contentScrollController.addListener(_onContentScroll);
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  void _onContentScroll() {
    // Find which section is currently visible
    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          // Check if section is in viewport (with some threshold)
          if (position.dy < 300 && position.dy > -100) {
            if (_selectedTabIndex != i) {
              setState(() {
                _selectedTabIndex = i;
              });
              // Auto scroll tab bar to show active tab
              _scrollToTab(i);
              break;
            }
          }
        }
      }
    }
  }

  void _scrollToTab(int index) {
    if (_tabScrollController.hasClients) {
      final double itemWidth = 120.0; // Approximate tab width
      final double targetScroll = (index * itemWidth) - 50;
      _tabScrollController.animateTo(
        targetScroll.clamp(0.0, _tabScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.4;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          // Fixed carousel
          _buildCarousel(context, carouselHeight, isDarkMode),
          // Overlapping card with collapsible header
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusL),
                topRight: Radius.circular(AppSizes.radiusL),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomScrollView(
              controller: _contentScrollController,
              slivers: [
                // Collapsible title and crown section
                SliverToBoxAdapter(
                  child: _buildTitleAndCrownSection(context, isDarkMode),
                ),
                // Scrollable info section (location, time, languages)
                SliverToBoxAdapter(
                  child: _buildScrollableInfoSection(context, isDarkMode),
                ),
                // Sticky tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: _buildTabBar(isDarkMode),
                    isDarkMode: isDarkMode,
                  ),
                ),
                // Tab content sections
                SliverPadding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _buildTabSections(isDarkMode),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(
      BuildContext context, double carouselHeight, bool isDarkMode) {
    return SizedBox(
      height: carouselHeight,
      child: Stack(
        children: [
          // Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: carouselHeight,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
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
                    decoration: BoxDecoration(
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
          // Carousel indicators
          Positioned(
            bottom: 70,
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

          // Back button
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
          // Share and Favorite buttons (top right)
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
      ),
    );
  }

  Widget _buildTitleAndCrownSection(BuildContext context, bool isDarkMode) {
    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.only(
        left: AppSizes.paddingL,
        right: AppSizes.paddingL,
        top: AppSizes.paddingXL,
        bottom: AppSizes.paddingL,
      ),
      child: Column(
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
      ),
    );
  }

  Widget _buildScrollableInfoSection(BuildContext context, bool isDarkMode) {
    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
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
          AppSizes.heightM,
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? AppColors.textSecondary.withValues(alpha: 0.2)
                : AppColors.textSecondary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _tabScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _tabItems.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
              _scrollToSection(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingL,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _tabItems[index],
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTabSections(bool isDarkMode) {
    return List.generate(_tabItems.length, (index) {
      return Container(
        key: _sectionKeys[index],
        margin: const EdgeInsets.only(bottom: AppSizes.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tabItems[index],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            AppSizes.heightM,
            // Placeholder content for each section
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondary.withValues(alpha: 0.1)
                    : AppColors.textSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Center(
                child: Text(
                  'Content for ${_tabItems[index]}',
                  style: TextStyle(
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
    });
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
}

// Sticky tab bar delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDarkMode;

  _StickyTabBarDelegate({required this.child, required this.isDarkMode});

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child || isDarkMode != oldDelegate.isDarkMode;
  }
}
