import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  final isConnected = true.obs;
  final isChecking = false.obs;
  bool _manualMode = false;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (_) => _checkConnection(),
    );
  }

  Future<void> _checkConnection() async {
    final connectivity = await _connectivity.checkConnectivity();
    final hasConnection =
        connectivity != ConnectivityResult.none && await _hasInternet();
    _updateStatus(hasConnection);
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('pub.dev');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _updateStatus(bool hasInternet) {
    if (!hasInternet) {
      isConnected.value = false;
      _manualMode = true;
    } else if (!_manualMode) {
      isConnected.value = true;
    }
  }

  Future<void> triggerReconnect() async {
    isChecking.value = true;
    final hasInternet = await _hasInternet();
    if (hasInternet) {
      isConnected.value = true;
      _manualMode = false;
    }
    isChecking.value = false;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
