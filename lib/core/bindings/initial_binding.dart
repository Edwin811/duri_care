import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(HomeController());
    Get.put(NetworkController());
  }
}
