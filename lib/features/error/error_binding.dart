import 'network_controller.dart';
import 'package:get/get.dart';

class ErrorBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NetworkController());
  }
}
