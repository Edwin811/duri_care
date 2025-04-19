import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ProfileController>(() => ProfileController());
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
