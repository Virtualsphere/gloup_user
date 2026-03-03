/// Domain Entities for Map Markers

class MapMarkersEntity {
  final int zoom;
  final bool clusteringEnabled;
  final List<ClusterEntity> clusters;
  final List<MarkerEntity> markers;
  final int totalCount;

  MapMarkersEntity({
    required this.zoom,
    required this.clusteringEnabled,
    required this.clusters,
    required this.markers,
    required this.totalCount,
  });
}

class ClusterEntity {
  final String id;
  final double lat;
  final double lng;
  final int count;
  final double avgRating;
  final bool hasPremium;
  final ClusterBoundsEntity bounds;

  ClusterEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.count,
    required this.avgRating,
    required this.hasPremium,
    required this.bounds,
  });
}

class ClusterBoundsEntity {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;

  ClusterBoundsEntity({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });
}

class MarkerEntity {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final double rating;
  final bool isPremium;
  final bool isFavorite;

  MarkerEntity({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.isPremium,
    required this.isFavorite,
  });
}
