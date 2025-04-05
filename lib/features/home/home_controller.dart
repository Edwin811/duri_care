import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  RxString ucapan = ''.obs;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      _isInitialized = true;
      _getSpeech();
    }
  }

  @override
  void onReady() {
    super.onReady();
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
