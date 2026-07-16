import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/booking_confirmation/data/models/guest_model.dart';

abstract class GuestRemoteDataSource {
  /// Get all guests for the current user
  Future<List<GuestModel>> getAllGuests();

  /// Add a new guest
  Future<void> addGuest({
    required String name,
    required String gender,
    required int age,
    required String phone,
  });

  /// Update an existing guest
  Future<void> updateGuest({
    required int guestId,
    String? name,
    String? gender,
    int? age,
    String? phone,
  });
}

class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  final DioClient dioClient;

  GuestRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<GuestModel>> getAllGuests() async {
    try {
      final response = await dioClient.get(ApiRoutes.getAllGuests);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => GuestModel.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to fetch guests',
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
  Future<void> addGuest({
    required String name,
    required String gender,
    required int age,
    required String phone,
  }) async {
    try {
      final requestData = {
        'name': name,
        'gender': gender,
        'age': age,
        'phone': phone,
      };

      final response = await dioClient.post(
        ApiRoutes.addGuest,
        data: requestData,
      );

      if (response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to add guest',
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
  Future<void> updateGuest({
    required int guestId,
    String? name,
    String? gender,
    int? age,
    String? phone,
  }) async {
    try {
      // Build optional update payload
      final requestData = <String, dynamic>{
        'guestId': guestId,
      };

      // Add optional fields
      if (name != null) requestData['name'] = name;
      if (gender != null) requestData['gender'] = gender;
      if (age != null) requestData['age'] = age;
      if (phone != null) requestData['phone'] = phone;

      final response = await dioClient.patch(
        ApiRoutes.updateGuest,
        data: requestData,
      );

      if (response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to update guest',
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
