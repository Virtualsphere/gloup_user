import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
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
      final token = LocalStorageService.accessToken;

      final response = await dioClient.post(
        ApiRoutes.createOrder,
        data: request.toJson(),
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
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
      final token = LocalStorageService.accessToken;

      print('🔐 Verify Payment → orderId=$razorpayOrderId paymentId=$razorpayPaymentId');

      final response = await dioClient.post(
        ApiRoutes.paymentSuccess,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      print('🔐 Verify Payment response: ${response.statusCode} → ${response.data}');

      if (response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Payment verification failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('🔐 Verify Payment DioException: ${e.type} → ${e.message}');
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      print('🔐 Verify Payment unexpected error: $e');
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
        final message = e.response?.data['message'] ?? e.message;
        if (statusCode == 401) {
          return UnauthorizedException(message: message);
        } else if (statusCode == 404) {
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
