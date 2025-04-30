import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final isPasswordVisible = true.obs;
  final isLoading = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void clearForm() {
    emailController.clear();
    passwordController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    if (SessionService.to.token != null) {
      Get.offAllNamed('/home');
    }
  }

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      DialogHelper.showErrorDialog(
        title: 'Gagal Masuk',
        message: 'Email atau password tidak valid',
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.login(email, password);

      final userData = SessionService.to.getUserData();
      if (userData != null) {
        Get.offAllNamed('/main');
        DialogHelper.showSuccessDialog(
          title: 'Berhasil Masuk',
          message: 'Selamat datang, ${userData['fullname']}',
        );
      }
    } catch (e) {
      if (e.toString().contains('invalid_credentials')) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Email atau password salah',
        );
      } else if (e.toString().contains('user_not_found')) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Akun tidak ditemukan',
        );
      } else {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Terjadi kesalahan, silakan coba lagi',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await DialogHelper.showConfirmationDialog(
      title: 'Konfirmasi',
      message: 'Apakah Anda yakin ingin keluar?',
      onConfirm: () async {
        await _auth.logout();
        Get.offAllNamed('/login');
        DialogHelper.showSuccessDialog(
          title: 'Berhasil Keluar',
          message: 'Anda telah keluar dari akun Anda',
        );
      },
      onCancel: () => Get.back(),
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      DialogHelper.showSuccessDialog(
        title: 'txt_reset_password'.tr,
        message: 'Reset password link has been sent to your email',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Failed to send reset password link',
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
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
