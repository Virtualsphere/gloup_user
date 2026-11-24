import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tressy/core/constants/api_routes.dart';
import 'package:tressy/core/network/dio_client.dart';
import 'package:tressy/core/utils/local_storage_service.dart';
import 'package:tressy/features/app_launch/data/datasources/app_launch_local_datasource.dart';
import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';

class AppLaunchRepositoryImpl implements AppLaunchRepository {
  final AppLaunchLocalDataSource localDataSource;
  final Connectivity connectivity;
  final DioClient? dioClient;

  AppLaunchRepositoryImpl({
    required this.localDataSource,
    required this.connectivity,
    this.dioClient,
  });

  @override
  Future<bool> isFirstOpen() async {
    return await localDataSource.isFirstOpen();
  }

  @override
  Future<void> markFirstOpenCompleted() async {
    await localDataSource.markFirstOpenCompleted();
  }

  @override
  Future<String> resolveCurrentArea() async {
    try {
      // 1. Check cached area / city from user preferences
      final savedArea = LocalStorageService.getString('user_area');
      if (savedArea != null && savedArea.trim().isNotEmpty) {
        return savedArea.trim();
      }

      final savedCity = LocalStorageService.getString('user_city');
      if (savedCity != null && savedCity.trim().isNotEmpty) {
        return savedCity.trim();
      }

      // 2. Fall back to GPS last known position if enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            final placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              final area = place.subLocality ?? place.locality ?? place.name;
              if (area != null && area.trim().isNotEmpty) {
                return area.trim();
              }
            }
          }
        }
      }
    } catch (_) {
      // Fallback gracefully on any exception
    }
    // Unknown area: views fall back to "Finding salons near you...".
    return '';
  }

  @override
  Future<bool> checkNetworkReachability() async {
    try {
      final results = await connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> checkServerReachability() async {
    try {
      final isNetworkUp = await checkNetworkReachability();
      if (!isNetworkUp) return false;

      if (dioClient == null) return true;

      final response = await dioClient!.get(
        ApiRoutes.getBanners,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
