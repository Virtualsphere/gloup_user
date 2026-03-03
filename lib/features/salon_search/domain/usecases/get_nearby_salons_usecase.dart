import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/salon_search/domain/repositories/search_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class GetNearbySalonsParams {
  final double latitude;
  final double longitude;
  final int? limit;
  final int? page;
  final String? gender;

  GetNearbySalonsParams({
    required this.latitude,
    required this.longitude,
    this.limit,
    this.page,
    this.gender,
  });
}

class GetNearbySalonsUseCase {
  final SearchRepository repository;

  GetNearbySalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call(
    GetNearbySalonsParams params,
  ) async {
    return await repository.getNearbySalons(
      latitude: params.latitude,
      longitude: params.longitude,
      limit: params.limit,
      page: params.page,
      gender: params.gender,
    );
  }
}
