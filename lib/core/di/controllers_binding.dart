import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/login/login_controller.dart';
import 'package:duri_care/features/onboarding/onboarding_controller.dart';
import 'package:duri_care/features/splashscreen/splashscreen_controller.dart';
import 'package:get/get.dart';

class ControllersBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => SplashscreenController(), fenix: true);
    Get.lazyPut(() => OnboardingController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
  }
}
