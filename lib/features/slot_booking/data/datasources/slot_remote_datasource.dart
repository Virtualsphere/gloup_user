import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/slot_booking/data/models/slot_model.dart';

abstract class SlotRemoteDataSource {
  /// Get slot status for a specific salon and date
  Future<List<SlotModel>> getSlotStatus({
    required int salonId,
    required String date,
  });
}

class SlotRemoteDataSourceImpl implements SlotRemoteDataSource {
  final DioClient dioClient;

  SlotRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<SlotModel>> getSlotStatus({
    required int salonId,
    required String date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.getSlotStatus,
        queryParameters: {
          'saloon_id': salonId,
          'date': date, // Format: YYYY-MM-DD (e.g., 2025-12-20)
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => SlotModel.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to fetch slot status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
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
