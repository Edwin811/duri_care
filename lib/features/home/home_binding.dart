import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/services/schedule_service.dart';
import 'package:duri_care/core/services/sensor_service.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';
import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController(), permanent: true);
    Get.put(SensorService(), permanent: true);
    Get.lazyPut<ZoneController>(() => ZoneController());
    Get.lazyPut(() => ScheduleService());
    Get.lazyPut(() => AuthService());
  }
}
