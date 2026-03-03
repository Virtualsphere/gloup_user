import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';
import 'package:tressy/features/map_markers/data/models/map_marker_models.dart';

abstract class SearchRepository {
  /// Get nearby salons without search query
  Future<Either<Failure, List<SalonEntity>>> getNearbySalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
  
  /// Search salons with query and filters
  Future<Either<Failure, List<SalonEntity>>> searchSalons({
    required double latitude,
    required double longitude,
    String? query,
    String? categoryId,
    String? gender,
    int? limit,
    int? page,
  });

  /// Get clustered map markers
  Future<Either<Failure, MapMarkersEntity>> getClusteredMarkers({
    required MapMarkersRequestModel request,
  });
}
