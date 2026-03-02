import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    super.discountAmount = 50,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      discountAmount: json['discountAmount'] as int? ?? 50, // Use API value or default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountAmount': discountAmount,
    };
  }
}
