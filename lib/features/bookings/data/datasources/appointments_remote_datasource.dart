import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/bookings/data/models/appointment_model.dart';

abstract class AppointmentsRemoteDataSource {
  Future<Map<String, List<AppointmentModel>>> getAllAppointments();
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final DioClient dioClient;

  AppointmentsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, List<AppointmentModel>>> getAllAppointments() async {
    try {
      final token = LocalStorageService.accessToken;

      final response = await dioClient.post(
        ApiRoutes.getAllAppointments,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      final upcoming = (data['upcoming'] as List<dynamic>? ?? [])
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final past = (data['past'] as List<dynamic>? ?? [])
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return {'upcoming': upcoming, 'past': past};
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
        if (statusCode == 401) return UnauthorizedException(message: message);
        return ApiException(message: message ?? 'Request failed', statusCode: statusCode);
      default:
        return ApiException(message: e.message ?? 'Unknown error occurred');
    }
  }
}
