import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tressy/core/constants/app_colors.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';

/// Manager class for creating and handling map markers and clusters
class MapMarkerManager {
  // Cache for marker icons to avoid recreating them
  final Map<String, BitmapDescriptor> _iconCache = {};

  /// Creates markers from individual salon data
  Future<Set<Marker>> createIndividualMarkers({
    required List<MarkerEntity> markers,
    required bool isDarkMode,
    required Function(int salonId) onMarkerTap,
  }) async {
    final Set<Marker> googleMarkers = {};

    // Use Google's default marker with black color (hue 0 = red-ish, we want black)
    // For black/dark color, use hue close to 0 or use defaultMarker
    final blackMarker = BitmapDescriptor.defaultMarker;

    for (final marker in markers) {
      googleMarkers.add(
        Marker(
          markerId: MarkerId('salon_${marker.id}'),
          position: LatLng(marker.lat, marker.lng),
          icon: blackMarker,
          infoWindow: InfoWindow(
            title: marker.name,
            snippet: '${marker.rating.toStringAsFixed(1)} ⭐',
          ),
          onTap: () => onMarkerTap(marker.id),
        ),
      );
    }

    print('✅ Created ${googleMarkers.length} individual markers (default black)');
    return googleMarkers;
  }

  /// Creates cluster markers from aggregated data
  Future<Set<Marker>> createClusterMarkers({
    required List<ClusterEntity> clusters,
    required bool isDarkMode,
    required Function(ClusterEntity cluster) onClusterTap,
  }) async {
    final Set<Marker> googleMarkers = {};

    for (final cluster in clusters) {
      // Create unique key for cluster size range
      final sizeRange = _getClusterSizeRange(cluster.count);
      final iconKey = 'cluster_${sizeRange}_${cluster.hasPremium}';

      // Get or create icon
      BitmapDescriptor icon;
      if (_iconCache.containsKey(iconKey)) {
        icon = _iconCache[iconKey]!;
      } else {
        icon = await _createClusterIcon(
          count: cluster.count,
          hasPremium: cluster.hasPremium,
          isDarkMode: isDarkMode,
        );
        _iconCache[iconKey] = icon;
      }

      googleMarkers.add(
        Marker(
          markerId: MarkerId(cluster.id),
          position: LatLng(cluster.lat, cluster.lng),
          icon: icon,
          infoWindow: InfoWindow(
            title: '${cluster.count} salons',
            snippet: 'Avg rating: ${cluster.avgRating.toStringAsFixed(1)} ⭐',
          ),
          onTap: () => onClusterTap(cluster),
        ),
      );
    }

    print('✅ Created ${googleMarkers.length} cluster markers');
    return googleMarkers;
  }

  /// Create cluster icon (simple with count)
  Future<BitmapDescriptor> _createClusterIcon({
    required int count,
    required bool hasPremium,
    required bool isDarkMode,
  }) async {
    final size = _getClusterSize(count);
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Cluster color - simplified
    final clusterColor = hasPremium ? AppColors.primary : AppColors.secondary;

    // Draw solid circle
    final circlePaint = Paint()
      ..color = clusterColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, circlePaint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, borderPaint);

    // Draw count text
    final displayCount = count > 999 ? '999+' : count.toString();
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayCount,
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 3.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Get cluster size based on count
  double _getClusterSize(int count) {
    if (count < 10) return 60.0;
    if (count < 50) return 70.0;
    if (count < 100) return 80.0;
    if (count < 500) return 90.0;
    return 100.0;
  }

  /// Get cluster size range for caching
  String _getClusterSizeRange(int count) {
    if (count < 10) return 'small';
    if (count < 50) return 'medium';
    if (count < 100) return 'large';
    if (count < 500) return 'xlarge';
    return 'xxlarge';
  }

  /// Clear icon cache (call when theme changes)
  void clearCache() {
    _iconCache.clear();
  }

  /// Dispose resources
  void dispose() {
    _iconCache.clear();
  }
}
