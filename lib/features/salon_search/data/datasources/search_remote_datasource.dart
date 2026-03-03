import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/features/home/data/datasources/home_datasource.dart';
import 'package:tressy/features/home/data/models/home_models.dart';
import 'package:tressy/shared/data/datasources/salon_remote_datasource.dart';
import 'package:tressy/shared/data/models/salon_model.dart';
import 'package:tressy/features/map_markers/data/models/map_marker_models.dart';

/// Search Remote Data Source
/// Handles API calls for salon search functionality
abstract class SearchRemoteDataSource {
  /// Get nearby salons (reuses home API)
  Future<NearbyStoresResponseModel> getNearbySalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  });
  
  /// Search salons with filters (uses shared salon API)
  Future<SalonsResponseModel> searchSalons({
    required double latitude,
    required double longitude,
    String? query,
    String? categoryId,
    String? gender,
    int? limit,
    int? page,
  });

  /// Get clustered map markers based on map bounds and zoom level
  Future<MapMarkersResponseModel> getClusteredMarkers({
    required MapMarkersRequestModel request,
  });
}

/// Implementation that delegates to existing data sources
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final HomeDataSource homeDataSource;
  final SalonRemoteDataSource salonDataSource;
  final DioClient dioClient;
  
  SearchRemoteDataSourceImpl({
    required this.homeDataSource,
    required this.salonDataSource,
    required this.dioClient,
  });
  
  @override
  Future<NearbyStoresResponseModel> getNearbySalons({
    required double latitude,
    required double longitude,
    int? limit,
    int? page,
    String? gender,
  }) async {
    // Delegate to home data source
    return await homeDataSource.getPopularServices(
      latitude: latitude,
      longitude: longitude,
      limit: limit,
      page: page,
      gender: gender,
    );
  }
  
  @override
  Future<SalonsResponseModel> searchSalons({
    required double latitude,
    required double longitude,
    String? query,
    String? categoryId,
    String? gender,
    int? limit,
    int? page,
  }) async {
    // Delegate to shared salon data source
    return await salonDataSource.getSalons(
      latitude: latitude,
      longitude: longitude,
      search: query,
      category: categoryId,
      gender: gender,
      limit: limit,
      page: page,
    );
  }

  @override
  Future<MapMarkersResponseModel> getClusteredMarkers({
    required MapMarkersRequestModel request,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.mapMarkersClustered,
        data: request.toJson(),
      );

      return MapMarkersResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
