import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/salon_details/domain/entities/salon_detail_entity.dart';
import 'package:tressy/features/salon_details/domain/repositories/salon_detail_repository.dart';

class GetSalonDetailsUseCase {
  final SalonDetailRepository repository;

  GetSalonDetailsUseCase(this.repository);

  Future<Either<Failure, SalonDetailEntity>> call(String salonId) async {
    return await repository.getSalonDetails(salonId: salonId);
  }
}
