import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});
  static const String route = '/edit-profile';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.greenPrimary,
          leading: AppBackButton(
            onPressed: () {
              controller.refreshProfileData();
              Get.back();
            },
            iconColor: AppColor.white,
          ),
          title: Text(
            'Edit Profil',
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(color: AppColor.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar section - selalu bisa diedit
                Obx(() {
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColor.greenPrimary.withAlpha(100),
                        backgroundImage:
                            controller.imageFile.value != null
                                ? FileImage(controller.imageFile.value!)
                                : controller.profilePicture.value.startsWith(
                                  'http',
                                )
                                ? NetworkImage(controller.profilePicture.value)
                                    as ImageProvider
                                : null,
                        child:
                            controller.imageFile.value == null &&
                                    !controller.profilePicture.value.startsWith(
                                      'http',
                                    )
                                ? Text(
                                  controller.profilePicture.value.isNotEmpty
                                      ? controller.profilePicture.value
                                      : controller.username.value.toUpperCase(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                )
                                : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () => _showImageSourceDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.greenPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 32),

                Obx(
                  () => Form(
                    key: controller.profileKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Pengguna - disabled untuk employee
                        AppLabelText(text: 'Nama Pengguna'),
                        const SizedBox(height: 8),
                        AppTextFormField(
                          controller: controller.usernameController,
                          hintText: 'Masukkan nama pengguna',
                          enabled:
                              controller
                                  .canEditBasicInfo, // false untuk employee
                          prefixIcon: Icons.person_outline,
                          validator:
                              controller.canEditBasicInfo
                                  ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama pengguna tidak boleh kosong';
                                    }
                                    return null;
                                  }
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Email - disabled untuk employee
                        AppLabelText(text: 'Email'),
                        const SizedBox(height: 8),
                        AppTextFormField(
                          controller: controller.emailController,
                          hintText: 'Masukkan email',
                          enabled:
                              controller
                                  .canEditBasicInfo, // false untuk employee
                          prefixIcon: Icons.email_outlined,
                          validator:
                              controller.canEditBasicInfo
                                  ? (value) =>
                                      controller.validateEmail(value ?? '')
                                  : null,
                        ),

                        if (controller.isOwner) ...[
                          const SizedBox(height: 16),
                          AppLabelText(text: 'Password'),
                          AppSpacing.sm,
                          AppTextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.isPasswrodVisible.value,
                            hintText: 'Masukkan password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon:
                                  controller.isPasswrodVisible.value
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                              onPressed:
                                  () => controller.togglePasswordVisibility(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return controller.validatePassword(value);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppLabelText(text: 'Konfirmasi Password'),
                          AppSpacing.sm,
                          AppTextFormField(
                            controller: controller.confirmPasswordController,
                            obscureText:
                                controller.isConfirmPasswordVisible.value,
                            hintText: 'Masukkan konfirmasi password',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon:
                                  controller.isConfirmPasswordVisible.value
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                              onPressed:
                                  () =>
                                      controller
                                          .toggleConfirmPasswordVisibility(),
                            ),
                            validator: (value) {
                              return controller.validateConfirmPassword(
                                value ?? '',
                              );
                            },
                          ),
                        ],

                        // Info untuk employee
                        if (controller.isEmployee) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColor.greenPrimary.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColor.greenPrimary),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColor.greenPrimary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Sebagai pegawai, Anda hanya dapat mengubah foto profil. Untuk mengubah data lainnya, hubungi pemilik.',
                                    style: TextStyle(
                                      color: AppColor.greenPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                AppFilledButton(
                  onPressed: () {
                    if (controller.profileKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
                  text: 'Simpan Perubahan',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () {
                    controller.pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () {
                    controller.pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
