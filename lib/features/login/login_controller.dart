import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/services/auth_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final GlobalKey<FormState> loginKey = GlobalKey<FormState>();
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
    if (SessionService.to.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/main');
      });
    }
  }

  Future<void> loginWithEmail() async {
    if (!(loginKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      isLoading.value = true;

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColor.white)),
        barrierDismissible: false,
      );

      await _auth.login(email, password);

      final userData = AuthService.to.currentUser;
      if (userData == null) {
        throw Exception('userData null');
      }

      final profile = await AuthService.to.getUserProfile(userData.id);
      final fullname = profile?['fullname'] ?? userData.email ?? 'Pengguna';

      Get.back();
      Get.offAllNamed('/main');
      Future.delayed(Duration(milliseconds: 300), () {
        DialogHelper.showSuccessDialog(
          title: 'Berhasil Masuk',
          message: 'Selamat datang, $fullname',
        );
      });
    } catch (e) {
      debugPrint('Login error: $e');
      Get.back();

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid_credentials')) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Email atau password salah',
          onConfirm: () {
            isLoading.value = false;
          },
        );
      } else if (errorStr.contains('user_not_found')) {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Akun tidak ditemukan',
          onConfirm: () {
            isLoading.value = false;
          },
        );
      } else {
        DialogHelper.showErrorDialog(
          title: 'Gagal Masuk',
          message: 'Terjadi kesalahan: ${e.toString()}',
          onConfirm: () {
            isLoading.value = false;
          },
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

  String? validateEmail(String? email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }
}
