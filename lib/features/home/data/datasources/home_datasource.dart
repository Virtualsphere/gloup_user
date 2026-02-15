import 'package:tressy/features/home/data/models/home_models.dart';
import 'package:tressy/features/home/data/models/home_mock_data.dart';

/// Home Data Source
/// Handles API calls for home page data
/// Currently using mock data, replace with actual API calls when backend is ready
abstract class HomeDataSource {
  Future<List<CarouselBannerModel>> getCarouselBanners();
  Future<List<CategoryModel>> getCategories();
  Future<List<SalonModel>> getPopularServices({
    required double latitude,
    required double longitude,
  });
  Future<List<SalonModel>> getTopSalons({
    required double latitude,
    required double longitude,
  });
  Future<List<SalonModel>> getRecommendedSalons();
}

/// Implementation using mock data
class HomeDataSourceImpl implements HomeDataSource {
  @override
  Future<List<CarouselBannerModel>> getCarouselBanners() async {
    // TODO: Replace with actual API call
    // Example: return await dioClient.get('/api/v1/home/carousel');
    return await HomeMockData.simulateApiCall(
      HomeMockData.getCarouselBanners(),
      delaySeconds: 1,
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    // TODO: Replace with actual API call
    // Example: return await dioClient.get('/api/v1/home/categories');
    return await HomeMockData.simulateApiCall(
      HomeMockData.getCategories(),
      delaySeconds: 1,
    );
  }

  @override
  Future<List<SalonModel>> getPopularServices({
    required double latitude,
    required double longitude,
  }) async {
    // TODO: Replace with actual API call
    // Example: return await dioClient.get(
    //   '/api/v1/home/popular-services',
    //   queryParameters: {
    //     'lat': latitude,
    //     'lng': longitude,
    //     'radius': radius,
    //   },
    // );
    return await HomeMockData.simulateApiCall(
      HomeMockData.getPopularServices(),
      delaySeconds: 1,
    );
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
      delaySeconds: 3,
    );
  }
}
