import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString username = "Sarah Wijayanto".obs;
  final RxString email = "sarah.wijayanto@example.com".obs;
  final RxString phoneNumber = "+62 812-3456-7890".obs;
  final RxString role = "Owner".obs;
  final RxString profilePicture = "SW".obs; // User's initials for avatar
  final RxBool isDarkMode = false.obs;
  final RxBool isNotificationEnabled = true.obs;

  void toggleNotification(bool value) {
    isNotificationEnabled.value = value;
    update();
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    update();
    // Would implement theme changing functionality here
  }

  void logout() {
    // Implement logout functionality
    Get.offAllNamed('/login'); // Navigate to login page
  }

  void editProfile() {
    // Would navigate to edit profile screen
    Get.toNamed('/edit-profile');
  }
}
