import 'package:equatable/equatable.dart';

class CouponEntity extends Equatable {
  final int id;
  final String code;
  final int discountAmount; // Default discount for display

  const CouponEntity({
    required this.id,
    required this.code,
    this.discountAmount = 50, // Default discount amount
  });

  @override
  List<Object?> get props => [id, code, discountAmount];
}
