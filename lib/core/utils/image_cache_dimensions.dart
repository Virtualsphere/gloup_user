import 'package:flutter/material.dart';

/// Computes physical pixel dimensions for [CachedNetworkImage] cache hints.
///
/// Uses the device pixel ratio so decoded images match on-screen density
/// without arbitrary downscaling (which causes blur on high-DPI devices).
class ImageCacheDimensions {
  ImageCacheDimensions._();

  static const int maxDimension = 4096;

  static int? forLogicalSize(BuildContext context, double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final pixels =
        (logicalSize * MediaQuery.devicePixelRatioOf(context)).ceil();
    return pixels.clamp(1, maxDimension);
  }

  static int? forLogicalWidth(BuildContext context, double? logicalWidth) =>
      forLogicalSize(context, logicalWidth);

  static int? forLogicalHeight(BuildContext context, double? logicalHeight) =>
      forLogicalSize(context, logicalHeight);

  static ({int? width, int? height}) forBox(
    BuildContext context, {
    double? logicalWidth,
    double? logicalHeight,
    bool fullResolution = false,
  }) {
    if (fullResolution) {
      return (width: null, height: null);
    }
    return (
      width: forLogicalWidth(context, logicalWidth),
      height: forLogicalHeight(context, logicalHeight),
    );
  }
}
