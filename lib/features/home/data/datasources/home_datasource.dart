import 'package:dio/dio.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/api_exception.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/features/home/data/models/home_models.dart';
import 'package:tressy/features/home/data/models/home_mock_data.dart';

/// Home Data Source
/// Handles API calls for home page data
abstract class HomeDataSource {
  Future<List<CarouselBannerModel>> getCarouselBanners();
  Future<List<SalonModel>> getPopularServices({
    required double latitude,
    required double longitude,
    String gender = 'unisex',
  });
  Future<List<SalonModel>> getTopSalons({
    required double latitude,
    required double longitude,
  });
  Future<List<SalonModel>> getRecommendedSalons();
}

/// Implementation with actual API calls
class HomeDataSourceImpl implements HomeDataSource {
  final DioClient dioClient;

  HomeDataSourceImpl(this.dioClient);

  @override
  Future<List<CarouselBannerModel>> getCarouselBanners() async {
    try {
      final response = await dioClient.get(ApiRoutes.getBanners);

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if response has success field and data array
        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> bannerList = data['data'];
          return bannerList
              .map((json) => CarouselBannerModel.fromJson(
                    json,
                    imageBaseUrl: ApiRoutes.imageProfileUrl,
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
  Future<List<SalonModel>> getPopularServices({
    required double latitude,
    required double longitude,
    String gender = 'unisex',
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.getNearbyStores,
        data: {
          'lat': latitude,
          'lng': longitude,
          'gender': gender,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> salonsJson = data['data'];
          return salonsJson
              .map((json) => SalonModel.fromJson(
                    json,
                    imageBaseUrl: ApiRoutes.imageBaseUrl,
                  ))
              .toList();
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
  Future<List<SalonModel>> getTopSalons({
    required double latitude,
    required double longitude,
  }) async {
    // TODO: Replace with actual API call
    // Example: return await dioClient.get(
    //   '/api/v1/home/top-salons',
    //   queryParameters: {
    //     'lat': latitude,
    //     'lng': longitude,
    //     'radius': radius,
    //   },
    // );
    return await HomeMockData.simulateApiCall(
      HomeMockData.getTopSalons(),
      delaySeconds: 2,
    );
  }

  @override
  Future<List<SalonModel>> getRecommendedSalons() async {
    // TODO: Replace with actual API call
    // Example: return await dioClient.get('/api/v1/home/recommended');
    return await HomeMockData.simulateApiCall(
      HomeMockData.getRecommendedSalons(),
      delaySeconds: 2,
    );
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
