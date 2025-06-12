import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxString connectionType = 'unknown'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      isConnected.value = false;
      connectionType.value = 'unknown';
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isConnected.value = false;
      connectionType.value = 'none';
    } else {
      isConnected.value = true;
      if (results.contains(ConnectivityResult.wifi)) {
        connectionType.value = 'wifi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        connectionType.value = 'mobile';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        connectionType.value = 'ethernet';
      } else {
        connectionType.value = 'other';
      }
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.none)) {
        return false;
      }

      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<T?> executeWithConnectivity<T>(Future<T> Function() apiCall) async {
    if (!await hasInternetConnection()) {
      Get.snackbar(
        'Tidak Ada Internet',
        'Pastikan perangkat terhubung ke internet',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return null;
    }

    try {
      return await apiCall();
    } on SocketException {
      Get.snackbar(
        'Koneksi Gagal',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
