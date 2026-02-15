import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';

class GetPopularServicesParams {
  final double latitude;
  final double longitude;

  GetPopularServicesParams({
    required this.latitude,
    required this.longitude,
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
    );
  }
}
