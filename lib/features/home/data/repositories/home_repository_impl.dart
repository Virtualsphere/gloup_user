import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/home/data/datasources/home_datasource.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart'
    hide SalonEntity;
import 'package:tressy/features/home/domain/repositories/home_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CarouselBannerEntity>>>
      getCarouselBanners() async {
    try {
      final models = await dataSource.getCarouselBanners();
      final entities = models
          .map((model) => CarouselBannerEntity(
                id: model.id,
                imageUrl: model.imageUrl,
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
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> getPopularServices({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    try {
      final response = await dataSource.getPopularServices(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
      );

      final entities = response.salons.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> getTopSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    try {
      final response = await dataSource.getTopSalons(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
      );

      final entities = response.salons.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
