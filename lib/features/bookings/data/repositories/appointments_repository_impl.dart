import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/bookings/data/datasources/appointments_remote_datasource.dart';
import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';
import 'package:tressy/features/bookings/domain/repositories/appointments_repository.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource remoteDataSource;

  AppointmentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, List<AppointmentEntity>>>>
      getAllAppointments() async {
    try {
      final result = await remoteDataSource.getAllAppointments();
      return Right({
        'upcoming': result['upcoming']!.map((m) => m.toEntity()).toList(),
        'past': result['past']!.map((m) => m.toEntity()).toList(),
      });
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
