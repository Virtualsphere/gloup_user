import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/home/data/models/home_models.dart';

/// Home Data Source
/// Handles API calls for home page data
abstract class HomeDataSource {
  Future<List<CarouselBannerModel>> getCarouselBanners();
  Future<NearbyStoresResponseModel> getPopularServices({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
  Future<TopSalonsResponseModel> getTopSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
}

/// Implementation with actual API calls
class HomeDataSourceImpl implements HomeDataSource {
  final DioClient dioClient;

  HomeDataSourceImpl(this.dioClient);

  @override
  Future<List<CarouselBannerModel>> getCarouselBanners() async {
    try {
      // Get auth token if available
      final token = LocalStorageService.accessToken;
      
      final response = await dioClient.get(
        ApiRoutes.getBanners,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if response has success field and data array
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> bannerList = data['data'];
          return bannerList
              .map((json) => CarouselBannerModel.fromJson(
                    json,
                    imageBaseUrl: ApiRoutes.bannerImageBaseUrl,
                  ))
              .toList();
        } else {
          throw ServerException(
            message: data['message'] ?? 'Invalid response format',
          );
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch banners',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<NearbyStoresResponseModel> getPopularServices({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    try {
      // Build request data with optional parameters
      final Map<String, dynamic> requestData = {
        'lat': latitude,
        'lng': longitude,
      };

      // Add optional parameters only if they are provided
      if (limit != null) requestData['limit'] = limit;
      if (page != null) requestData['page'] = page;
      if (gender != null) requestData['gender'] = gender;

      // Get auth token if available
      final token = LocalStorageService.accessToken;

      final response = await dioClient.post(
        ApiRoutes.getNearbyStores,
        data: requestData,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          // Parse the new response format with pagination
          return NearbyStoresResponseModel.fromJson(
            data['data'],
            imageBaseUrl: ApiRoutes.imageBaseUrl,
          );
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch popular services',
          );
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch popular services',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<TopSalonsResponseModel> getTopSalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
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

      // Get auth token if available
      final token = LocalStorageService.accessToken;

      final response = await dioClient.get(
        ApiRoutes.getTopSalons,
        queryParameters: queryParams,
        options: token != null && token.isNotEmpty
            ? Options(headers: {'userauth': token})
            : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true) {
          // Parse the response with pagination
          return TopSalonsResponseModel.fromJson(
            data,
            imageBaseUrl: ApiRoutes.imageBaseUrl,
          );
        } else {
          throw ServerException(
            message: data['message'] ?? 'Failed to fetch top salons',
          );
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch top salons',
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
