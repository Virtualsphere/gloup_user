import 'package:dartz/dartz.dart';
import 'package:tressy/core/error/failures.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/features/booking_confirmation/data/datasources/booking_remote_datasource.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';
import 'package:tressy/features/booking_confirmation/domain/entities/order_entity.dart';
import 'package:tressy/features/booking_confirmation/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final BookingRemoteDataSource dataSource;

  OrderRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, OrderEntity>> createOrder(
    CreateOrderRequest request,
  ) async {
    try {
      final model = await dataSource.createOrder(request);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      await dataSource.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on TimeoutException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
