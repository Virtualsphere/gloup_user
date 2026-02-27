import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';

class GetRecommendedSalonsUseCase {
  final HomeRepository repository;

  GetRecommendedSalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    GetRecommendedSalonsParams params,
  ) async {
    return await repository.getRecommendedSalons(
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
    );
  }
}

class GetRecommendedSalonsParams {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;

  GetRecommendedSalonsParams({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
  });
}
