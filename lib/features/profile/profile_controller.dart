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
    clearImageCache();
    forceRefreshProfile();

    Future.delayed(const Duration(milliseconds: 300), () {
      forceRefreshAvatar();
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (Get.currentRoute.contains('profile')) {
        forceRefreshAvatar();
      }
    });
  }

  Future<void> forceRefreshProfile() async {
    clearImageCache();
    await _initializeProfileData(forceServerRefresh: true);

    if (profilePicture.value.isNotEmpty) {
      final baseUrl = profilePicture.value.split('?')[0];
      final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
      final randomSuffix =
          (DateTime.now().millisecondsSinceEpoch % 10000).toString();

      profilePicture.value =
          '$baseUrl?v=$timestamp&t=${DateTime.now().toString()}&r=$randomSuffix';
    }

    avatarKey.value = DateTime.now().microsecondsSinceEpoch;

    Future.delayed(const Duration(milliseconds: 100), () {
      avatarKey.value = DateTime.now().microsecondsSinceEpoch + 1;
    });
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
        role.value = user.roleName ?? 'Pegawai';

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
        // Fallback
        username.value = '';
        email.value = '';
        role.value = 'Pegawai';
        profilePicture.value = '';
      }

      usernameController.text = username.value;
      emailController.text = email.value;
    } catch (e) {
      username.value = '';
      email.value = '';
      role.value = 'Pegawai';
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
        forceRefreshAvatar();
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
        if (imageFile.value != null) {
          uploadedImageStoragePath = await _userService.uploadProfileImage(
            imageFile.value!,
          );
        }

        await _userService.updateUserProfile(
          email:
              isOwner && emailController.text != email.value
                  ? emailController.text
                  : null,
          password:
              isOwner && passwordController.text.isNotEmpty
                  ? passwordController.text
                  : null,
          fullname:
              isOwner && usernameController.text.isNotEmpty
                  ? usernameController.text
                  : usernameController.text,
          profileImageUrl: uploadedImageStoragePath,
        );

        imageFile.value = null;
        clearImageCache();

        await forceRefreshProfile();

        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          await homeController.refreshUserSpecificData();
        }

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        if (Get.previousRoute.isNotEmpty) {
          Get.back();
        }

        await Future.delayed(const Duration(milliseconds: 100));
        DialogHelper.showSuccessDialog(
          title: 'Berhasil',
          message:
              isEmployee
                  ? 'Foto profil berhasil diperbarui'
                  : 'Profil berhasil diperbarui',
        );
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        DialogHelper.showErrorDialog(
          title: 'Error',
          message: 'Gagal memperbarui profil: ${e.toString()}',
        );
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

    if (profilePicture.value.isNotEmpty) {
      final baseUrl = profilePicture.value.split('?')[0];
      final randomParam = DateTime.now().microsecondsSinceEpoch.toString();
      profilePicture.value =
          '$baseUrl?v=$randomParam&t=${DateTime.now().toString()}';
    }

    Future.delayed(const Duration(milliseconds: 50), () {
      avatarKey.value = DateTime.now().microsecondsSinceEpoch;
    });
  }

  void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    imageCache.clear();
    imageCache.clearLiveImages();

    if (profilePicture.value.isNotEmpty) {
      try {
        NetworkImage(profilePicture.value).evict();
        final baseUrl = profilePicture.value.split('?')[0];
        NetworkImage(baseUrl).evict();
      } catch (e) {}
    }

    forceRefreshAvatar();
  }

  Future<void> refreshProfileData() async {
    clearImageCache();

    await _initializeProfileData(forceServerRefresh: true);

    if (profilePicture.value.isNotEmpty) {
      final baseUrl = profilePicture.value.split('?')[0];
      final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
      final randomSuffix = (timestamp.hashCode % 10000).toString();
      profilePicture.value =
          '$baseUrl?v=$timestamp&t=${DateTime.now().toString()}&r=$randomSuffix';
    }

    forceRefreshAvatar();
    Future.delayed(const Duration(milliseconds: 100), () {
      forceRefreshAvatar();
    });
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
    try {
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      // Ignore disposal errors
    }
  }

  @override
  void onClose() {
    try {
      usernameController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.onClose();
  }
}
