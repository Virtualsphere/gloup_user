import 'package:equatable/equatable.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';

class OrderState extends Equatable {
  final bool isLoading;
  final OrderEntity? order;
  final String? errorMessage;
  final bool isSuccess;
  final bool isPaymentVerified;
  final bool isVerifyingPayment;

  const OrderState({
    this.isLoading = false,
    this.order,
    this.errorMessage,
    this.isSuccess = false,
    this.isPaymentVerified = false,
    this.isVerifyingPayment = false,
  });

  factory OrderState.initial() => const OrderState();

  OrderState copyWithLoading() {
    return const OrderState(isLoading: true);
  }

  OrderState copyWithSuccess(OrderEntity order) {
    return OrderState(isLoading: false, order: order, isSuccess: true);
  }

  OrderState copyWithError(String message) {
    return OrderState(isLoading: false, errorMessage: message);
  }

  OrderState copyWithVerifyingPayment() {
    return copyWith(
        isVerifyingPayment: true, isSuccess: false, errorMessage: null);
  }

  OrderState copyWithPaymentVerified() {
    return copyWith(
        isVerifyingPayment: false, isSuccess: false, isPaymentVerified: true);
  }

  OrderState copyWithVerifyError(String message) {
    return copyWith(
        isVerifyingPayment: false, isSuccess: false, errorMessage: message);
  }

  OrderState copyWith({
    bool? isLoading,
    OrderEntity? order,
    String? errorMessage,
    bool? isSuccess,
    bool? isPaymentVerified,
    bool? isVerifyingPayment,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isPaymentVerified: isPaymentVerified ?? this.isPaymentVerified,
      isVerifyingPayment: isVerifyingPayment ?? this.isVerifyingPayment,
    );
  }

  OrderState copyWithReset() => const OrderState();

  @override
  List<Object?> get props => [
        isLoading,
        order,
        errorMessage,
        isSuccess,
        isPaymentVerified,
        isVerifyingPayment
      ];
}
