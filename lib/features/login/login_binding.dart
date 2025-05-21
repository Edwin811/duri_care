import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>();
    }
    Get.put<LoginController>(LoginController(), permanent: false);

    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }
}
