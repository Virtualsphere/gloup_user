import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/home/data/models/service_category_model.dart';
import 'package:tressy/shared/data/models/salon_model.dart';

abstract class ServiceDiscoveryDataSource {
  Future<List<ServiceCategoryModel>> getTopCategories({String sex = 'male'});

  Future<List<SalonModel>> getStoresByCategory({
    required String categoryId,
    required String sex,
    required double lat,
    required double lng,
    String budget = '',
    String rating = '',
  });
}

class ServiceDiscoveryDataSourceImpl implements ServiceDiscoveryDataSource {
  final DioClient dioClient;

  ServiceDiscoveryDataSourceImpl(this.dioClient);

  @override
  Future<List<ServiceCategoryModel>> getTopCategories(
      {String sex = 'male'}) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.getTopCategories,
        data: {'sex': sex},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data
            .map((e) => ServiceCategoryModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList();
      }

      throw ServerException(
        message: response.data['message']?.toString() ??
            'Failed to fetch service categories',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<SalonModel>> getStoresByCategory({
    required String categoryId,
    required String sex,
    required double lat,
    required double lng,
    String budget = '',
    String rating = '',
  }) async {
    try {
      final payload = <String, dynamic>{
        'category_id': categoryId == 'all' ? '' : categoryId,
        'sex': sex,
        'lat': lat,
        'lng': lng,
        'budget': budget,
        'rating': rating,
      };

      final response = await dioClient.post(
        ApiRoutes.getStoresByCategory,
        data: payload,
        queryParameters: {'lat': lat, 'lng': lng},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data
            .map((e) => SalonModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                  imageBaseUrl: ApiRoutes.imageBaseUrl,
                ))
            .toList();
      }

      throw ServerException(
        message: response.data['message']?.toString() ??
            'Failed to fetch salons by category',
      );
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
