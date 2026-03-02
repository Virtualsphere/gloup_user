import 'package:equatable/equatable.dart';

abstract class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

class GetActiveCouponsEvent extends CouponEvent {
  const GetActiveCouponsEvent();
}

class RefreshCouponsEvent extends CouponEvent {
  const RefreshCouponsEvent();
}
