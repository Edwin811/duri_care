import 'package:duri_care/features/error/connectivity_controller.dart';
import 'package:get/get.dart';

class ErrorBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityController());
  }
}
