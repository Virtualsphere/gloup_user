import 'package:equatable/equatable.dart';

class CouponEntity extends Equatable {
  final int id;
  final String code;
  final int discountAmount; // Default discount for display
  final String discountType; // 'flat' | 'percentage'

  const CouponEntity({
    required this.id,
    required this.code,
    this.discountAmount = 50, // Default discount amount
    this.discountType = 'flat',
  });

  @override
  List<Object?> get props => [id, code, discountAmount, discountType];
}
