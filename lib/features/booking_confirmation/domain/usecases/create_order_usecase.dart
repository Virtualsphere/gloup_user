import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(CreateOrderRequest request) {
    return repository.createOrder(request);
  }
}
