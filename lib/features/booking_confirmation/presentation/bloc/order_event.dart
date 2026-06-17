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

/// Clears [OrderState.isSuccess] after Razorpay checkout opens so the listener
/// does not reopen checkout on rebuild.
class RazorpayOpenedEvent extends OrderEvent {
  const RazorpayOpenedEvent();
}

/// Keeps the pending order in state after Razorpay reports failure or dismiss.
class PaymentFailedEvent extends OrderEvent {
  const PaymentFailedEvent();
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
