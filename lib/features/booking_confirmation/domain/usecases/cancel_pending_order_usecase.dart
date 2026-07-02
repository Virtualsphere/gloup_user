import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/order_repository.dart';

class CancelPendingOrderUseCase {
  final OrderRepository repository;

  CancelPendingOrderUseCase(this.repository);

  Future<Either<Failure, void>> call({required int orderId}) {
    return repository.cancelPendingOrder(orderId: orderId);
  }
}
