import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:get/get.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserService>()) {
      Get.put<UserService>(UserService());
    }

    if (Get.isRegistered<UserManagementController>()) {
      Get.find<UserManagementController>();
    } else {
      Get.put<UserManagementController>(UserManagementController());
    }
  }
}
