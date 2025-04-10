import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(), permanent: true);
    Get.lazyPut<ZoneController>(() => ZoneController(), fenix: true);
  }
}