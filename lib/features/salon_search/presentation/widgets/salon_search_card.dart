import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image with rounded corners and margin
                _buildImage(),
                const SizedBox(width: AppSizes.spaceM),
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

  Widget _buildImage() {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(left: AppSizes.paddingS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Image.network(
              widget.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.content_cut,
                        color: AppColors.primary.withValues(alpha: 0.3),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No image',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.4),
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
                padding: const EdgeInsets.symmetric(
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
                style: context.textTheme.titleMedium?.copyWith(
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
            const SizedBox(width: AppSizes.spaceS),
            // Rating with review count
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFA500),
                  size: AppSizes.iconXS,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
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
        const SizedBox(height: AppSizes.spaceM),
        // Address
        if (widget.address != null) ...[
          _buildRatingAndDistance(isDarkMode),
          const SizedBox(height: AppSizes.spaceM),
        ],
        // Languages and Categories
        if ((widget.languageCodes != null &&
                widget.languageCodes!.isNotEmpty) ||
            (widget.categories != null && widget.categories!.isNotEmpty)) ...[
          Row(
            children: [
              if (widget.languageCodes != null &&
                  widget.languageCodes!.isNotEmpty)
                _buildLanguageBadges(isDarkMode),
              if (widget.languageCodes != null &&
                  widget.languageCodes!.isNotEmpty &&
                  widget.categories != null &&
                  widget.categories!.isNotEmpty)
                const SizedBox(width: AppSizes.spaceM),
              if (widget.categories != null && widget.categories!.isNotEmpty)
                Expanded(
                  child: Container(
                  constraints: const BoxConstraints(maxWidth: 190),
                    child: _buildCategoryBadges(isDarkMode),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLanguageBadges(bool isDarkMode) {
    final languageCodes = widget.languageCodes ?? [];
    final displayLanguages = languageCodes.take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: displayLanguages.asMap().entries.map((entry) {
        final languageCode = entry.value;
        final index = entry.key;
        final iconPath = getLanguageIcon(languageCode);

        return Padding(
          padding: EdgeInsets.only(
              right: index < displayLanguages.length - 1 ? 6 : 4),
          child: iconPath != null
              ? SvgPicture.asset(
                  iconPath,
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
              : Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.primaryDark.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      languageCode.length >= 2
                          ? languageCode.substring(0, 2).toUpperCase()
                          : languageCode.toUpperCase(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingAndDistance(bool isDarkMode) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
          size: 14,
        ),
        const SizedBox(width: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 130),
          child: Text(
            widget.address ?? '',
            style: context.textTheme.bodyMedium?.copyWith(
              overflow: TextOverflow.ellipsis,
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Distance
        Text(
          '${widget.distance.toStringAsFixed(1)} KM',
          style: context.textTheme.bodyMedium?.copyWith(
            color: isDarkMode
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadges(bool isDarkMode) {
    final categories = widget.categories ?? [];
    final displayCategories = categories.take(2).toList();
    final hasMoreCategories = categories.length > 2;

    return Row(
      spacing: 4,
      children: [
        // Category badges (up to 2)
        ...displayCategories.map((category) => Container(
        constraints: const BoxConstraints(maxWidth: 70),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
                    : AppColors.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
              ),
              child: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        if (hasMoreCategories)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingS,
              vertical: 2,
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
