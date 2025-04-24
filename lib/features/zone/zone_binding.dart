import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';

class ZoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZoneController>(() => ZoneController(), fenix: true);
  }
}
