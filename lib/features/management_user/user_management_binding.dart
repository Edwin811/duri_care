import 'package:duri_care/core/services/user_management_service.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:get/get.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserManagementService>()) {
      Get.put<UserManagementService>(UserManagementService());
    }

    Get.lazyPut<UserManagementController>(() => UserManagementController());
  }
}
