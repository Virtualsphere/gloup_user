import 'package:tressy/features/coupons/domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    required super.discountAmount,
    super.discountType,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      discountAmount: json['discountValue'] as int? ?? 0,
      discountType: json['discountType'] as String? ?? 'flat',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_value': discountAmount,
      'discountType': discountType,
    };
  }
}
