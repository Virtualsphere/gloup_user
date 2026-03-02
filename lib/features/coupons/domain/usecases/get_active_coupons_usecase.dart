import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';
import 'package:tressy/features/coupons/domain/repositories/coupon_repository.dart';

class GetActiveCouponsUseCase {
  final CouponRepository repository;

  GetActiveCouponsUseCase(this.repository);

  Future<Either<Failure, List<CouponEntity>>> call() async {
    return await repository.getActiveCoupons();
  }
}
