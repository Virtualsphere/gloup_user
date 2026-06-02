import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/shared/widgets/category_image.dart';

/// Figma service tile — 90×90 image, 12px label gap, green price.
class ServiceItemWidget extends StatelessWidget {
  const ServiceItemWidget({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.isDarkMode = false,
    this.trailingGap = 0,
  });

  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double trailingGap;

  static const itemWidth = 90.0;
  static const imageSize = 90.0;
  static const imageRadius = 8.0;
  static const labelGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: itemWidth,
        margin: EdgeInsets.only(right: trailingGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(imageRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Transform.scale(
                    scale: 1.25,
                    child: CategoryImage(
                      categoryName: title,
                      imageUrl: imageUrl,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: labelGap),
            RichText(
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 15 / 12,
                  color: isDarkMode ? AppColors.white : const Color(0xFF000000),
                ),
                children: [
                  TextSpan(text: '$title '),
                  TextSpan(
                    text: price,
                    style: TextStyle(
                        color: AppColors.serviceItemPriceGreen, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
