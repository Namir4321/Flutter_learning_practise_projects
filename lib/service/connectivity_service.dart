import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity;

  ConnectivityService({Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  Future<bool> hasNetworkConnection() async {
    final results = await connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) {
      return !results.contains(ConnectivityResult.none);
    });
  }
}
