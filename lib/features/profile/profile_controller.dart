import 'dart:io';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString profilePicture = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString address = ''.obs;

  // Form controllers
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Selected image file
  final Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    _initializeProfileData();
  }

  Future<void> _initializeProfileData() async {
    username.value = await authController.getUsername() ?? '';
    email.value = await authController.getEmail() ?? '';
    profilePicture.value = await authController.getProfilePicture();
    phoneNumber.value = ''; // Initialize from storage or API if available
    address.value = ''; // Initialize from storage or API if available

    // Initialize controllers with current values
    usernameController = TextEditingController(text: username.value);
    emailController = TextEditingController(text: email.value);
    phoneController = TextEditingController(text: phoneNumber.value);
    addressController = TextEditingController(text: address.value);
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  // Existing code
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

  // New methods for profile editing
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal memilih gambar: ${e.toString()}',
      );
    }
  }

  Future<void> updateProfile() async {
    try {

      // Update local values
      username.value = usernameController.text;
      email.value = emailController.text;
      phoneNumber.value = phoneController.text;
      address.value = addressController.text;

      // TODO: Upload image if selected
      if (imageFile.value != null) {
        // Example implementation - replace with your actual API call
        // final String uploadedImageUrl = await uploadImageToServer(imageFile.value!);
        // profilePicture.value = uploadedImageUrl;

        // For now, we'll just use a mock update
        profilePicture.value = 'https://example.com/profile.jpg';
      }

      // TODO: Save to backend API
      // await authController.updateUserProfile(
      //   username: username.value,
      //   email: email.value,
      //   phoneNumber: phoneNumber.value,
      //   address: address.value,
      //   profilePicture: profilePicture.value,
      // );

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      Get.back();
      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Profil berhasil diperbarui',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal memperbarui profil: ${e.toString()}',
      );
    }
  }
}
