import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_day_result.dart';
import 'package:tressy/features/slot_booking/domain/repositories/slot_repository.dart';

class GetSlotStatusUseCase {
  final SlotRepository repository;

  GetSlotStatusUseCase(this.repository);

  Future<Either<Failure, SlotDayResult>> call({
    required int salonId,
    required String date,
  }) async {
    return await repository.getSlotStatus(
      salonId: salonId,
      date: date,
    );
  }
}

class GetStoreHolidaysUseCase {
  final SlotRepository repository;

  GetStoreHolidaysUseCase(this.repository);

  Future<Either<Failure, List<String>>> call({
    required int salonId,
    required String from,
    required String to,
  }) {
    return repository.getStoreHolidays(
      salonId: salonId,
      from: from,
      to: to,
    );
  }
}
