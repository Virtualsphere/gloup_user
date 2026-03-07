import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';

/// Request payload for creating an order
class CreateOrderRequest {
  final String bookingDate;
  final int slotId;
  final List<Map<String, dynamic>> services;
  final bool isCombo;
  final String bookingFor;
  final int? guestId;
  final int? professionalId;
  final dynamic storeId;
  final double gst;
  final double platformFee;
  final double serviceAmount;
  final double serviceDiscount;
  final double? couponDiscount;
  final String? couponCode;
  final double walletAmountUsed;
  final double finalAmount;

  const CreateOrderRequest({
    required this.bookingDate,
    required this.slotId,
    required this.services,
    required this.isCombo,
    required this.bookingFor,
    this.guestId,
    this.professionalId,
    required this.storeId,
    required this.gst,
    required this.platformFee,
    required this.serviceAmount,
    required this.serviceDiscount,
    this.couponDiscount,
    this.couponCode,
    required this.walletAmountUsed,
    required this.finalAmount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'booking_date': bookingDate,
      'slot_id': slotId,
      'services': services,
      'is_combo': isCombo,
      'booking_for': bookingFor,
      'store_id': storeId,
      'gst': gst,
      'platform_fee': platformFee,
      'amount': finalAmount,
      'payment_status': 'pending',
      'status': 'pending',
      'is_discounted': serviceDiscount > 0,
      'discounted_amount': serviceDiscount,
      'wallet_amount_used': walletAmountUsed,
      'is_wallet': walletAmountUsed > 0,
    };

    if (guestId != null) data['guest_id'] = guestId;
    if (professionalId != null) data['professional_id'] = professionalId;
    if (couponCode != null) data['coupon_code'] = couponCode;
    if (couponDiscount != null) data['coupon_discount_amount'] = couponDiscount;

    return data;
  }
}

/// Response model for create order API
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.razorpayOrderId,
    required super.amount,
    required super.currency,
    required super.bookingDate,
    required super.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      bookingDate: json['booking_date'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      razorpayOrderId: razorpayOrderId,
      amount: amount,
      currency: currency,
      bookingDate: bookingDate,
      status: status,
    );
  }
}
