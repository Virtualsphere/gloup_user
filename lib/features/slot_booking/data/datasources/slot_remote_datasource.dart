import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/slot_booking/data/models/slot_model.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_day_result.dart';
import 'package:tressy/features/slot_booking/domain/entities/slot_entity.dart';

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
        final dataMap = _asStringKeyedMap(data);
        if (dataMap != null) {
          final isHoliday = dataMap['is_holiday'] == true;
          final reason = dataMap['holiday_reason']?.toString();
          final holidayType = dataMap['holiday_type']?.toString();
          final weekdayName = dataMap['weekday_name']?.toString();
          final slots = _parseSlots(dataMap['slots']);
          return SlotDayResult(
            isHoliday: isHoliday,
            holidayReason: reason,
            holidayType: holidayType,
            weekdayName: weekdayName,
            slots: slots,
          );
        }

        // Legacy shape: List of slots
        return SlotDayResult(isHoliday: false, slots: _parseSlots(data));
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
        final dataMap = _asStringKeyedMap(data);
        final dates = _asList(dataMap != null ? dataMap['dates'] : data);
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

  /// Avoids `as List` crashes when APIs return `{}` or object-encoded arrays.
  List<dynamic> _asList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is Map) return value.values.toList();
    return const [];
  }

  Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<SlotEntity> _parseSlots(dynamic raw) {
    return _asList(raw)
        .map((json) {
          final map = _asStringKeyedMap(json);
          if (map == null) return null;
          return SlotModel.fromJson(map).toEntity();
        })
        .whereType<SlotEntity>()
        .toList();
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
