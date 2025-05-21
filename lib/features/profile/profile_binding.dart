import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>();
    }

    Get.put<ProfileController>(ProfileController(), permanent: false);
  }
}
