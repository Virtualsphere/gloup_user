import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/guest_entity.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/guest_repository.dart';

class GetAllGuestsUseCase {
  final GuestRepository repository;

  GetAllGuestsUseCase(this.repository);

  Future<Either<Failure, List<GuestEntity>>> call() async {
    return await repository.getAllGuests();
  }
}
