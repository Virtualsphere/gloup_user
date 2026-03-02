import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/slot_booking/data/datasources/slot_remote_datasource.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';
import 'package:tressy/features/slot_booking/domain/repositories/slot_repository.dart';

class SlotRepositoryImpl implements SlotRepository {
  final SlotRemoteDataSource remoteDataSource;

  SlotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SlotEntity>>> getSlotStatus({
    required int salonId,
    required String date,
  }) async {
    try {
      final slots = await remoteDataSource.getSlotStatus(
        salonId: salonId,
        date: date,
      );
      return Right(slots.map((model) => model.toEntity()).toList());
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
