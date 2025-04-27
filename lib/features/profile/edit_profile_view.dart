import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(onPressed: () => Get.back()),
          title: Text(
            'Edit Profil',
            style: Theme.of(context).textTheme.titleLarge,
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
                // Profile picture section
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
                                      : '?',
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
                // Form
                Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Pengguna',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: controller.usernameController,
                        hintText: 'Masukkan nama pengguna',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pengguna tidak boleh kosong';
                          }
                          return null;
                        },
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          } else if (!GetUtils.isEmail(value)) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Nomor Telepon',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: controller.phoneController,
                        hintText: 'Masukkan nomor telepon',
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !GetUtils.isPhoneNumber(value)) {
                            return 'Nomor telepon tidak valid';
                          }
                          return null;
                        },
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Alamat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppTextFormField(
                        controller: controller.addressController,
                        hintText: 'Masukkan alamat',
                        prefixIcon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        controller.updateProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.greenPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Simpan Perubahan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: AppColor.greenPrimary),
                    ),
                    child: Text(
                      'Batal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColor.greenPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
