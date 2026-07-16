import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/category/data/datasources/category_remote_datasource.dart';
import 'package:tressy/features/category/domain/entities/category_entity.dart';
import 'package:tressy/features/category/domain/repositories/category_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource dataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    final disconnected =
        await leftIfDisconnected<List<CategoryEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

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
    final disconnected =
        await leftIfDisconnected<List<SalonEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

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
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
