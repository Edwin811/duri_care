import 'dart:io';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/utils/helpers/navigation/navigation_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final UserService _userService = Get.find<UserService>();
  final NavigationHelper navigationHelper = Get.find<NavigationHelper>();

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
  bool get isOwner => role.value.toLowerCase() == 'owner';
  bool get isEmployee =>
      role.value.toLowerCase() == 'employee' ||
      role.value.toLowerCase() == 'pegawai';
  bool get canEditBasicInfo => isOwner;
  bool get canEditPassword => isOwner;

  final profileKey = GlobalKey<FormState>(debugLabel: 'profileFormKey');
  final Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final RxInt avatarKey = 0.obs;
  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _initializeProfileData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      forceRefreshProfile();
    });
  }

  void onProfilePageEntered() {
    forceRefreshProfile();
  }

  Future<void> forceRefreshProfile() async {
    await _initializeProfileData(forceServerRefresh: true);

    avatarKey.value = DateTime.now().microsecondsSinceEpoch;
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

  Future<void> _initializeProfileData({bool forceServerRefresh = false}) async {
    try {
      final user = await _userService.getCurrentUser(
        forceRefresh: forceServerRefresh,
      );

      if (user != null) {
        username.value = user.fullname ?? '';
        email.value = user.email ?? '';
        if (user.roleName != null && user.roleName!.isNotEmpty) {
          role.value = user.roleName!;
        } else {
          role.value = authController.currentRole ?? 'Pegawai';
        }

        if (user.profileUrl != null && user.profileUrl!.isNotEmpty) {
          String rawUrl;
          if (user.profileUrl!.startsWith('http')) {
            rawUrl = user.profileUrl!;
          } else {
            rawUrl = Supabase.instance.client.storage
                .from('image')
                .getPublicUrl(user.profileUrl!);
          }

          if (rawUrl.isNotEmpty) {
            final baseUrl = rawUrl.split('?')[0];
            final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
            final randomSuffix = (timestamp.hashCode % 10000).toString();
            profilePicture.value =
                '$baseUrl?v=$timestamp&t=${DateTime.now().microsecondsSinceEpoch}&r=$randomSuffix';
          } else {
            profilePicture.value = '';
          }
        } else {
          profilePicture.value = '';
        }
      } else {
        username.value = authController.currentUsername;
        email.value = authController.currentEmail;
        role.value = authController.currentRole ?? 'Pegawai';
        profilePicture.value = '';
      }

      usernameController.text = username.value;
      emailController.text = email.value;
    } catch (e) {
      username.value = authController.currentUsername;
      email.value = authController.currentEmail;
      role.value = authController.currentRole ?? 'Pegawai';
      profilePicture.value = '';

      usernameController.text = username.value;
      emailController.text = email.value;
    }
  }

  String getInitialsFromName(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '';

    if (nameParts.length == 1) {
      if (nameParts[0].length > 1) {
        return nameParts[0].substring(0, 1).toUpperCase();
      }
      return nameParts[0].toUpperCase();
    }

    String firstInitial =
        nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    String secondInitial =
        nameParts.length > 1 && nameParts[1].isNotEmpty
            ? nameParts[1][0].toUpperCase()
            : '';

    return '$firstInitial$secondInitial';
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
        avatarKey.value = DateTime.now().microsecondsSinceEpoch;
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
      final user = _userService.getCurrentUserRaw();
      if (user == null) {
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'User tidak ditemukan. Silakan login ulang.',
        );
        return;
      }

      if (!profileKey.currentState!.validate()) {
        DialogHelper.showErrorDialog(
          title: 'Error',
          message:
              'Form tidak valid. Mohon periksa kembali data yang dimasukkan.',
        );
        return;
      }

      if (isOwner &&
          passwordController.text.isNotEmpty &&
          passwordController.text != confirmPasswordController.text) {
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'Password dan konfirmasi password tidak sesuai.',
        );
        return;
      }

      if (isOwner &&
          emailController.text.isNotEmpty &&
          emailController.text != email.value) {
        try {
          final emailText = emailController.text.trim();
          if (emailText.isNotEmpty) {
            bool isEmailExists = await _userService.isEmailAlreadyExists(
              emailText,
            );
            if (isEmailExists) {
              DialogHelper.showErrorDialog(
                title: 'Error',
                message: 'Gunakan Email lain yang belum terdaftar.',
              );
              return;
            }
          }
        } catch (e) {
          DialogHelper.showErrorDialog(
            title: 'Error',
            message: 'Gagal memeriksa email: ${e.toString()}',
          );
          return;
        }
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );

      try {
        String? uploadedImageStoragePath;
        bool hasChanges = false;

        if (imageFile.value != null) {
          uploadedImageStoragePath = await _userService.uploadProfileImage(
            imageFile.value!,
          );
          hasChanges = true;
        }

        bool hasEmailChange = isOwner && emailController.text != email.value;
        bool hasPasswordChange = isOwner && passwordController.text.isNotEmpty;
        bool hasNameChange =
            isOwner && usernameController.text != username.value;

        if (hasEmailChange ||
            hasPasswordChange ||
            hasNameChange ||
            uploadedImageStoragePath != null) {
          Map<String, dynamic> updateData = {};

          if (hasEmailChange) {
            updateData['email'] = emailController.text;
          }

          if (hasPasswordChange) {
            updateData['password'] = passwordController.text;
          }

          if (hasNameChange) {
            updateData['fullname'] = usernameController.text.trim();
          }

          if (uploadedImageStoragePath != null) {
            updateData['profileImageUrl'] = uploadedImageStoragePath;
          }

          await _userService.updateUserProfile(
            email: updateData['email'],
            password: updateData['password'],
            fullname: updateData['fullname'],
            profileImageUrl: updateData['profileImageUrl'],
          );
          hasChanges = true;
        }

        imageFile.value = null;

        if (hasChanges) {
          await refreshProfileData();

          if (Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            await homeController.refreshUserSpecificData();
          }
        }

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.back(result: hasChanges);

        if (hasChanges) {
          DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message:
                isEmployee
                    ? 'Foto profil berhasil diperbarui'
                    : 'Profil berhasil diperbarui',
          );
        }
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'Gagal memperbarui profil: ${e.toString()}',
        );
        debugPrint('Error updating profile: $e');
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  void forceRefreshAvatar() {
    avatarKey.value = DateTime.now().microsecondsSinceEpoch;
  }

  Future<void> refreshProfileData() async {
    await _initializeProfileData(forceServerRefresh: true);

    avatarKey.value = DateTime.now().microsecondsSinceEpoch;
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
      return null;
    } else if (password.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String password) {
    if (passwordController.text.isEmpty && password.isEmpty) {
      return null;
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
        onConfirm: () async {
          Get.back();
          try {
            disposeControllerResources();
            await authController.logout();
            navigationHelper.resetIndex();
          } catch (e) {
            DialogHelper.showErrorDialog(
              title: 'Error',
              message: 'Gagal keluar: ${e.toString()}',
            );
          }
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

  void disposeControllerResources() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> forceRefreshRole() async {
    final user = await _userService.getCurrentUser(forceRefresh: true);
    if (user != null && user.roleName != null) {
      role.value = user.roleName!;
    } else {
      final authRole = authController.currentRole;
      if (authRole != null) {
        role.value = authRole;
      }
    }
  }
}
