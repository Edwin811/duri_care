import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString profilePicture = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    username.value = await authController.getUsername() ?? '';
    email.value = await authController.getEmail() ?? '';
    profilePicture.value = await authController.getProfilePicture();
  }

  final RxString role = "Owner".obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isNotificationEnabled = true.obs;

  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    update();
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    update();
  }

  void logout() {
    DialogHelper.showConfirmationDialog(
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar?',
      onConfirm: () async {
        await authController.logout();
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  void editProfile() {
    Get.toNamed('/edit-profile');
  }
}
