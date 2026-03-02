import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/category/data/datasources/category_remote_datasource.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/features/category/domain/repositories/category_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await dataSource.getCategories();
      final entities = models
          .map((model) => CategoryEntity(
                id: model.id,
                label: model.label,
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
  Future<Either<Failure, List<SalonEntity>>> getCategorySalons({
    required double latitude,
    required double longitude,
    required String categoryId,
    int? limit,
    int? page,
    String? gender,
    String? search,
  }) async {
    try {
      final response = await dataSource.getCategorySalons(
        latitude: latitude,
        longitude: longitude,
        categoryId: categoryId,
        limit: limit,
        page: page,
        gender: gender,
        search: search,
      );

      // Extract salons from the response model
      final entities = response.salons
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
