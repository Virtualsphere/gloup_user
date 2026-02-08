import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tressy/core/constants/app_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

class SalonCard extends StatefulWidget {
  final String salonName;
  final String salonImage;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double distance;
  final bool isPremium;
  final bool isFavorite;
  final String? serviceName;
  final double? servicePrice;
  final List<String>? categories;
  final List<String>? languageCodes;
  final bool isFullWidth;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const SalonCard({
    super.key,
    required this.salonName,
    required this.salonImage,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distance = 0.0,
    this.isPremium = false,
    this.isFavorite = false,
    this.serviceName,
    this.servicePrice,
    this.categories,
    this.languageCodes,
    this.isFullWidth = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<SalonCard> createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard> {
  int _currentImageIndex = 0;
  late bool _isFavorite;

  // Language icon paths map
  static const Map<String, String> languageIcons = {
    'ta': AppIcons.icTamil,
    'ml': AppIcons.icMalayalam,
    'hi': AppIcons.icHindi,
    'te': AppIcons.icTelugu,
    'kn': AppIcons.icKannada,
    'bn': AppIcons.icBengali,
    'gu': AppIcons.icGujarati,
    'en': AppIcons.icEnglish,
  };

  String? getLanguageIcon(String languageCode) {
    return languageIcons[languageCode];
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        width: widget.isFullWidth ? double.infinity : 320,
        margin: widget.isFullWidth 
            ? EdgeInsets.zero
            : const EdgeInsets.only(right: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          // border: Border.all(
          //   color: AppColors.border,
          //   width: 1,
          // ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageCarousel(),
            SizedBox(height: widget.isFullWidth ? AppSizes.spaceL : AppSizes.spaceM),
            _buildSalonInfo(),
            SizedBox(height: widget.isFullWidth ? AppSizes.spaceM : AppSizes.spaceS),
            _buildRatingAndDistance(),
            SizedBox(height: widget.isFullWidth ? AppSizes.spaceL : AppSizes.spaceS),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        // Carousel images
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusM),
            topRight: Radius.circular(AppSizes.radiusM),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1.0,
              enableInfiniteScroll: widget.images.length > 1,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.images.map((imageUrl) {
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
                            size: 50,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        // Premium crown badge (top left)
        if (widget.isPremium)
          Positioned(
            top: AppSizes.paddingS,
            left: AppSizes.paddingS,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC02E),
                    Color(0xFFC88C00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC02E).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.icCrown,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        // Favorite heart button (top right)
        Positioned(
          top: AppSizes.paddingS,
          right: AppSizes.paddingS,
          child: InkWell(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              widget.onFavoriteToggle?.call();
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                _isFavorite
                    ? 'assets/icons/ic_heart_fill.svg'
                    : 'assets/icons/ic_heart.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  _isFavorite ? Colors.red : AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        // Carousel indicators (left side)
        if (widget.images.length > 1)
          Positioned(
            bottom: AppSizes.paddingS,
            left: AppSizes.paddingS,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.images.asMap().entries.map((entry) {
                return Container(
                  width: _currentImageIndex == entry.key ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentImageIndex == entry.key
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),
        // Service badge (right side)
        if (widget.serviceName != null && widget.servicePrice != null)
          Positioned(
            bottom: AppSizes.paddingS,
            right: AppSizes.paddingS,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.serviceName!,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Text(
                    '₹${widget.servicePrice!.toInt()}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSalonInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon circular image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                widget.salonImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceS),
          // Salon name and rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.salonName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceS),
          // Rating
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFA500), // Orange/Gold for rating
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.rating.toStringAsFixed(1),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontM,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '(${widget.reviewCount})',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontXS,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingAndDistance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location row
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Koramangala, Bengalore',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Distance
              Text(
                '${widget.distance.toStringAsFixed(1)} KM',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),
          // Language and Category badges row (separate)
          if ((widget.languageCodes != null && widget.languageCodes!.isNotEmpty) ||
              (widget.categories != null && widget.categories!.isNotEmpty)) ...[
            const SizedBox(height: AppSizes.spaceS),
            Row(
              children: [
                _buildLanguageBadges(),
                const Spacer(),
                _buildCategoryBadges(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageBadges() {
    final languageCodes = widget.languageCodes ?? [];
    // Filter only languages that have icons available
    final availableLanguages = languageCodes
        .where((code) => getLanguageIcon(code) != null)
        .toList();
    
    if (availableLanguages.isEmpty) return const SizedBox.shrink();
    
    final displayLanguages = availableLanguages.take(3).toList();
    final hasMoreLanguages = availableLanguages.length > 3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Language badges (max 2)
        ...displayLanguages.asMap().entries.map((entry) {
          final languageCode = entry.value;
          final index = entry.key;
          final iconPath = getLanguageIcon(languageCode);
          if (iconPath == null) return const SizedBox.shrink();
          
          return Padding(
            padding: EdgeInsets.only(right: index < displayLanguages.length - 1 ? 10 : 6),
            child: SvgPicture.asset(
              iconPath,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          );
        }),
        // More languages indicator
        // if (hasMoreLanguages)
        //   Padding(
        //     padding: const EdgeInsets.only(right: 6),
        //     child: Text(
        //       '+${availableLanguages.length - 2}',
        //       style: context.textTheme.bodySmall?.copyWith(
        //         color: AppColors.primary,
        //         fontSize: 16,
        //         fontWeight: FontWeight.w700,
        //         height: 1.2,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildCategoryBadges() {
    final categories = widget.categories ?? [];
    final displayCategories = categories.take(2).toList();
    final hasMoreCategories = categories.length > 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category badges
        ...displayCategories.map((category) => Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: Text(
                category,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        if (hasMoreCategories)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            ),
            child: Text(
              '+${categories.length - 2}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
