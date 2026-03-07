import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/bookings/domain/entities/appointment_entity.dart';
import 'package:tressy/features/bookings/domain/repositories/appointments_repository.dart';

class GetAllAppointmentsUseCase {
  final AppointmentsRepository repository;

  GetAllAppointmentsUseCase(this.repository);

  Future<Either<Failure, Map<String, List<AppointmentEntity>>>> call() {
    return repository.getAllAppointments();
  }
}
