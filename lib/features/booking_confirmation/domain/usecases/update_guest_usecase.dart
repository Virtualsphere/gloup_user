import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/guest_repository.dart';

class UpdateGuestUseCase {
  final GuestRepository repository;

  UpdateGuestUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int guestId,
    String? name,
    String? gender,
    int? age,
    String? phone,
  }) async {
    return await repository.updateGuest(
      guestId: guestId,
      name: name,
      gender: gender,
      age: age,
      phone: phone,
    );
  }
}
