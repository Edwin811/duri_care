import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 3));

    final authController = Get.find<AuthController>();

    if (authController.isFirstTime.value) {
      Get.offNamed('/onboarding');
    } else if (authController.isAuthenticated) {
      Get.offNamed('/home');
    } else {
      Get.offNamed('/login');
    }
  }
}
