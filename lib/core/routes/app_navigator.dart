import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class AppNavigator {
  static final _authController = Get.find<AuthController>();
  static bool _hasNavigated = false;

  static void handleInitialNavigation() {
    if (_hasNavigated) return;
    if (Get.currentRoute != '/splashscreen') return;

    _hasNavigated = true;

    if (_authController.isFirstTime.value) {
      Get.offAllNamed('/onboarding');
    } else if (_authController.isAuthenticated) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }
}