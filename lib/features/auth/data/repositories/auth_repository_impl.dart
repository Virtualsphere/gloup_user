import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tressy/features/auth/domain/entities/auth_entity.dart';
import 'package:tressy/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, AuthEntity>> sendOtp(String phone) async {
    final disconnected = await leftIfDisconnected<AuthEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.sendOtp(phone);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> verifyOtp(
    String phone,
    String otp,
  ) async {
    final disconnected = await leftIfDisconnected<AuthEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.verifyOtp(phone, otp);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> googleLogin(String idToken) async {
    final disconnected = await leftIfDisconnected<AuthEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.googleLogin(idToken);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> appleLogin({
    required String authorizationCode,
    required String identityToken,
    required String userIdentifier,
  }) async {
    final disconnected = await leftIfDisconnected<AuthEntity>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.appleLogin(
        authorizationCode: authorizationCode,
        identityToken: identityToken,
        userIdentifier: userIdentifier,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
