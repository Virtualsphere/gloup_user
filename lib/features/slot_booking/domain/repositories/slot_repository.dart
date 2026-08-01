import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_day_result.dart';

abstract class SlotRepository {
  Future<Either<Failure, SlotDayResult>> getSlotStatus({
    required int salonId,
    required String date,
  });

  Future<Either<Failure, List<String>>> getStoreHolidays({
    required int salonId,
    required String from,
    required String to,
  });
}
