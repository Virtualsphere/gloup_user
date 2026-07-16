import 'package:connectivity_plus/connectivity_plus.dart';

/// True when at least one active transport is available.
bool hasActiveConnectivity(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}
