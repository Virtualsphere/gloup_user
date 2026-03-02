import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class GetPopularServicesParams {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;

  GetPopularServicesParams({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
  });
}

class GetPopularServicesUseCase {
  final HomeRepository repository;

  GetPopularServicesUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    GetPopularServicesParams params,
  ) async {
    return await repository.getPopularServices(
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
    );
  }
}
