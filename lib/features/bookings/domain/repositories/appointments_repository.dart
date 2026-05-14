import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, Map<String, List<AppointmentEntity>>>>
      getAllAppointments();
}
