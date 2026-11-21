abstract class AppLaunchRepository {
  Future<bool> isFirstOpen();
  Future<void> markFirstOpenCompleted();
  Future<String> resolveCurrentArea();
  Future<bool> checkNetworkReachability();
}

