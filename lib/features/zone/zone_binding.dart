import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';

class ZoneBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ZoneController());
  }
}
