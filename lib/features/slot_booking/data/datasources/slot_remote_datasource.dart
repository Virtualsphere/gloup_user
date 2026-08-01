import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/slot_booking/data/models/slot_model.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_day_result.dart';

abstract class SlotRemoteDataSource {
  Future<SlotDayResult> getSlotStatus({
    required int salonId,
    required String date,
  });

  Future<List<String>> getStoreHolidays({
    required int salonId,
    required String from,
    required String to,
  });
}

class SlotRemoteDataSourceImpl implements SlotRemoteDataSource {
  final DioClient dioClient;

  SlotRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SlotDayResult> getSlotStatus({
    required int salonId,
    required String date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.getSlotStatus,
        queryParameters: {
          'saloon_id': salonId,
          'date': date,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // New shape: { is_holiday, holiday_reason, slots }
        if (data is Map) {
          final isHoliday = data['is_holiday'] == true;
          final reason = data['holiday_reason']?.toString();
          final holidayType = data['holiday_type']?.toString();
          final weekdayName = data['weekday_name']?.toString();
          final list = (data['slots'] as List<dynamic>? ?? []);
          final slots = list
              .map((json) => SlotModel.fromJson(json as Map<String, dynamic>))
              .map((m) => m.toEntity())
              .toList();
          return SlotDayResult(
            isHoliday: isHoliday,
            holidayReason: reason,
            holidayType: holidayType,
            weekdayName: weekdayName,
            slots: slots,
          );
        }

        // Legacy shape: List of slots
        final list = data as List<dynamic>? ?? [];
        final slots = list
            .map((json) => SlotModel.fromJson(json as Map<String, dynamic>))
            .map((m) => m.toEntity())
            .toList();
        return SlotDayResult(isHoliday: false, slots: slots);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to fetch slot status',
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

  @override
  Future<List<String>> getStoreHolidays({
    required int salonId,
    required String from,
    required String to,
  }) async {
    try {
      final response = await dioClient.get(
        ApiRoutes.storeHolidays,
        queryParameters: {
          'saloon_id': salonId,
          'from': from,
          'to': to,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final dates = (data is Map ? data['dates'] : null) as List<dynamic>? ??
            <dynamic>[];
        return dates
            .map((d) {
              final s = d.toString();
              return s.length >= 10 ? s.substring(0, 10) : s;
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
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
