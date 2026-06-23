import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class GetTopSalonsParams {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;
  final String? minRating;
  final int? minPrice;
  final int? maxPrice;
  final String? search;
  final String? sort;

  GetTopSalonsParams({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
    this.minRating,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.sort,
  });
}

class GetTopSalonsUseCase {
  final HomeRepository repository;

  GetTopSalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    GetTopSalonsParams params,
  ) async {
    return await repository.getTopSalons(
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
      minRating: params.minRating,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      search: params.search,
      sort: params.sort,
    );
  }
}
