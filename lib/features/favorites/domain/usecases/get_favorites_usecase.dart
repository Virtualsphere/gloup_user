import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<Failure, List<SalonEntity>>> call() async {
    return await repository.getFavorites();
  }
}
