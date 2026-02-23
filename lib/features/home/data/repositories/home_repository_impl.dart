import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/home/data/datasources/home_datasource.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;

  HomeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CarouselBannerEntity>>> getCarouselBanners() async {
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
    String gender = 'unisex',
  }) async {
    try {
      final models = await dataSource.getPopularServices(
        latitude: latitude,
        longitude: longitude,
        gender: gender,
      );
      final entities = models
          .map((model) => SalonEntity(
                id: model.id,
                salonName: model.salonName,
                salonImage: model.salonImage,
                images: model.images,
                rating: model.rating,
                reviewCount: model.reviewCount,
                distance: model.distance,
                isPremium: model.isPremium,
                isFavorite: model.isFavorite,
                serviceName: model.serviceName,
                servicePrice: model.servicePrice,
                address: model.address,
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
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> getTopSalons({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final models = await dataSource.getTopSalons(
        latitude: latitude,
        longitude: longitude,
      );
      final entities = models
          .map((model) => SalonEntity(
                id: model.id,
                salonName: model.salonName,
                salonImage: model.salonImage,
                images: model.images,
                rating: model.rating,
                reviewCount: model.reviewCount,
                distance: model.distance,
                isPremium: model.isPremium,
                isFavorite: model.isFavorite,
                serviceName: model.serviceName,
                servicePrice: model.servicePrice,
                address: model.address,
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
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> getRecommendedSalons() async {
    try {
      final models = await dataSource.getRecommendedSalons();
      final entities = models
          .map((model) => SalonEntity(
                id: model.id,
                salonName: model.salonName,
                salonImage: model.salonImage,
                images: model.images,
                rating: model.rating,
                reviewCount: model.reviewCount,
                distance: model.distance,
                isPremium: model.isPremium,
                isFavorite: model.isFavorite,
                serviceName: model.serviceName,
                servicePrice: model.servicePrice,
                address: model.address,
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
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
