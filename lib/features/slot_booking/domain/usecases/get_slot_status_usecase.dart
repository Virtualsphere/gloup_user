import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';
import 'package:tressy/features/slot_booking/domain/repositories/slot_repository.dart';

class GetSlotStatusUseCase {
  final SlotRepository repository;

  GetSlotStatusUseCase(this.repository);

  Future<Either<Failure, List<SlotEntity>>> call({
    required int salonId,
    required String date,
  }) async {
    return await repository.getSlotStatus(
      salonId: salonId,
      date: date,
    );
  }
}
