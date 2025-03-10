import 'dart:async';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _authController.checkFirstTimeUser();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 5), () => _navigateToNextScreen());
  }

  void _navigateToNextScreen() {
    if (_authController.isFirstTime.value) {
      Get.offAllNamed('/onboarding');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
