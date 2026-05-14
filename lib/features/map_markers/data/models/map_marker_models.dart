import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';

/// Request Models

class MapBoundsModel {
  final LatLngModel northEast;
  final LatLngModel southWest;

  MapBoundsModel({
    required this.northEast,
    required this.southWest,
  });

  Map<String, dynamic> toJson() {
    return {
      'northEast': northEast.toJson(),
      'southWest': southWest.toJson(),
    };
  }
}

class LatLngModel {
  final double lat;
  final double lng;

  LatLngModel({
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class MapFiltersModel {
  final String? gender;
  final int? categoryId;
  final bool? isPremium;

  MapFiltersModel({
    this.gender,
    this.categoryId,
    this.isPremium,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender ?? 'all',
      'categoryId': categoryId,
      'isPremium': isPremium ?? false,
    };
  }
}

class MapMarkersRequestModel {
  final MapBoundsModel bounds;
  final int zoom;
  final MapFiltersModel? filters;
  final int? limit;

  MapMarkersRequestModel({
    required this.bounds,
    required this.zoom,
    this.filters,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      'bounds': bounds.toJson(),
      'zoom': zoom,
      'filters': filters?.toJson() ?? MapFiltersModel().toJson(),
      'limit': limit ?? 500,
    };
  }
}

/// Response Models

class MapMarkersResponseModel {
  final bool success;
  final int zoom;
  final bool clusteringEnabled;
  final MapMarkersDataModel data;
  final int totalCount;
  final String timestamp;

  MapMarkersResponseModel({
    required this.success,
    required this.zoom,
    required this.clusteringEnabled,
    required this.data,
    required this.totalCount,
    required this.timestamp,
  });

  factory MapMarkersResponseModel.fromJson(Map<String, dynamic> json) {
    return MapMarkersResponseModel(
      success: json['success'] as bool,
      zoom: json['zoom'] as int,
      clusteringEnabled: json['clusteringEnabled'] as bool,
      data: MapMarkersDataModel.fromJson(json['data'] as Map<String, dynamic>),
      totalCount: json['totalCount'] as int,
      timestamp: json['timestamp'] as String,
    );
  }

  MapMarkersEntity toEntity() {
    return MapMarkersEntity(
      zoom: zoom,
      clusteringEnabled: clusteringEnabled,
      clusters: data.clusters.map((c) => c.toEntity()).toList(),
      markers: data.markers.map((m) => m.toEntity()).toList(),
      totalCount: totalCount,
    );
  }
}

class MapMarkersDataModel {
  final List<ClusterModel> clusters;
  final List<MarkerModel> markers;

  MapMarkersDataModel({
    required this.clusters,
    required this.markers,
  });

  factory MapMarkersDataModel.fromJson(Map<String, dynamic> json) {
    return MapMarkersDataModel(
      clusters: (json['clusters'] as List<dynamic>?)
              ?.map((e) => ClusterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      markers: (json['markers'] as List<dynamic>?)
              ?.map((e) => MarkerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ClusterModel {
  final String id;
  final String type;
  final double lat;
  final double lng;
  final int count;
  final double avgRating;
  final bool hasPremium;
  final ClusterBoundsModel bounds;

  ClusterModel({
    required this.id,
    required this.type,
    required this.lat,
    required this.lng,
    required this.count,
    required this.avgRating,
    required this.hasPremium,
    required this.bounds,
  });

  factory ClusterModel.fromJson(Map<String, dynamic> json) {
    return ClusterModel(
      id: json['id'] as String,
      type: json['type'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      count: json['count'] as int,
      avgRating: (json['avgRating'] as num).toDouble(),
      hasPremium: json['hasPremium'] as bool,
      bounds:
          ClusterBoundsModel.fromJson(json['bounds'] as Map<String, dynamic>),
    );
  }

  ClusterEntity toEntity() {
    return ClusterEntity(
      id: id,
      lat: lat,
      lng: lng,
      count: count,
      avgRating: avgRating,
      hasPremium: hasPremium,
      bounds: bounds.toEntity(),
    );
  }
}

class ClusterBoundsModel {
  final LatLngModel northEast;
  final LatLngModel southWest;

  ClusterBoundsModel({
    required this.northEast,
    required this.southWest,
  });

  factory ClusterBoundsModel.fromJson(Map<String, dynamic> json) {
    return ClusterBoundsModel(
      northEast:
          LatLngModel.fromJson(json['northEast'] as Map<String, dynamic>),
      southWest:
          LatLngModel.fromJson(json['southWest'] as Map<String, dynamic>),
    );
  }

  ClusterBoundsEntity toEntity() {
    return ClusterBoundsEntity(
      northEastLat: northEast.lat,
      northEastLng: northEast.lng,
      southWestLat: southWest.lat,
      southWestLng: southWest.lng,
    );
  }
}

class MarkerModel {
  final int id;
  final String type;
  final String name;
  final double lat;
  final double lng;
  final double rating;
  final bool isPremium;
  final bool isFavorite;

  MarkerModel({
    required this.id,
    required this.type,
    required this.name,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.isPremium,
    required this.isFavorite,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      isPremium: json['isPremium'] as bool,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  MarkerEntity toEntity() {
    return MarkerEntity(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      rating: rating,
      isPremium: isPremium,
      isFavorite: isFavorite,
    );
  }
}
