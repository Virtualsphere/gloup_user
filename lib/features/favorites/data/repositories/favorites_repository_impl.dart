import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:tressy/features/favorites/domain/entities/favorite_entity.dart';
import 'package:tressy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FavoriteEntity>> toggleFavorite(int storeId) async {
    try {
      final result = await remoteDataSource.toggleFavorite(storeId);
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<SalonEntity>>> getFavorites() async {
    try {
      final result = await remoteDataSource.getFavorites();
      // Convert SalonModel list to SalonEntity list
      final entities = result.favorites.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
