import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/features/management_user/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({super.key});

  static const String route = '/user-management';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UserManagementController>()) {
      Get.put(UserManagementController());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.greenPrimary,
        leading: AppBackButton(
          onPressed: () => Get.back(),
          iconColor: AppColor.white,
        ),
        title: Text(
          'Manajemen Akun Pegawai',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColor.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColor.white),
            onPressed: () => controller.fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 180,
                  child: AppFilledButton(
                    onPressed: () {
                      _showAddUserDialog(context);
                    },
                    text: 'Tambah Akun',
                    textSize: 16,
                    icon: Icons.add,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

                if (controller.users.isEmpty) {
                return Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Column(
                      children: [
                      Text(
                        'Belum ada pegawai yang ditambahkan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silahkan tambahkan pegawai baru dengan menekan tombol di atas',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      ],
                    ),
                    ),
                  ],
                  ),
                );
                }

              return RefreshIndicator(
                onRefresh: controller.fetchUsers,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.users.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return UserListItem(
                      user: user,
                      roles: controller.roles,
                      onDelete: () {
                        controller.deleteUser(user.id);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    controller.resetForm();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_add, color: AppColor.greenPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Akun Pegawai',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppLabelText(text: 'Nama Lengkap'),
                      AppTextFormField(
                        controller: controller.fullnameController,
                        hintText: 'Masukkan nama lengkap',
                        obscureText: false,
                        prefixIcon: Icons.person_outline,
                        validator: controller.validateName,
                      ),
                      AppLabelText(text: 'Email'),
                      AppTextFormField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                        validator: controller.validateEmail,
                      ),
                      AppLabelText(text: 'Password'),
                      Obx(
                        () => AppTextFormField(
                          controller: controller.passwordController,
                          hintText: 'Masukkan password',
                          obscureText: controller.passwordVisible.value,
                          prefixIcon: Icons.lock_outline,
                          validator: controller.validatePassword,
                          suffixIcon: IconButton(
                            icon:
                                controller.passwordVisible.value
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                            onPressed:
                                () => controller.togglePasswordVisibility(),
                          ),
                        ),
                      ),

                      AppLabelText(text: 'Konfirmasi Password'),
                      Obx(
                        () => AppTextFormField(
                          controller: controller.confirmPasswordController,
                          hintText: 'Masukkan konfirmasi password',
                          obscureText: controller.confirmPasswordVisible.value,
                          prefixIcon: Icons.lock_outline,
                          validator: controller.validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon:
                                controller.confirmPasswordVisible.value
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                            onPressed:
                                () =>
                                    controller
                                        .toggleConfirmPasswordVisibility(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: AppColor.greenPrimary),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Obx(
                            () => ElevatedButton(
                              onPressed:
                                  controller.isCreating.value
                                      ? null
                                      : () async {
                                        controller.isCreating.value = true;
                                        await controller.createUser();
                                        controller.isCreating.value = false;
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.greenPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child:
                                  controller.isCreating.value
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'Buat Akun',
                                        style: TextStyle(color: AppColor.white),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
