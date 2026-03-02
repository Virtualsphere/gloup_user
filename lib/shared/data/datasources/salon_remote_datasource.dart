import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/shared/data/models/salon_model.dart';

/// Shared Salon Remote Data Source
/// Handles API calls for salon data across multiple features
abstract class SalonRemoteDataSource {
  Future<SalonsResponseModel> getSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
  });
}

/// Implementation of Shared Salon Remote Data Source
class SalonRemoteDataSourceImpl implements SalonRemoteDataSource {
  final DioClient dioClient;

  SalonRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SalonsResponseModel> getSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
    String? search,
    String? category,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'lat': latitude,
        'lng': longitude,
      };

      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (gender != null) queryParams['gender'] = gender;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;

      // Get auth token if available
      final token = LocalStorageService.accessToken;

      final response = await dioClient.get(
        ApiRoutes.getAllStores,
        queryParameters: queryParams,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          return SalonsResponseModel.fromJson(
            data,
            imageBaseUrl: ApiRoutes.imageBaseUrl,
          );
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch salons',
          );
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch salons',
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
