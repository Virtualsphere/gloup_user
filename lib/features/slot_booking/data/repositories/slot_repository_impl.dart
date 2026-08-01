import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/network_info.dart';
import 'package:tressy/core/network/repository_network_guard.dart';
import 'package:tressy/features/slot_booking/data/datasources/slot_remote_datasource.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_day_result.dart';
import 'package:tressy/features/slot_booking/domain/repositories/slot_repository.dart';

class SlotRepositoryImpl implements SlotRepository {
  final SlotRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SlotRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Either<Failure, T>? _mapException<T>(Object e) {
    if (e is NetworkException) return Left(NetworkFailure(e.message));
    if (e is ServerException) return Left(ServerFailure(e.message));
    if (e is TimeoutException) return Left(NetworkFailure(e.message));
    if (e is UnauthorizedException) {
      return Left(AuthenticationFailure(e.message));
    }
    if (e is ApiException) return Left(ServerFailure(e.message));
    return Left(ServerFailure('Unexpected error: ${e.toString()}'));
  }

  @override
  Future<Either<Failure, SlotDayResult>> getSlotStatus({
    required int salonId,
    required String date,
  }) async {
    final disconnected =
        await leftIfDisconnected<SlotDayResult>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final result = await remoteDataSource.getSlotStatus(
        salonId: salonId,
        date: date,
      );
      return Right(result);
    } catch (e) {
      return _mapException<SlotDayResult>(e)!;
    }
  }

  @override
  Future<Either<Failure, List<String>>> getStoreHolidays({
    required int salonId,
    required String from,
    required String to,
  }) async {
    final disconnected =
        await leftIfDisconnected<List<String>>(networkInfo);
    if (disconnected != null) return disconnected;

    try {
      final dates = await remoteDataSource.getStoreHolidays(
        salonId: salonId,
        from: from,
        to: to,
      );
      return Right(dates);
    } catch (e) {
      return _mapException<List<String>>(e)!;
    }
  }
}
