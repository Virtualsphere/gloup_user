import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/favorites/domain/entities/favorite_entity.dart';
import 'package:tressy/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  final FavoritesRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<Failure, FavoriteEntity>> call(int storeId) async {
    // Single API call - backend handles the toggle
    return await repository.toggleFavorite(storeId);
  }
}
