import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/create_order_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/verify_payment_usecase.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;

  OrderBloc({
    required this.createOrderUseCase,
    required this.verifyPaymentUseCase,
  }) : super(OrderState.initial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<ResetOrderEvent>(_onReset);
    on<VerifyPaymentEvent>(_onVerifyPayment);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWithLoading());

    // print('Create Order Request: ${event.request.toJson()}');

    final result = await createOrderUseCase(event.request);

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (order) => emit(state.copyWithSuccess(order)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWithVerifyingPayment());

    final result = await verifyPaymentUseCase(
      razorpayOrderId: event.razorpayOrderId,
      razorpayPaymentId: event.razorpayPaymentId,
      razorpaySignature: event.razorpaySignature,
    );

    result.fold(
      (failure) => emit(state.copyWithVerifyError(failure.message)),
      (_) => emit(state.copyWithPaymentVerified()),
    );
  }

  void _onReset(ResetOrderEvent event, Emitter<OrderState> emit) {
    emit(state.copyWithReset());
  }
}
