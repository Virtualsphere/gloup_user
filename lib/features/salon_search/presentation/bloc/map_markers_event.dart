import 'package:equatable/equatable.dart';

/// Events for MapMarkersBloc ONLY
abstract class MapMarkersEvent extends Equatable {
  const MapMarkersEvent();

  @override
  List<Object?> get props => [];
}

/// Load map markers with clustering
class LoadMapMarkersEvent extends MapMarkersEvent {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;
  final int zoom;
  final String? gender;
  final int? categoryId;
  final bool? isPremium;

  const LoadMapMarkersEvent({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
    required this.zoom,
    this.gender,
    this.categoryId,
    this.isPremium,
  });

  @override
  List<Object?> get props => [
        northEastLat,
        northEastLng,
        southWestLat,
        southWestLng,
        zoom,
        gender,
        categoryId,
        isPremium,
      ];
}
