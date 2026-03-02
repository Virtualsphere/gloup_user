import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/guest_repository.dart';

class AddGuestUseCase {
  final GuestRepository repository;

  AddGuestUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String gender,
    required int age,
    required String phone,
  }) async {
    return await repository.addGuest(
      name: name,
      gender: gender,
      age: age,
      phone: phone,
    );
  }
}
