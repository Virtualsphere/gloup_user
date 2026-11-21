import 'package:tressy/core/utils/local_storage_service.dart';

abstract class AppLaunchLocalDataSource {
  Future<bool> isFirstOpen();
  Future<void> markFirstOpenCompleted();
}

class AppLaunchLocalDataSourceImpl implements AppLaunchLocalDataSource {
  @override
  Future<bool> isFirstOpen() async {
    return !LocalStorageService.hasCompletedFirstOpen;
  }

  @override
  Future<void> markFirstOpenCompleted() async {
    await LocalStorageService.setFirstOpenCompleted(true);
  }
}

