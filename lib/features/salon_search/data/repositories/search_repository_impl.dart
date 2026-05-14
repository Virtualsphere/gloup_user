import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/salon_search/data/datasources/search_remote_datasource.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';
import 'package:tressy/features/map_markers/data/models/map_marker_models.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource dataSource;

  SearchRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SalonEntity>>> getNearbySalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    try {
      final response = await dataSource.getNearbySalons(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
      );

      // Convert models to entities
      final entities = response.salons
          .map((model) => SalonEntity(
                id: model.id,
                salonName: model.salonName,
                salonImage: model.salonImage,
                images: model.images,
                rating: model.rating,
                reviewCount: model.reviewCount,
                distance: model.distance,
                address: model.address,
                isPremium: model.isPremium,
                isFavorite: model.isFavorite,
                serviceName: model.serviceName,
                servicePrice: model.servicePrice,
                categories: model.categories,
                languageCodes: model.languageCodes,
              ))
          .toList();

      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to fetch nearby salons: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> searchSalons({
    required double latitude,
    required double longitude,
    String? query,
    String? categoryId,
    String? gender,
    int? limit,
    int? page,
  }) async {
    try {
      final response = await dataSource.searchSalons(
        latitude: latitude,
        longitude: longitude,
        query: query,
        categoryId: categoryId,
        gender: gender,
        limit: limit,
        page: page,
      );

      // Convert models to entities
      final entities = response.salons
          .map((model) => SalonEntity(
                id: model.id,
                salonName: model.salonName,
                salonImage: model.salonImage,
                images: model.images,
                rating: model.rating,
                reviewCount: model.reviewCount,
                distance: model.distance,
                address: model.address,
                isPremium: model.isPremium,
                isFavorite: model.isFavorite,
                serviceName: model.serviceName,
                servicePrice: model.servicePrice,
                categories: model.categories,
                languageCodes: model.languageCodes,
              ))
          .toList();

      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search salons: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MapMarkersEntity>> getClusteredMarkers({
    required MapMarkersRequestModel request,
  }) async {
    try {
      final response = await dataSource.getClusteredMarkers(request: request);
      return Right(response.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to fetch map markers: ${e.toString()}'));
    }
  }
}
