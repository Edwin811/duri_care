import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final RxBool isConnected = true.obs;
  final RxBool isChecking = false.obs;
  String? lastRouteBeforeError;

  late final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _startMonitoring();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> checkConnection() async {
    isChecking.value = true;
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);
    isChecking.value = false;
    print('Connection status checked: ${isConnected.value}');
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final status = _getEffectiveStatus(results);
    final previousStatus = isConnected.value;
    isConnected.value = status != ConnectivityResult.none;
    print('Connection status updated: ${isConnected.value}');

    if (!previousStatus && isConnected.value) {
      _handleReconnection();
    }
    
    if (isConnected.value && Get.currentRoute != '/error') {
      lastRouteBeforeError = Get.currentRoute;
    }
  }

  void _handleReconnection() {
    if (Get.currentRoute == '/error' && lastRouteBeforeError != null) {
      Get.offNamed(lastRouteBeforeError!);
    }
  }

  ConnectivityResult _getEffectiveStatus(List<ConnectivityResult> results) {
    return results.firstWhere(
      (result) => result != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    );
  }
}