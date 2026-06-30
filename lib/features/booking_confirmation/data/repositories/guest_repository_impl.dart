import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/booking_confirmation/data/datasources/guest_remote_datasource.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/guest_entity.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/guest_repository.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GuestRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<GuestEntity>>> getAllGuests() async {
    final disconnected =
        await leftIfDisconnected<List<GuestEntity>>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final guests = await remoteDataSource.getAllGuests();
      return Right(guests.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addGuest({
    required String name,
    required String gender,
    required int age,
    required String phone,
  }) async {
    final disconnected = await leftIfDisconnected<void>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      await remoteDataSource.addGuest(
        name: name,
        gender: gender,
        age: age,
        phone: phone,
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGuest({
    required int guestId,
    String? name,
    String? gender,
    int? age,
    String? phone,
  }) async {
    final disconnected = await leftIfDisconnected<void>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      await remoteDataSource.updateGuest(
        guestId: guestId,
        name: name,
        gender: gender,
        age: age,
        phone: phone,
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
