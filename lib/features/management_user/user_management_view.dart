import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/features/management_user/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:duri_care/core/themes/app_themes.dart';
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
          'Managemen Akun Pegawai',
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
                      Text(
                        'No users found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new user to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                      const SizedBox(height: 24),

                      AppLabelText(text: 'Nama Lengkap'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.fullnameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama lengkap',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        validator: controller.validateName,
                      ),
                      const SizedBox(height: 16),

                      AppLabelText(text: 'Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        validator: controller.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      AppLabelText(text: 'Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        validator: controller.validatePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      AppLabelText(text: 'Konfirmasi Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Konfirmasi password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                        ),
                        validator: controller.validateConfirmPassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // AppLabelText(text: 'Role'),
                      // const SizedBox(height: 8),
                      // Obx(() {
                      //   if (controller.roles.isEmpty) {
                      //     return const Text('No roles available');
                      //   }

                      //   return DropdownButtonFormField<String>(
                      //     value: controller.selectedRoleId.value,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       filled: true,
                      //       prefixIcon: const Icon(
                      //         Icons.assignment_ind_outlined,
                      //       ),
                      //     ),
                      //     items:
                      //         controller.roles.map((role) {
                      //           return DropdownMenuItem<String>(
                      //             value: role.id,
                      //             child: Text(role.name),
                      //           );
                      //         }).toList(),
                      //     onChanged: (value) {
                      //       if (value != null) {
                      //         controller.setSelectedRole(value);
                      //       }
                      //     },
                      //   );
                      // }),
                      const SizedBox(height: 24),

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
                                      : controller.createUser,
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
                                      : Text(
                                        'Buat Akun',
                                        style: AppThemes.textTheme(
                                          context,
                                          ColorScheme.dark(),
                                        ).titleMedium!.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
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
