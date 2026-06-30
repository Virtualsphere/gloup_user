import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/salon_detail_design_tokens.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/shared/extensions/context_extensions.dart';

class SalonGallerySection extends StatelessWidget {
  final double carouselHeight;
  final bool isDarkMode;
  final bool isFullyExpanded;
  final SalonDetailEntity salonDetail;
  final int currentImageIndex;
  final ValueChanged<int> onImageChanged;

  const SalonGallerySection({
    super.key,
    required this.carouselHeight,
    required this.isDarkMode,
    required this.isFullyExpanded,
    required this.salonDetail,
    required this.currentImageIndex,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCarousel();
  }

  Widget _buildCarousel() {
    final images = salonDetail.images;

    return Stack(
      clipBehavior: Clip.none,
      children: [
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
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (index, reason) => onImageChanged(index),
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
                final isActive = currentImageIndex == entry.key;
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
}
