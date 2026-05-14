import 'package:equatable/equatable.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final CreateOrderRequest request;

  const CreateOrderEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetOrderEvent extends OrderEvent {
  const ResetOrderEvent();
}

class VerifyPaymentEvent extends OrderEvent {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  const VerifyPaymentEvent({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  @override
  List<Object?> get props =>
      [razorpayOrderId, razorpayPaymentId, razorpaySignature];
}
