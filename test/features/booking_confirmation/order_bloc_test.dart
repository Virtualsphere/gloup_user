import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/cancel_pending_order_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/create_order_usecase.dart';
import 'package:tressy/features/booking_confirmation/domain/usecases/verify_payment_usecase.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_bloc.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_event.dart';
import 'package:tressy/features/booking_confirmation/presentation/bloc/order_state.dart';

import '../../helpers/test_fixtures.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

class MockVerifyPaymentUseCase extends Mock implements VerifyPaymentUseCase {}

class MockCancelPendingOrderUseCase extends Mock
    implements CancelPendingOrderUseCase {}

void main() {
  late MockCreateOrderUseCase createOrderUseCase;
  late MockVerifyPaymentUseCase verifyPaymentUseCase;
  late MockCancelPendingOrderUseCase cancelPendingOrderUseCase;

  OrderBloc buildBloc() => OrderBloc(
        createOrderUseCase: createOrderUseCase,
        verifyPaymentUseCase: verifyPaymentUseCase,
        cancelPendingOrderUseCase: cancelPendingOrderUseCase,
      );

  setUpAll(() {
    registerFallbackValue(testCreateOrderRequest);
  });

  setUp(() {
    createOrderUseCase = MockCreateOrderUseCase();
    verifyPaymentUseCase = MockVerifyPaymentUseCase();
    cancelPendingOrderUseCase = MockCancelPendingOrderUseCase();
  });

  group('OrderBloc', () {
    blocTest<OrderBloc, OrderState>(
      'emits loading then success when create order succeeds',
      build: buildBloc,
      act: (bloc) => bloc.add(const CreateOrderEvent(testCreateOrderRequest)),
      setUp: () {
        when(() => createOrderUseCase(any()))
            .thenAnswer((_) async => const Right(testOrder));
      },
      expect: () => [
        isA<OrderState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.order, 'order', isNull),
        isA<OrderState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.isSuccess, 'isSuccess', true)
            .having((s) => s.order, 'order', testOrder),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits loading then error when create order fails',
      build: buildBloc,
      act: (bloc) => bloc.add(const CreateOrderEvent(testCreateOrderRequest)),
      setUp: () {
        when(() => createOrderUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Order creation failed')),
        );
      },
      expect: () => [
        isA<OrderState>().having((s) => s.isLoading, 'isLoading', true),
        isA<OrderState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', 'Order creation failed'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits verifying then payment verified when verify payment succeeds',
      build: buildBloc,
      seed: () => OrderState.initial().copyWithSuccess(testOrder),
      act: (bloc) => bloc.add(
        const VerifyPaymentEvent(
          razorpayOrderId: 'order_test',
          razorpayPaymentId: 'pay_test',
          razorpaySignature: 'sig_test',
        ),
      ),
      setUp: () {
        when(
          () => verifyPaymentUseCase(
            razorpayOrderId: any(named: 'razorpayOrderId'),
            razorpayPaymentId: any(named: 'razorpayPaymentId'),
            razorpaySignature: any(named: 'razorpaySignature'),
          ),
        ).thenAnswer((_) async => const Right(null));
      },
      expect: () => [
        isA<OrderState>()
            .having((s) => s.isVerifyingPayment, 'isVerifyingPayment', true)
            .having((s) => s.isSuccess, 'isSuccess', false),
        isA<OrderState>()
            .having((s) => s.isPaymentVerified, 'isPaymentVerified', true)
            .having((s) => s.isVerifyingPayment, 'isVerifyingPayment', false),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits verifying then verify error when payment verification fails',
      build: buildBloc,
      seed: () => OrderState.initial().copyWithSuccess(testOrder),
      act: (bloc) => bloc.add(
        const VerifyPaymentEvent(
          razorpayOrderId: 'order_test',
          razorpayPaymentId: 'pay_test',
          razorpaySignature: 'bad_sig',
        ),
      ),
      setUp: () {
        when(
          () => verifyPaymentUseCase(
            razorpayOrderId: any(named: 'razorpayOrderId'),
            razorpayPaymentId: any(named: 'razorpayPaymentId'),
            razorpaySignature: any(named: 'razorpaySignature'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Payment verification failed')),
        );
      },
      expect: () => [
        isA<OrderState>().having((s) => s.isVerifyingPayment, 'isVerifyingPayment', true),
        isA<OrderState>()
            .having((s) => s.errorMessage, 'errorMessage', 'Payment verification failed')
            .having((s) => s.isPaymentVerified, 'isPaymentVerified', false),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'resets to initial state on ResetOrderEvent',
      build: buildBloc,
      seed: () => OrderState.initial().copyWithSuccess(testOrder),
      act: (bloc) => bloc.add(const ResetOrderEvent()),
      expect: () => [OrderState.initial()],
    );

    blocTest<OrderBloc, OrderState>(
      'clears success flag when Razorpay checkout opens',
      build: buildBloc,
      seed: () => OrderState.initial().copyWithSuccess(testOrder),
      act: (bloc) => bloc.add(const RazorpayOpenedEvent()),
      expect: () => [
        isA<OrderState>()
            .having((s) => s.isSuccess, 'isSuccess', false)
            .having((s) => s.order, 'order', testOrder),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'clears success and error when payment fails',
      build: buildBloc,
      seed: () => OrderState.initial().copyWithSuccess(testOrder),
      act: (bloc) => bloc.add(const PaymentFailedEvent()),
      expect: () => [
        isA<OrderState>()
            .having((s) => s.isSuccess, 'isSuccess', false)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );
  });
}
