import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';

abstract class SalonDetailRepository {
  /// Get detailed information about a specific salon
  Future<Either<Failure, SalonDetailEntity>> getSalonDetails({
    required String salonId,
  });
}
