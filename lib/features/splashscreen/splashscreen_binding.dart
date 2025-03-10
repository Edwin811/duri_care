import 'package:duri_care/features/splashscreen/splashscreen_controller.dart';
import 'package:get/get.dart';

class SplashscreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SplashscreenController());
  }
}
