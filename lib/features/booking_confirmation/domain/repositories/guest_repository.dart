import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/guest_entity.dart';

abstract class GuestRepository {
  /// Get all guests for the current user
  Future<Either<Failure, List<GuestEntity>>> getAllGuests();
  
  /// Add a new guest
  Future<Either<Failure, void>> addGuest({
    required String name,
    required String gender,
    required int age,
    required String phone,
  });
  
  /// Update an existing guest
  Future<Either<Failure, void>> updateGuest({
    required int guestId,
    String? name,
    String? gender,
    int? age,
    String? phone,
  });
}
