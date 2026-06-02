import 'package:tressy/core/utils/image_url_resolver.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';

/// Resolves home / listing category labels to CDN URLs or local asset paths.
abstract final class CategoryImageResolver {
  static const defaultAsset = 'assets/images/png/haircut.png';

  /// Top-categories API: `image` (v2) or legacy `imageUrl`.
  static String? apiImageFromJson(Map<String, dynamic> json) {
    for (final key in ['image', 'imageUrl', 'image_url']) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Best image path for UI: API image → list match → local PNG.
  static String resolveImagePath({
    required String categoryName,
    String? imageUrl,
    List<CategoryEntity>? apiCategories,
  }) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    if (trimmedUrl.isNotEmpty) {
      if (isAssetPath(trimmedUrl)) return trimmedUrl;
      if (ImageUrlResolver.isAbsoluteUrl(trimmedUrl)) return trimmedUrl;
    }

    if (apiCategories != null) {
      final network = networkUrlForCategory(categoryName, apiCategories);
      if (network != null && network.isNotEmpty) return network;
    }

    return localAssetForCategory(categoryName) ?? defaultAsset;
  }

  static bool isAssetPath(String path) => path.startsWith('assets/');

  /// CDN image from [apiCategories] when the label matches.
  static String? networkUrlForCategory(
    String categoryName,
    List<CategoryEntity> apiCategories,
  ) {
    if (_normalize(categoryName) == 'all') return null;

    for (final category in apiCategories) {
      if (category.imageUrl.isEmpty) continue;
      if (_namesMatch(categoryName, category.label)) {
        return category.imageUrl;
      }
    }
    return null;
  }

  /// Bundled PNG/SVG for category names (home, Services @ ₹49, listings).
  static String? localAssetForCategory(String categoryName) {
    final name = categoryName.toLowerCase().trim();
    if (name == 'all') {
      return 'assets/images/svg/chair.svg';
    }

    if (name.contains('hair') || name.contains('cut')) {
      return 'assets/images/png/haircut.png';
    }
    if (name.contains('eyebrow') || name.contains('brow')) {
      return 'assets/images/png/eyebrow.png';
    }
    if (name.contains('shave') || name.contains('beard')) {
      return 'assets/images/png/shave.png';
    }
    if (name.contains('trim')) {
      return 'assets/images/png/trim.png';
    }
    if (name.contains('nail')) {
      return 'assets/images/png/nails.png';
    }
    if (name.contains('facial') ||
        name.contains('makeup') ||
        name.contains('clean')) {
      return 'assets/images/png/facial.png';
    }
    if (name.contains('detan') ||
        name.contains('detain') ||
        name.contains('de-tan')) {
      return 'assets/images/png/detain.png';
    }
    if (name.contains('bleach')) {
      return 'assets/images/png/facial.png';
    }
    if (name.contains('massage') || name.contains('spa')) {
      return 'assets/images/png/facial.png';
    }

    return null;
  }

  static bool isSvgAsset(String path) => path.toLowerCase().endsWith('.svg');

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  static bool _namesMatch(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) return true;

    const keywords = [
      'haircut',
      'hair',
      'eyebrow',
      'brow',
      'facial',
      'cleanup',
      'clean',
      'nail',
      'shave',
      'trim',
      'detan',
      'bleach',
      'massage',
      'makeup',
    ];
    for (final keyword in keywords) {
      if (na.contains(keyword) && nb.contains(keyword)) return true;
    }
    return false;
  }
}
