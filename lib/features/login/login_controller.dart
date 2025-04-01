import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final AuthController _auth = AuthController.find;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  Future<void> loginWithEmail(
    String email,
    String password,
    GlobalKey<FormState> dynamicFormKey,
  ) async {
    if (!dynamicFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await _auth.login(email);
      DialogHelper.showSuccessDialog(
        'Selamat Datang',
        title: 'txt_success_login'.tr,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      DialogHelper.showErrorDialog(e.toString(), title: 'txt_failed_login'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    DialogHelper.showConfirmationDialog(
      'Apakah Anda yakin ingin keluar?',
      'txt_warning'.tr,
      'txt_confirm'.tr,
      'txt_cancel'.tr,
      () async {
        try {
          await _auth.logout();
          Get.offAllNamed('/login');
        } catch (e) {
          DialogHelper.showErrorDialog(
            'Error logging out: ${e.toString()}',
            title: 'txt_error'.tr,
          );
        }
      },
      () => Get.back(),
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
      return 'Email cannot be empty';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
