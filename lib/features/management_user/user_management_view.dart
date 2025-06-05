import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/features/management_user/user_list_item.dart';
import 'package:duri_care/features/management_user/permission_management_view.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Pegawai',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        '${controller.users.length} pegawai terdaftar',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAddUserDialog(context);
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Tambah Akun'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.greenPrimary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColor.greenPrimary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return UserListItem(
                      user: user,
                      roles: controller.roles,
                      onDelete: () {
                        controller.deleteUser(user.id);
                      },
                      onTap: () async {
                        controller.selectedUser.value = user;
                        await controller.fetchAllZones();
                        await controller.fetchUserPermissions();
                        await Get.toNamed(PermissionManagementView.route);
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColor.greenPrimary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              color: AppColor.greenPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tambah Akun Pegawai',
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lengkapi data di bawah untuk membuat akun baru',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: AppColor.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppLabelText(text: 'Nama Lengkap'),
                      AppTextFormField(
                        controller: controller.fullnameController,
                        hintText: 'Masukkan nama lengkap',
                        obscureText: false,
                        prefixIcon: Icons.person_outline,
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: 8),
                      AppLabelText(text: 'Email'),
                      AppTextFormField(
                        controller: controller.emailController,
                        hintText: 'Masukkan email',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              side: BorderSide(
                                color: AppColor.greenPrimary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: AppColor.greenPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
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
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                elevation: 2,
                                shadowColor: AppColor.greenPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  controller.isCreating.value
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Buat Akun',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
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
