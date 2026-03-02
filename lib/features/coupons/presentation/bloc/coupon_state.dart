import 'package:equatable/equatable.dart';
import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {
  const CouponInitial();
}

class CouponLoading extends CouponState {
  const CouponLoading();
}

class CouponLoaded extends CouponState {
  final List<CouponEntity> coupons;

  const CouponLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class CouponFailure extends CouponState {
  final String message;

  const CouponFailure(this.message);

  @override
  List<Object?> get props => [message];
}
