import 'dart:io';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final supabase = Supabase.instance.client;

  final RxString username = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString profilePicture = ''.obs;
  final RxString role = ''.obs;
  final RxBool isNotificationEnabled = true.obs;
  final isPasswrodVisible = true.obs;
  final isConfirmPasswordVisible = true.obs;

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final formKey = GlobalKey<FormState>();
  final Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _initializeProfileData();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void toggleNotification() {
    isNotificationEnabled.value = !isNotificationEnabled.value;
  }

  void togglePasswordVisibility() {
    isPasswrodVisible.value = !isPasswrodVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> _initializeProfileData() async {
    username.value = await authController.getUsername();
    email.value = await authController.getEmail() ?? '';
    profilePicture.value = await authController.getProfilePicture();
    role.value = await authController.getRole() ?? 'Employee';

    usernameController.text = username.value;
    emailController.text = email.value;
    passwordController.text = password.value;
    confirmPasswordController.text = confirmPassword.value;
  }

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

  Future<String?> _uploadImage(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final filePath =
          'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';

      final storageResponse = await supabase.storage
          .from('duricare')
          .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      if (storageResponse.isEmpty) {
        throw Exception('Upload ke storage gagal');
      }

      return supabase.storage.from('duricare').getPublicUrl(filePath);
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal mengunggah gambar: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (!formKey.currentState!.validate()) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message:
            'Form tidak valid. Mohon periksa kembali data yang dimasukkan.',
      );
      return;
    }

    if (passwordController.text.isNotEmpty ||
        confirmPasswordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'Password dan konfirmasi password tidak sesuai.',
        );
        return;
      }
    }

    try {
      String? uploadedImageUrl;
      if (imageFile.value != null) {
        uploadedImageUrl = await _uploadImage(imageFile.value!);
        if (uploadedImageUrl != null) {
          profilePicture.value = uploadedImageUrl;
        }
      }

      final updates = <String, dynamic>{};
      if (emailController.text != email.value) {
        updates['email'] = emailController.text;
      }
      if (passwordController.text.isNotEmpty) {
        updates['password'] = passwordController.text;
      }

      if (updates.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(
            email: updates['email'],
            password: updates['password'],
          ),
        );
      }

      final updateData = {
        'fullname': usernameController.text,
        if (uploadedImageUrl != null) 'profile_image': uploadedImageUrl,
      };

      await supabase.from('users').update(updateData).eq('id', user.id);

      username.value = usernameController.text;
      email.value = emailController.text;

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

  String? validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (email.isEmpty) {
      return 'Email tidak boleh kosong';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return null; // Allow empty password (no change)
    } else if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String password) {
    if (passwordController.text.isEmpty && password.isEmpty) {
      return null; // Both fields empty is valid (no change)
    } else if (passwordController.text.isNotEmpty && password.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    } else if (passwordController.text != password) {
      return 'Konfirmasi password tidak sesuai';
    }
    return null;
  }

  Future<void> logout() async {
    try {
      DialogHelper.showConfirmationDialog(
        title: 'Keluar Aplikasi?',
        message: 'Apakah anda yakin ingin keluar dari aplikasi ini?',
        onConfirm: () {
          authController.logout();
          Get.offAllNamed('/login');
          DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message: 'Anda telah keluar dari aplikasi',
          );
        },
        onCancel: () {
          Get.back();
        },
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal keluar: ${e.toString()}',
      );
    }
  }
}
