import 'package:get/get.dart';
import 'package:duri_care/core/services/connectivity_service.dart';

mixin ConnectivityMixin {
  ConnectivityService get connectivity => Get.find<ConnectivityService>();

  Future<bool> requiresConnection() async {
    if (!await connectivity.hasInternetConnection()) {
      Get.snackbar(
        'Tidak Ada Internet',
        'Pastikan perangkat terhubung ke internet',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
    return true;
  }

  Future<T?> executeWithConnection<T>(Future<T> Function() operation) async {
    if (!await requiresConnection()) return null;
    try {
      return await operation();
    } catch (e) {
      rethrow;
    }
  }
}
