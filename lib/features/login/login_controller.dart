import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
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

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      DialogHelper.showErrorDialog(
        'Email atau password tidak valid',
        title: 'Gagal Masuk',
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.login(email, password);
      Get.offAllNamed('/home');
      DialogHelper.showSuccessDialog(
        'Berhasil Masuk',
        title: 'Selamat Datang di Aplikasi Duri Care',
      );
    } catch (e) {
      if (e.toString().contains('invalid_credentials')) {
        DialogHelper.showErrorDialog(
          'Email atau password salah',
          title: 'Gagal Masuk',
        );
      } else if (e.toString().contains('user_not_found')) {
        DialogHelper.showErrorDialog(
          'Akun tidak ditemukan',
          title: 'Gagal Masuk',
        );
      } else {
        DialogHelper.showErrorDialog(e.toString(), title: 'Gagal Masuk');
      }
    }
  }

  Future<void> logout() async {
    await DialogHelper.showConfirmationDialog(
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar?',
      onConfirm: () async {
        await _auth.logout();
        Get.offAllNamed('/login');
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      DialogHelper.showSuccessDialog(
        'Reset password link has been sent to your email',
        title: 'txt_reset_password'.tr,
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        e.toString(),
        title: 'txt_reset_password_failed'.tr,
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
