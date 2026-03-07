import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/order_repository.dart';

class VerifyPaymentUseCase {
  final OrderRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) {
    return repository.verifyPayment(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }
}
