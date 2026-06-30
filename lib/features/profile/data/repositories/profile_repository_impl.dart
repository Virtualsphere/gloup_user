import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/profile/data/datasources/profile_remote_datasources.dart';
import 'package:tressy/features/profile/domain/entities/profile_entity.dart';
import 'package:tressy/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource dataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    final disconnected = await leftIfDisconnected<ProfileEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final model = await dataSource.getProfile();
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final disconnected = await leftIfDisconnected<void>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      await dataSource.logout();
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    final disconnected = await leftIfDisconnected<ProfileEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await dataSource.updateProfile(profile);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DeleteProfileEntity>> deleteProfile() async {
    final disconnected =
        await leftIfDisconnected<DeleteProfileEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final model = await dataSource.deleteProfile();
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
