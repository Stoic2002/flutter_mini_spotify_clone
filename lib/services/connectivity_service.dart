import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final connectivityStream = StreamController<bool>();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      connectivityStream.add(_getStatusFromResult(result.first));
    });
  }

  bool _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        return true;
      case ConnectivityResult.none:
      default:
        return false;
    }
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _getStatusFromResult(result.first);
  }

  void dispose() {
    connectivityStream.close();
  }
}
