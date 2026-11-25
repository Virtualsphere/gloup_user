import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/shared/data/datasources/salon_remote_datasource.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/domain/repositories/salon_repository.dart';

/// Shared Salon Repository Implementation
class SalonRepositoryImpl implements SalonRepository {
  final SalonRemoteDataSource dataSource;
  final NetworkInfo networkInfo;

  SalonRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<SalonEntity>>> getSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    final result = await getSalonsPage(
      latitude: latitude,
      longitude: longitude,
      limit: limit,
      page: page,
      gender: gender,
      search: search,
      category: category,
      filters: filters,
    );
    return result.map((p) => p.salons);
  }

  @override
  Future<Either<Failure, SalonPage>> getSalonsPage({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    final disconnected = await leftIfDisconnected<SalonPage>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final response = await dataSource.getSalons(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
        page: page,
        gender: gender,
        search: search,
        category: category,
        filters: filters,
      );

      return Right(SalonPage(
        salons: response.salons.map((model) => model.toEntity()).toList(),
        totalRecords: response.pagination.totalRecords,
      ));
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
