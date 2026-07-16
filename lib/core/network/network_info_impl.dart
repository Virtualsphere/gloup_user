import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tressy/core/network/connectivity_status.dart';
import 'package:tressy/core/network/network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return hasActiveConnectivity(results);
  }
}
