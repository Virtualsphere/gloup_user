import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:tressy/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/responsive_ellipsis_text.dart';
import 'package:tressy/shared/widgets/salon_location_row.dart';
import 'package:tressy/shared/widgets/login_bottom_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExploreSalonCard extends StatefulWidget {
  final int storeId;
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
  final String? address;
  final List<String>? categories;
  final List<String>? languageCodes;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showDistance; // New parameter to hide/show distance

  const ExploreSalonCard({
    super.key,
    required this.storeId,
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
    this.address,
    this.categories,
    this.languageCodes,
    this.onTap,
    this.onFavoriteToggle,
    this.showDistance = true, // Default to showing distance
  });

  @override
  State<ExploreSalonCard> createState() => _ExploreSalonCardState();
}

class _ExploreSalonCardState extends State<ExploreSalonCard> {
  int _currentImageIndex = 0;

  void _handleFavoriteToggle() {
    // Check if user is authenticated
    final isAuthenticated = LocalStorageService.accessToken != null &&
        LocalStorageService.accessToken!.isNotEmpty;

    if (!isAuthenticated) {
      // Show login bottom sheet
      LoginBottomSheet.show(context);
      return;
    }

    // Toggle favorite via BLoC
    context.read<FavoritesBloc>().add(
          ToggleFavoriteEvent(widget.storeId, widget.isFavorite),
        );

    // Call optional callback
    widget.onFavoriteToggle?.call();
  }

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
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        // Use optimistic update if available, otherwise use server data
        final isFavorite =
            favoritesState.isFavorite(widget.storeId, widget.isFavorite);

        // Check if this specific card is loading
        final isLoading = favoritesState.status == FavoritesStatus.loading &&
            favoritesState.lastToggledStoreId == widget.storeId;

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              // border: Border.all(
              //   color: isDarkMode
              //       ? AppColors.white.withValues(alpha: 0.08)
              //       : AppColors.black.withValues(alpha: 0.08),
              //   width: 1,
              // ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? AppColors.white.withValues(alpha: 0.08)
                      : AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image carousel
                _buildImageCarousel(isDarkMode),
                SizedBox(width: AppSizes.spaceM),
                // Right side - Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: AppSizes.paddingM,
                      right: AppSizes.paddingM,
                      bottom: AppSizes.paddingM,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSalonInfo(isDarkMode, isFavorite, isLoading),
                        SizedBox(height: AppSizes.spaceS),
                        _buildRatingAndDistance(
                            isDarkMode, widget.showDistance),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel(bool isDarkMode) {
    return SizedBox(
      width: 130.w,
      height: 150.h, // Add fixed height to prevent infinite height error
      child: Stack(
        children: [
          // Carousel images
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusS),
              bottomLeft: Radius.circular(AppSizes.radiusS),
            ),
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
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
                        color: isDarkMode
                            ? AppColors.primaryDark.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        memCacheWidth: 260,
                        memCacheHeight: 300,
                        errorWidget: (context, url, error) {
                          return Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.content_cut,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  size: 32.w,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No image',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    fontSize: 9.sp,
                                  ),
                                ),
                              ],
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
              top: AppSizes.paddingXS,
              left: AppSizes.paddingXS,
              child: Container(
                width: 28.w,
                height: 28.h,
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
                    width: 14.w,
                    height: 14.h,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          // Carousel indicators (bottom center)
          if (widget.images.length > 1)
            Positioned(
              bottom: AppSizes.paddingXS,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: widget.images.asMap().entries.map((entry) {
                  return Container(
                    width: _currentImageIndex == entry.key ? 14.w : 4.w,
                    height: 4.h,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: _currentImageIndex == entry.key
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Service badge (bottom right - inside image)
          if (widget.serviceName != null && widget.servicePrice != null)
            Positioned(
              bottom: AppSizes.paddingXS,
              right: AppSizes.paddingXS,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                constraints: BoxConstraints(maxWidth: 130.w),
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
                    Container(
                      constraints: BoxConstraints(maxWidth: 70.w),
                      child: Text(
                        widget.serviceName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 2.5.w,
                        height: 2.5.h,
                        decoration: const BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      '₹${widget.servicePrice!.toInt()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                        color: AppColors.primary,
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

  Widget _buildSalonInfo(bool isDarkMode, bool isFavorite, bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ResponsiveEllipsisText(
            text: widget.salonName,
            maxLines: 2,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(width: AppSizes.spaceS),
        // Favorite heart button
        InkWell(
          onTap: isLoading ? null : _handleFavoriteToggle,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                  )
                : SvgPicture.asset(
                    isFavorite
                        ? 'assets/icons/ic_heart_fill.svg'
                        : 'assets/icons/ic_heart.svg',
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(
                      isFavorite ? Colors.red : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndDistance(bool isDarkMode, bool showDistance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating and review count
        Row(
          children: [
            Icon(
              Icons.star,
              color: const Color(0xFFFFA500),
              size: 16.w,
            ),
            const SizedBox(width: 4),
            Text(
              widget.rating.toStringAsFixed(1),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${widget.reviewCount} reviews)',
              style: context.textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceXS),
        SalonLocationRow(
          locationLabel: widget.address,
          distanceKm: widget.distance,
          showDistance: showDistance,
          isDarkMode: isDarkMode,
        ),
        SizedBox(height: AppSizes.spaceS),
        // Language and Category badges row
        Row(
          children: [
            _buildLanguageBadges(isDarkMode),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildCategoryBadges(isDarkMode),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageBadges(bool isDarkMode) {
    final languageCodes = widget.languageCodes ?? [];

    // If no languages found, show default 'en' and 'ta'
    final displayLanguages =
        languageCodes.isEmpty ? ['en', 'ta'] : languageCodes.take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Language badges (max 2 for grid layout)
        ...displayLanguages.asMap().entries.expand((entry) {
          final languageCode = entry.value;
          final index = entry.key;
          final iconPath = getLanguageIcon(languageCode);
          final isLast = index == displayLanguages.length - 1;

          final icon = iconPath != null
              ? SvgPicture.asset(
                  iconPath,
                  width: 11.w,
                  height: 11.h,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                )
              : Container(
                  width: 11.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      languageCode.length >= 2
                          ? languageCode.substring(0, 2).toUpperCase()
                          : languageCode.toUpperCase(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

          return [
            icon,
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ];
        }),
      ],
    );
  }

  Widget _buildCategoryBadges(bool isDarkMode) {
    final categories = (widget.categories == null || widget.categories!.isEmpty)
        ? ['Haircut', 'Facial']
        : widget.categories!;
    final displayCategories = categories.take(1).toList();
    final hasMoreCategories = categories.length > 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category badges
        ...displayCategories.map((category) => Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 80.w),
                margin: const EdgeInsets.only(left: 4),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1FE),
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                ),
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8F89CA),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
        if (hasMoreCategories)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
                  : AppColors.textSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            ),
            child: Text(
              '+${categories.length - 2}',
              style: context.textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
