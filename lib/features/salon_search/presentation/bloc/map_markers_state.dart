import 'package:equatable/equatable.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';

/// States for MapMarkersBloc ONLY
abstract class MapMarkersState extends Equatable {
  const MapMarkersState();

  @override
  List<Object?> get props => [];
}

class MapMarkersInitial extends MapMarkersState {}

class MapMarkersLoading extends MapMarkersState {}

class MapMarkersLoaded extends MapMarkersState {
  final int zoom;
  final bool clusteringEnabled;
  final List<ClusterEntity> clusters;
  final List<MarkerEntity> markers;
  final int totalCount;

  const MapMarkersLoaded({
    required this.zoom,
    required this.clusteringEnabled,
    required this.clusters,
    required this.markers,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [zoom, clusteringEnabled, clusters, markers, totalCount];
}

class MapMarkersEmpty extends MapMarkersState {
  const MapMarkersEmpty();
}

class MapMarkersFailure extends MapMarkersState {
  final String message;

  const MapMarkersFailure(this.message);

  @override
  List<Object?> get props => [message];
}
