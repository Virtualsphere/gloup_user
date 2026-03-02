import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';
import 'package:tressy/shared/domain/repositories/salon_repository.dart';

/// Shared Use Case for Getting Salons
/// Used by Home, Explore, Category, and other features
class GetSalonsUseCase {
  final SalonRepository repository;

  GetSalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    GetSalonsParams params,
  ) async {
    return await repository.getSalons(
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
      search: params.search,
      category: params.category,
    );
  }
}

/// Parameters for GetSalonsUseCase
class GetSalonsParams {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;
  final String? search;
  final String? category;

  GetSalonsParams({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
    this.search,
    this.category,
  });
}
