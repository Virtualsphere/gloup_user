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
import 'package:tressy/shared/widgets/login_bottom_sheet.dart';
import 'package:tressy/shared/widgets/responsive_ellipsis_text.dart';
import 'package:tressy/shared/widgets/salon_location_row.dart';
import 'package:tressy/shared/widgets/salon_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalonCard extends StatefulWidget {
  final int storeId; // Added store ID for API
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
  final bool isFullWidth;
  final bool isOfferCard;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const SalonCard({
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
    this.isFullWidth = false,
    this.isOfferCard = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<SalonCard> createState() => _SalonCardState();
}

class _SalonCardState extends State<SalonCard> {
  int _currentImageIndex = 0;

  List<String> get _displayImages {
    final fromList =
        widget.images.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (fromList.isNotEmpty) return fromList;
    final primary = widget.salonImage.trim();
    if (primary.isNotEmpty) return [primary];
    return [];
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

  void _handleFavoriteToggle() {
    // Check if user is authenticated
    final isAuthenticated = LocalStorageService.accessToken != null &&
        LocalStorageService.accessToken!.isNotEmpty;

    if (!isAuthenticated) {
      // Show login bottom sheet
      LoginBottomSheet.show(context);
      return;
    }

    // Toggle favorite via BLoC, passing current state
    context.read<FavoritesBloc>().add(
          ToggleFavoriteEvent(widget.storeId, widget.isFavorite),
        );

    // Call optional callback
    widget.onFavoriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    // Removed BlocListener - toasts are now handled by parent page
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
            width: widget.isFullWidth ? double.infinity : 310.w,
            margin: widget.isFullWidth
                ? EdgeInsets.zero
                : EdgeInsets.only(right: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? AppColors.white.withValues(alpha: 0.08)
                      : AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildImageCarousel(isFavorite, isLoading, isDarkMode),
                SizedBox(
                    height:
                        widget.isFullWidth ? AppSizes.spaceL : AppSizes.spaceM),
                _buildSalonInfo(isDarkMode),
                // Spacer(),
                SizedBox(
                    height:
                        widget.isFullWidth ? AppSizes.spaceM : AppSizes.spaceS),
                _buildRatingAndDistance(isDarkMode),
                SizedBox(
                    height:
                        widget.isFullWidth ? AppSizes.spaceL : AppSizes.spaceS),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel(bool isFavorite, bool isLoading, bool isDarkmode) {
    final images = _displayImages;

    return Stack(
      children: [
        // Carousel images
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusM),
            topRight: Radius.circular(AppSizes.radiusM),
          ),
          child: images.isEmpty
              ? SizedBox(
                  height: 150.h,
                  width: double.infinity,
                  child: SalonNetworkImage(
                    imageUrl: '',
                    height: 150.h,
                    logTag: 'SalonCard',
                  ),
                )
              : CarouselSlider(
                  options: CarouselOptions(
                    height: 150.h,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: images.length > 1,
                    autoPlay: false,
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
                          height: 150.h,
                          child: SalonNetworkImage(
                            imageUrl: imageUrl,
                            height: 150.h,
                            logTag: 'SalonCard',
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
              width: 36.w,
              height: 36.h,
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
                  width: 18.w,
                  height: 18.h,
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
            onTap: isLoading
                ? null
                : _handleFavoriteToggle, // Disable while loading
            borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
            child: Container(
              padding: EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: isDarkmode ? AppColors.surfaceDark : AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      isFavorite
                          ? 'assets/icons/ic_heart_fill.svg'
                          : 'assets/icons/ic_heart.svg',
                      width: 18.w,
                      height: 18.h,
                      colorFilter: ColorFilter.mode(
                        isFavorite
                            ? Colors.red
                            : (isDarkmode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
        ),
        // Carousel indicators (left side)
        if (images.length > 1)
          Positioned(
            bottom: AppSizes.paddingS,
            left: AppSizes.paddingS,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: _currentImageIndex == entry.key ? 20.w : 6.w,
                  height: 6.h,
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
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                color: widget.isOfferCard ? const Color(0xFF1ECB5D) : AppColors.white,
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
                    constraints: BoxConstraints(maxWidth: 200.w),
                    child: Text(
                      widget.serviceName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: widget.isOfferCard ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 3.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: widget.isOfferCard ? Colors.white : AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Text(
                    '₹${widget.servicePrice!.toInt()}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                      color: widget.isOfferCard ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSalonInfo(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salon circular image
          Container(
            width: AppSizes.iconM,
            height: AppSizes.iconM,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode
                    ? AppColors.primaryDark.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: SalonNetworkImage(
                imageUrl: widget.salonImage,
                width: AppSizes.iconM,
                height: AppSizes.iconM,
                placeholderIconSize: 20,
                showErrorLabel: false,
                logTag: 'SalonCardAvatar',
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceS),
          // Salon name and rating
          Expanded(
            child: ResponsiveEllipsisText(
              text: widget.salonName,
              maxLines: 2,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode ? AppColors.primaryDark : AppColors.primary,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceS),
          // Rating — fixed width so the name keeps remaining space
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: const Color(0xFFFFA500), // Orange/Gold for rating
                size: 16.w,
              ),
              const SizedBox(width: 4),
              Text(
                widget.rating.toStringAsFixed(1),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontM,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '(${widget.reviewCount})',
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: AppSizes.fontXS,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingAndDistance(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalonLocationRow(
            locationLabel: widget.address,
            distanceKm: widget.distance,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: AppSizes.spaceS),
          // Language and Category badges row (separate)
          ...[
            SizedBox(height: AppSizes.spaceS),
            Row(
              children: [
                _buildLanguageBadges(isDarkMode),
                const Spacer(),
                _buildCategoryBadges(isDarkMode),
              ],
            ),
          ],
        ],
      ),
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
        // Language badges (max 3)
        ...displayLanguages.asMap().entries.expand((entry) {
          final languageCode = entry.value;
          final index = entry.key;
          final iconPath = getLanguageIcon(languageCode);
          final isLast = index == displayLanguages.length - 1;

          final icon = iconPath != null
              ? SvgPicture.asset(
                  iconPath,
                  width: 14.w,
                  height: 14.h,
                  colorFilter: ColorFilter.mode(
                    isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                )
              : Container(
                  width: 20.w,
                  height: 20.h,
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
                        fontSize: 8.sp,
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
    final displayCategories = categories.take(2).toList();
    final hasMoreCategories = categories.length > 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayCategories.map((category) => Container(
              constraints: BoxConstraints(maxWidth: 75.w),
              margin: const EdgeInsets.only(left: 6),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF6F1FE),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Color(0xFF8F89CA),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
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
