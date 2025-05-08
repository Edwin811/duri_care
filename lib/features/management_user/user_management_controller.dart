import 'package:duri_care/core/services/user_management_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/role_model.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementController extends GetxController {
  final UserManagementService _userManagementService =
      Get.find<UserManagementService>();

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;

  // Form controllers
  late TextEditingController emailController;
  late TextEditingController fullnameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final Rx<String?> selectedRoleId = Rx<String?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    fullnameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    fetchRoles();
    fetchUsers();
  }

  @override
  void onClose() {
    emailController.dispose();
    fullnameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userManagementService.fetchAllUsers();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Failed to load users: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRoles() async {
    try {
      final rolesList = await _userManagementService.getAllRoles();

      final filteredRoles =
          rolesList
              .where((role) => role.name.toLowerCase() != 'owner')
              .toList();

      roles.assignAll(filteredRoles);

      if (roles.isNotEmpty && selectedRoleId.value == null) {
        selectedRoleId.value = roles.first.id;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Failed to load roles: ${e.toString()}',
      );
    }
  }

  void setSelectedRole(String roleId) {
    selectedRoleId.value = roleId;
  }

  void resetForm() {
    emailController.clear();
    fullnameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    if (roles.isNotEmpty) {
      selectedRoleId.value = roles.first.id;
    } else {
      selectedRoleId.value = null;
    }
  }

  Future<void> createUser() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Password dan konfirmasi password tidak cocok',
      );
      return;
    }

    if (selectedRoleId.value == null) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Please select a role',
      );
      return;
    }

    try {
      isCreating.value = true;
      await _userManagementService.createUser(
        email: emailController.text,
        password: passwordController.text,
        fullname: fullnameController.text,
        roleId: selectedRoleId.value!,
      );

      await fetchUsers();
      resetForm();
      Get.back();

      DialogHelper.showSuccessDialog(
        title: 'Success',
        message: 'User created successfully',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Failed to create user: ${e.toString()}',
      );
    } finally {
      isCreating.value = false;
    }
  }

  // Future<void> updateUserRole(String userId, String roleId) async {
  //   try {
  //     isLoading.value = true;
  //     await _userManagementService.updateUserRole(userId, roleId);
  //     await fetchUsers();

  //     DialogHelper.showSuccessDialog(
  //       title: 'Success',
  //       message: 'User role updated successfully',
  //     );
  //   } catch (e) {
  //     DialogHelper.showErrorDialog(
  //       title: 'Error',
  //       message: 'Failed to update user role: ${e.toString()}',
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      DialogHelper.showConfirmationDialog(
        title: 'Hapus Akun Pegawai',
        message: 'Apakah Anda yakin ingin menghapus akun pegawai?',
        onConfirm: () async {
          await _userManagementService.deleteUser(userId);
          Get.back();
          DialogHelper.showSuccessDialog(
            title: 'Berhasil',
            message: 'Data akun pegawai berhasil dihapus',
          );
          await fetchUsers();
        },
        onCancel: () {
          Get.back();
        },
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal menghapus akun pegawai: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please insert confirm password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }
}
