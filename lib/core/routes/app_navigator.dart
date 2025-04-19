import 'package:duri_care/core/utils/helpers/tabs.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class AppNavigator {
  static final _authController = Get.find<AuthController>();

  static void handleInitialNavigation() {
    if (Get.currentRoute != '/splashscreen') return;

    if (_authController.isFirstTime.value) {
      Get.offAllNamed('/onboarding');
    } else if (_authController.isAuthenticated) {
      Get.offAllNamed('/tabs');
    } else {
      Get.offAllNamed('/login');
    }
  }
}
