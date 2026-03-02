import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/favorites/domain/entities/favorite_entity.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, FavoriteEntity>> toggleFavorite(int storeId);
  Future<Either<Failure, List<SalonEntity>>> getFavorites();
}
