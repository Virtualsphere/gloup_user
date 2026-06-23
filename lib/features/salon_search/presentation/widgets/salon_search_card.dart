import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';
import 'package:tressy/shared/widgets/salon_badges_row.dart';
import 'package:tressy/shared/widgets/salon_location_row.dart';

class SalonSearchCard extends StatefulWidget {
  final String salonName;
  final String salonImage;
  final String imageUrl;
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

  const SalonSearchCard({
    super.key,
    required this.salonName,
    required this.salonImage,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    this.isPremium = false,
    this.isFavorite = false,
    this.serviceName,
    this.servicePrice,
    this.address,
    this.categories,
    this.languageCodes,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<SalonSearchCard> createState() => _SalonSearchCardState();
}

class _SalonSearchCardState extends State<SalonSearchCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image with rounded corners and margin
                _buildImage(isDarkMode),
                SizedBox(width: AppSizes.spaceM),
                // Right side - Content
                Expanded(
                  child: _buildContent(isDarkMode),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode
              ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
              : AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildImage(bool isDarkMode) {
    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.only(left: AppSizes.paddingS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Stack(
        children: [
          // Main image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              memCacheWidth: 200,
              memCacheHeight: 200,
              errorWidget: (context, url, error) {
                return Container(
                  width: 100,
                  height: 100,
                  color: isDarkMode
                      ? AppColors.primaryDark.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.content_cut,
                        color: isDarkMode
                            ? AppColors.primaryDark.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                        size: 32,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No image',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.primaryDark.withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.4),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Premium crown badge
          if (widget.isPremium)
            Positioned(
              top: AppSizes.paddingXS,
              left: AppSizes.paddingXS,
              child: Container(
                width: 24,
                height: 24,
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
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.icCrown,
                    width: 12,
                    height: 12,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          // Service badge
          if (widget.serviceName != null && widget.servicePrice != null)
            Positioned(
              bottom: AppSizes.paddingXS,
              right: AppSizes.paddingXS,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '₹${widget.servicePrice!.toInt()}',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Salon name and rating
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.salonName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSizes.spaceS),
            // Rating with review count
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFFFFA500),
                  size: AppSizes.iconXS,
                ),
                SizedBox(width: 4),
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  '(${widget.reviewCount})',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDarkMode
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: AppSizes.spaceM),
        // Address
        if (widget.address != null) ...[
          _buildRatingAndDistance(isDarkMode),
          SizedBox(height: AppSizes.spaceM),
        ],
        // Languages and Categories
        SalonBadgesRow(
          languageCodes: widget.languageCodes,
          categories: widget.categories,
          languageIconSize: 12,
          languageFontSize: 7,
        ),
      ],
    );
  }

  Widget _buildRatingAndDistance(bool isDarkMode) {
    return SalonLocationRow(
      locationLabel: widget.address,
      distanceKm: widget.distance,
      isDarkMode: isDarkMode,
    );
  }
}
