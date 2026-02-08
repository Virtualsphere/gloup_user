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

  // Carousel images from Unsplash
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
    'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight;
    final carouselHeight = screenHeight * 0.4;
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        children: [
          // Carousel at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
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
          ),

          // Curved overlay card
          Positioned(
            top: carouselHeight - 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusL),
                  topRight: Radius.circular(AppSizes.radiusL),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? AppColors.black.withValues(alpha: 0.3)
                        : AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSizes.heightM,
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
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusL),
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
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusCircular),
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
                    AppSizes.heightL,
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
                    AppSizes.heightXXL,
                    AppSizes.heightXXL,
                    // More content will be added here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
}
