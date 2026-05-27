import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/core/constants/app_icons.dart';
import 'package:tressy/core/utils/app_logger.dart';
import 'package:tressy/core/utils/image_url_resolver.dart';

/// Network image for salon cards and lists with loading + error states.
class SalonNetworkImage extends StatelessWidget {
  const SalonNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIconSize = 48,
    this.showErrorLabel = true,
    this.logTag = 'SalonImage',
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double placeholderIconSize;
  final bool showErrorLabel;
  final String logTag;

  bool get _hasValidUrl {
    final url = imageUrl.trim();
    return url.isNotEmpty && ImageUrlResolver.isAbsoluteUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidUrl) {
      return _errorPlaceholder(context);
    }

    final image = CachedNetworkImage(
      imageUrl: imageUrl.trim(),
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => _loadingPlaceholder(context),
      errorWidget: (_, url, error) {
        AppLogger.warning(
          'Failed to load image: $url (${error.runtimeType})',
          tag: logTag,
        );
        return _errorPlaceholder(context);
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _loadingPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppIcons.placeGallery,
            width: placeholderIconSize * 0.6,
            height: placeholderIconSize * 0.6,
            colorFilter: ColorFilter.mode(
              AppColors.primary.withValues(alpha: 0.35),
              BlendMode.srcIn,
            ),
          ),
          if (showErrorLabel) ...[
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
