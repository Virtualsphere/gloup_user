import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tressy/core/utils/image_cache_dimensions.dart';

/// Network image tuned for sharp rendering on high-DPI screens.
class HdCachedNetworkImage extends StatelessWidget {
  const HdCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheLogicalWidth,
    this.cacheLogicalHeight,
    this.fit = BoxFit.cover,
    this.fullResolution = false,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  /// Override decode width when [width] is unbounded (e.g. `double.infinity`).
  final double? cacheLogicalWidth;
  final double? cacheLogicalHeight;
  final BoxFit fit;
  final bool fullResolution;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final cache = ImageCacheDimensions.forBox(
      context,
      logicalWidth: cacheLogicalWidth ?? _finite(width),
      logicalHeight: cacheLogicalHeight ?? _finite(height),
      fullResolution: fullResolution,
    );

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      memCacheWidth: cache.width,
      memCacheHeight: cache.height,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  static double? _finite(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }
}
