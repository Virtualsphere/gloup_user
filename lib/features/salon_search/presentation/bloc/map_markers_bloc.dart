import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/salon_search/domain/usecases/get_clustered_markers_usecase.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_event.dart';
import 'package:tressy/features/salon_search/presentation/bloc/map_markers_state.dart';

/// Separate BLoC ONLY for map markers - completely independent from search
class MapMarkersBloc extends Bloc<MapMarkersEvent, MapMarkersState> {
  final GetClusteredMarkersUseCase getClusteredMarkersUseCase;

  MapMarkersBloc({
    required this.getClusteredMarkersUseCase,
  }) : super(MapMarkersInitial()) {
    on<LoadMapMarkersEvent>(_onLoadMapMarkers);
  }

  Future<void> _onLoadMapMarkers(
    LoadMapMarkersEvent event,
    Emitter<MapMarkersState> emit,
  ) async {
    emit(MapMarkersLoading());

    final result = await getClusteredMarkersUseCase(
      northEastLat: event.northEastLat,
      northEastLng: event.northEastLng,
      southWestLat: event.southWestLat,
      southWestLng: event.southWestLng,
      zoom: event.zoom,
      gender: event.gender,
      categoryId: event.categoryId,
      isPremium: event.isPremium,
    );

    result.fold(
      (failure) => emit(MapMarkersFailure(failure.message)),
      (markersData) {
        if (markersData.totalCount == 0) {
          emit(const MapMarkersEmpty());
        } else {
          emit(MapMarkersLoaded(
            zoom: markersData.zoom,
            clusteringEnabled: markersData.clusteringEnabled,
            clusters: markersData.clusters,
            markers: markersData.markers,
            totalCount: markersData.totalCount,
          ));
        }
      },
    );
  }
}
