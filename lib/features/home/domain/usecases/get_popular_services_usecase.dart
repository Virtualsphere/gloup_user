import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';

class GetPopularServicesParams {
  final double latitude;
  final double longitude;
  final String gender;

  GetPopularServicesParams({
    required this.latitude,
    required this.longitude,
    this.gender = 'unisex',
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
      gender: params.gender,
    );
  }
}
