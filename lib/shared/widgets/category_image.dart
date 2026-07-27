import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/utils/category_image_resolver.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/shared/widgets/hd_cached_network_image.dart';

/// Category thumbnail: CDN URL when available, else bundled PNG/SVG.
class CategoryImage extends StatelessWidget {
  final String categoryName;
  final String? imageUrl;
  final List<CategoryEntity>? apiCategories;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isDarkMode;

  const CategoryImage({
    super.key,
    required this.categoryName,
    this.imageUrl,
    this.apiCategories,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = CategoryImageResolver.resolveImagePath(
      categoryName: categoryName,
      imageUrl: imageUrl,
      apiCategories: apiCategories,
    );

    if (CategoryImageResolver.isAssetPath(resolved)) {
      if (CategoryImageResolver.isSvgAsset(resolved)) {
        return SizedBox(
          width: width,
          height: height,
          child: SvgPicture.asset(
            resolved,
            fit: fit,
          ),
        );
      }
      return SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          resolved,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: HdCachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _fallbackAsset(),
      ),
    );
  }

  Widget _fallbackAsset() {
    final asset = CategoryImageResolver.localAssetForCategory(categoryName) ??
        CategoryImageResolver.defaultAsset;
    if (CategoryImageResolver.isSvgAsset(asset)) {
      return SizedBox(
        width: width,
        height: height,
        child: SvgPicture.asset(asset, fit: fit),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(asset, width: width, height: height, fit: fit),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
