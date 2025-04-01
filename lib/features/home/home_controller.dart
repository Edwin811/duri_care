import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/login/login_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final LoginController loginController = Get.find<LoginController>();
  RxString ucapan = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getSpeech();
  }

  void _getSpeech() {
    DateTime now = DateTime.now();
    int jam = now.hour;

    if (jam >= 3 && jam < 10) {
      ucapan.value = "Selamat Pagi";
    } else if (jam >= 10 && jam < 15) {
      ucapan.value = "Selamat Siang";
    } else if (jam >= 15 && jam < 18) {
      ucapan.value = "Selamat Sore";
    } else {
      ucapan.value = "Selamat Malam";
    }
  }
}
