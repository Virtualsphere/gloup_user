import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/shared/data/datasources/salon_remote_datasource.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/domain/repositories/salon_repository.dart';

/// Shared Salon Repository Implementation
class SalonRepositoryImpl implements SalonRepository {
  final SalonRemoteDataSource dataSource;

  SalonRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<SalonEntity>>> getSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
  }) async {
    try {
      final response = await dataSource.getSalons(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
        search: search,
        category: category,
      );

      // Convert models to entities
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
