import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';
import 'package:tressy/features/map_markers/data/models/map_marker_models.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';

/// Use case to get clustered map markers
class GetClusteredMarkersUseCase {
  final SearchRepository repository;

  GetClusteredMarkersUseCase(this.repository);

  Future<Either<Failure, MapMarkersEntity>> call({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
    required int zoom,
    String? gender,
    int? categoryId,
    bool? isPremium,
    int? limit,
  }) async {
    final request = MapMarkersRequestModel(
      bounds: MapBoundsModel(
        northEast: LatLngModel(lat: northEastLat, lng: northEastLng),
        southWest: LatLngModel(lat: southWestLat, lng: southWestLng),
      ),
      zoom: zoom,
      filters: MapFiltersModel(
        gender: gender,
        categoryId: categoryId,
        isPremium: isPremium,
      ),
      limit: limit,
    );

    return await repository.getClusteredMarkers(request: request);
  }
}
