import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/booking_confirmation/data/models/order_model.dart';

abstract class BookingRemoteDataSource {
  Future<OrderModel> createOrder(CreateOrderRequest request);

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final DioClient dioClient;

  BookingRemoteDataSourceImpl(this.dioClient);

  @override
  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.createOrder,
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return OrderModel.fromJson(data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to create order',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.paymentSuccess,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Payment verification failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        String? message = e.message;
        String? errorType;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('error') &&
              responseData['error'] is Map<String, dynamic>) {
            message = responseData['error']['message'] ?? message;
            errorType = responseData['error']['type'];
          } else {
            message = responseData['message'] ?? message;
          }
        }

        if (statusCode == 401 || errorType == 'UnauthorizedException') {
          return UnauthorizedException(message: message);
        } else if (statusCode == 404 || errorType == 'NotFoundException') {
          return NotFoundException(message: message);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message: message);
        }
        return ApiException(
          message: message ?? 'Request failed',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: e.message ?? 'Unknown error occurred');
    }
  }
}
