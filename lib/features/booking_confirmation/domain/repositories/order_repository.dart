import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderRequest request);
  Future<Either<Failure, void>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}
