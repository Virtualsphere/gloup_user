import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/home/domain/entities/home_entity.dart';
import 'package:tressy/features/home/domain/repositories/home_repository.dart';

class GetRecommendedSalonsUseCase {
  final HomeRepository repository;

  GetRecommendedSalonsUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call() async {
    return await repository.getRecommendedSalons();
  }
}
