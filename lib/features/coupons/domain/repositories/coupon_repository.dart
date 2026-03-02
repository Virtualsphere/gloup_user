import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<Either<Failure, List<CouponEntity>>> getActiveCoupons();
}
