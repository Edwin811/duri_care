import 'package:get/get.dart';

class HomeService extends GetxService {
  static HomeService get to => Get.find<HomeService>();

  Future<HomeService> init() async {
    return this;
  }

  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 3 && hour < 10) {
      return "Selamat Pagi";
    } else if (hour >= 10 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }
}
