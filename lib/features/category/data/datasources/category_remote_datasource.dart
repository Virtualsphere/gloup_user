import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/category/data/models/category_model.dart';
import 'package:tressy/shared/data/models/salon_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<SalonsResponseModel> getCategorySalons({
    required double latitude,
    required double longitude,
    required String categoryId,
    int? limit,
    int? page,
    String? gender,
    String? search,
  });
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient dioClient;

  CategoryRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dioClient.get(ApiRoutes.getCategories);

      if (response.statusCode == 200) {
        final success = response.data['success'] ?? false;
        if (success && response.data['data'] != null) {
          final List<dynamic> categoryList = response.data['data'];

          // Parse categories with base image URL
          return categoryList
              .map((json) => CategoryModel.fromJson(
                    json,
                    imageBaseUrl: ApiRoutes.categoryImageBaseUrl,
                  ))
              .toList();
        } else {
          throw ServerException(
            message: response.data['message'] ?? 'Failed to fetch categories',
          );
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch categories',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<SalonsResponseModel> getCategorySalons({
    required double latitude,
    required double longitude,
    required String categoryId,
    int? limit,
    int? page,
    String? gender,
    String? search,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'lat': latitude,
        'lng': longitude,
        'category': categoryId,
      };

      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (gender != null) queryParams['gender'] = gender;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await dioClient.get(
        ApiRoutes.getAllStores,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          // Parse the response with pagination
          return SalonsResponseModel.fromJson(
            data,
            imageBaseUrl: ApiRoutes.imageBaseUrl,
          );
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch category salons',
          );
        }
      } else {
        throw ServerException(
          message:
              response.data['message'] ?? 'Failed to fetch category salons',
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
