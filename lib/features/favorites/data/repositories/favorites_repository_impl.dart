import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:tressy/features/favorites/domain/entities/favorite_entity.dart';
import 'package:tressy/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:tressy/shared/domain/entities/salon_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FavoritesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, FavoriteEntity>> toggleFavorite(int storeId) async {
    final disconnected = await leftIfDisconnected<FavoriteEntity>(networkInfo);
    if (disconnected != null) return disconnected;

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
    final disconnected =
        await leftIfDisconnected<List<SalonEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.getFavorites();
      final entities =
          result.favorites.map((model) => model.toEntity()).toList();
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
