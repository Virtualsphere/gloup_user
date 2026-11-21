import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tressy/features/app_launch/data/datasources/app_launch_local_datasource.dart';
import 'package:tressy/features/app_launch/domain/repositories/app_launch_repository.dart';

class AppLaunchRepositoryImpl implements AppLaunchRepository {
  final AppLaunchLocalDataSource localDataSource;
  final Connectivity connectivity;

  AppLaunchRepositoryImpl({
    required this.localDataSource,
    required this.connectivity,
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
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Anna Nagar';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return 'Anna Nagar';
      }

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
            return area;
          }
        }
      }
    } catch (_) {
      // Fallback gracefully on any exception
    }
    return 'Anna Nagar';
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
}

