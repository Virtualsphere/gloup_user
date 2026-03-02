import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

abstract class SlotRepository {
  /// Get slot status for a specific salon and date
  Future<Either<Failure, List<SlotEntity>>> getSlotStatus({
    required int salonId,
    required String date,
  });
}
