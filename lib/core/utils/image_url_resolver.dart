/// Resolves image paths from API responses into loadable URLs.
///
/// The backend may return either:
/// - A full CDN URL (`https://cdn.gloup.in/...`)
/// - A legacy filename or relative path (needs [imageBaseUrl] + store id)
class ImageUrlResolver {
  ImageUrlResolver._();

  static bool isAbsoluteUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final trimmed = value.trim().toLowerCase();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  /// Salon / store gallery image (`salonImage`, `images[]`, `logo`).
  static String resolveStoreImage({
    required String? path,
    String? storeId,
    String? imageBaseUrl,
  }) {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    if (isAbsoluteUrl(trimmed)) return trimmed;

    final base = _cleanBase(imageBaseUrl);
    if (base == null) return trimmed;

    final normalizedPath =
        trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;

    // Legacy: filename only → {base}/{storeId}/images/{file}
    if (storeId != null &&
        storeId.isNotEmpty &&
        !normalizedPath.contains('/')) {
      return '$base/$storeId/images/$normalizedPath';
    }

    // Legacy: path already includes store segment
    if (normalizedPath.startsWith('$storeId/images/')) {
      return '$base/$normalizedPath';
    }

    return '$base/$normalizedPath';
  }

  /// Banner, category, or other CDN asset (`imageUrl` on banners/categories).
  static String resolveCdnAsset({
    required String? path,
    String? imageBaseUrl,
  }) {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    if (isAbsoluteUrl(trimmed)) return trimmed;

    final base = _cleanBase(imageBaseUrl);
    if (base == null) return trimmed;

    final normalizedPath =
        trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '$base/$normalizedPath';
  }

  /// Profile or review user avatar.
  static String resolveProfileImage({
    required String? path,
    String? imageBaseUrl,
  }) {
    return resolveCdnAsset(path: path, imageBaseUrl: imageBaseUrl);
  }

  /// Team member image on salon details.
  static String resolveTeamMemberImage({
    required String? path,
    String? imageBaseUrl,
  }) {
    return resolveCdnAsset(path: path, imageBaseUrl: imageBaseUrl);
  }

  /// Builds a non-empty gallery list; falls back to [primaryImage] or [logo].
  static List<String> resolveStoreGallery({
    List<dynamic>? images,
    String? primaryImage,
    String? logo,
    String? storeId,
    String? imageBaseUrl,
  }) {
    final resolved = <String>[];

    void addIfValid(String? raw) {
      final url = resolveStoreImage(
        path: raw,
        storeId: storeId,
        imageBaseUrl: imageBaseUrl,
      );
      if (url.isNotEmpty && !resolved.contains(url)) {
        resolved.add(url);
      }
    }

    if (images != null) {
      for (final item in images) {
        addIfValid(item?.toString());
      }
    }

    if (resolved.isEmpty) {
      addIfValid(primaryImage);
      addIfValid(logo);
    }

    return resolved;
  }

  static String? _cleanBase(String? imageBaseUrl) {
    if (imageBaseUrl == null || imageBaseUrl.isEmpty) return null;
    return imageBaseUrl.endsWith('/')
        ? imageBaseUrl.substring(0, imageBaseUrl.length - 1)
        : imageBaseUrl;
  }
}
