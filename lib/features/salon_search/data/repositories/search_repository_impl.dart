import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/salon_search/data/datasources/search_remote_datasource.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/features/map_markers/domain/entities/map_marker_entities.dart';
import 'package:tressy/features/map_markers/data/models/map_marker_models.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource dataSource;
  final NetworkInfo networkInfo;

  SearchRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<SalonEntity>>> getNearbySalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    final disconnected =
        await leftIfDisconnected<List<SalonEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final response = await dataSource.getNearbySalons(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
      );

      final entities =
          response.salons.map((model) => model.toEntity()).toList();

      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch nearby salons: ${e.toString()}'),
      );
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
    final disconnected =
        await leftIfDisconnected<List<SalonEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

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

      final entities =
          response.salons.map((model) => model.toEntity()).toList();

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
    final disconnected =
        await leftIfDisconnected<MapMarkersEntity>(networkInfo);
    if (disconnected != null) return disconnected;

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
        ServerFailure('Failed to fetch map markers: ${e.toString()}'),
      );
    }
  }
}
