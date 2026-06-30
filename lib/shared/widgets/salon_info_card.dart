import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_sizes.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonInfoCard extends StatelessWidget {
  final String salonName;
  final String? salonImage;
  final double rating;
  final int reviewCount;
  final String gender;
  final String address;
  final bool isPremium;
  final String? selectedDate;
  final String? selectedTimeSlot;

  const SalonInfoCard({
    super.key,
    required this.salonName,
    this.salonImage,
    required this.rating,
    required this.reviewCount,
    required this.gender,
    required this.address,
    this.isPremium = false,
    this.selectedDate,
    this.selectedTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.paddingM),
      padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM, vertical: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surface,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Image with crown overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: salonImage != null
                        ? CachedNetworkImage(
                            imageUrl: salonImage!,
                            width: 120,
                            height: 80,
                            fit: BoxFit.cover,
                            memCacheWidth: 240,
                            memCacheHeight: 160,
                            errorWidget: (context, url, error) {
                              return Container(
                                width: 120,
                                height: 80,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.content_cut,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      size: 36,
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
                          )
                        : Container(
                            width: 120,
                            height: 80,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.image,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                  ),
                  // Premium crown overlay
                  if (isPremium)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 24,
                        height: 24,
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
                ],
              ),
              SizedBox(width: AppSizes.spaceM),
              // Right side - Column with salon info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon name
                    Text(
                      salonName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: AppSizes.fontL,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceS),
                    // Row: Rating and Gender
                    Row(
                      children: [
                        // Left side - Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFA500),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$rating ($reviewCount)',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: AppSizes.fontM,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: AppSizes.spaceM),
                        // Right side - Gender
                        Row(
                          children: [
                            Icon(
                              Icons.wc,
                              color: AppColors.info,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gender,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontSize: AppSizes.fontM,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spaceS),
                    // Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ic_location.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            isDarkMode
                                ? AppColors.primaryDark
                                : AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: AppSizes.fontM,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Date and Time section (left-aligned column)
          if (selectedDate != null || selectedTimeSlot != null) ...[
            SizedBox(height: AppSizes.spaceL),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date row
                if (selectedDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedDate!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: AppSizes.fontM,
                        ),
                      ),
                    ],
                  ),
                // Time slot row
                if (selectedTimeSlot != null) ...[
                  if (selectedDate != null) SizedBox(height: AppSizes.spaceS),
                  AppSizes.widthL,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isDarkMode
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedTimeSlot!,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: AppSizes.fontM,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
