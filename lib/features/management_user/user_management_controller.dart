import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/role_model.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:duri_care/models/zone_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZonePermissionModel {
  final int zoneId;
  final String key;
  final bool value;

  ZonePermissionModel({
    required this.zoneId,
    required this.key,
    required this.value,
  });
}

class UserManagementController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ZoneService _zoneService =
      Get.isRegistered<ZoneService>() ? Get.find<ZoneService>() : ZoneService();
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxList<ZoneModel> allZones = <ZoneModel>[].obs;
  final RxList<int> userZoneIds = <int>[].obs;
  final RxList<String> userPermissionIds = <String>[].obs;
  final RxList<ZonePermissionModel> zonePermissions =
      <ZonePermissionModel>[].obs;

  final RxMap<int, bool> zoneChanges = <int, bool>{}.obs;
  final RxMap<String, bool> permissionChanges = <String, bool>{}.obs;
  final RxList<Map<String, dynamic>> zonePermissionChanges =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasChanges = false.obs;
  final RxBool passwordVisible = true.obs;
  final RxBool confirmPasswordVisible = true.obs;

  late TextEditingController emailController;
  late TextEditingController fullnameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString searchQuery = ''.obs;

  List<ZoneModel> get filteredZones {
    if (searchQuery.value.isEmpty) {
      return allZones;
    }
    return allZones
        .where(
          (zone) =>
              zone.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    fullnameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      users.value = await _userService.fetchAllUsers();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Failed to load users: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    emailController.clear();
    fullnameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
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

    try {
      isCreating.value = true;

      await _userService.createUser(
        email: emailController.text,
        password: passwordController.text,
        fullname: fullnameController.text,
        roleId: "2",
      );

      Get.back();

      resetForm();

      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Akun pegawai berhasil dibuat',
      );
      await fetchUsers();
    } catch (e) {
      String errorMessage = 'Gagal membuat akun pegawai';

      if (e.toString().contains('user_already_exist')) {
        errorMessage = 'Email sudah terdaftar, silakan gunakan email lain';
      } else {
        errorMessage = '$errorMessage: ${e.toString()}';
      }

      DialogHelper.showErrorDialog(title: 'Error', message: errorMessage);
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      DialogHelper.showConfirmationDialog(
        title: 'Hapus Akun Pegawai',
        message: 'Apakah Anda yakin ingin menghapus akun pegawai?',
        onConfirm: () async {
          await _userService.deleteUser(userId);
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

  Future<void> fetchAllZones() async {
    final user = selectedUser.value;
    if (user == null) return;
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id ?? '';
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      final zones = await _zoneService.loadZones(userId);
      allZones.assignAll(zones);
      final zoneUserRows = await _supabase
          .from('zone_users')
          .select('zone_id, allow_auto_schedule')
          .eq('user_id', user.id);
      userZoneIds.clear();
      zonePermissions.clear();
      for (var row in zoneUserRows) {
        final zoneId = row['zone_id'] as int;
        userZoneIds.add(zoneId);
        if (row.containsKey('allow_auto_schedule')) {
          zonePermissions.add(
            ZonePermissionModel(
              zoneId: zoneId,
              key: 'allow_auto_schedule',
              value: row['allow_auto_schedule'] ?? false,
            ),
          );
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal memuat data zona: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateZonePermission(int zoneId, bool add) async {
    final user = selectedUser.value;
    if (user == null) return;
    try {
      if (add) {
        if (!userZoneIds.contains(zoneId)) {
          userZoneIds.add(zoneId);
          zoneChanges[zoneId] = true;
          hasChanges.value = true;
        }
      } else {
        if (userZoneIds.contains(zoneId)) {
          userZoneIds.remove(zoneId);
          zoneChanges[zoneId] = false;
          hasChanges.value = true;
          zonePermissions.removeWhere((p) => p.zoneId == zoneId);
        }
      }
      userZoneIds.refresh();
      zonePermissions.refresh();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal mengupdate akses zona: ${e.toString()}',
      );
    }
  }

  void toggleZonePermission(int zoneId, String permissionKey, bool value) {
    if (!userZoneIds.contains(zoneId)) {
      DialogHelper.showErrorDialog(
        title: 'Akses Ditolak',
        message:
            'Berikan akses ke zona ini terlebih dahulu sebelum mengatur permission.',
      );
      return;
    }
    final existingIndex = zonePermissions.indexWhere(
      (p) => p.zoneId == zoneId && p.key == permissionKey,
    );
    if (existingIndex >= 0) {
      if (zonePermissions[existingIndex].value != value) {
        zonePermissions.removeAt(existingIndex);
        zonePermissions.add(
          ZonePermissionModel(zoneId: zoneId, key: permissionKey, value: value),
        );
        zonePermissionChanges.add({
          'zone_id': zoneId,
          'key': permissionKey,
          'value': value,
        });
        hasChanges.value = true;
      }
    } else {
      zonePermissions.add(
        ZonePermissionModel(zoneId: zoneId, key: permissionKey, value: value),
      );
      zonePermissionChanges.add({
        'zone_id': zoneId,
        'key': permissionKey,
        'value': value,
      });
      hasChanges.value = true;
    }
    zonePermissions.refresh();
  }

  Future<void> updatePermission(String permissionId, bool add) async {
    final user = selectedUser.value;
    if (user == null) return;
    try {
      if (add) {
        if (!userPermissionIds.contains(permissionId)) {
          userPermissionIds.add(permissionId);
          permissionChanges[permissionId] = true;
          hasChanges.value = true;
        }
      } else {
        if (userPermissionIds.contains(permissionId)) {
          userPermissionIds.remove(permissionId);
          permissionChanges[permissionId] = false;
          hasChanges.value = true;
        }
      }
      userPermissionIds.refresh();
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal mengupdate permission: ${e.toString()}',
      );
    }
  }

  Future<void> saveChanges() async {
    final user = selectedUser.value;
    try {
      isSaving.value = true;
      if (!hasChanges.value) {
        isSaving.value = false;
        DialogHelper.showSnackBar(
          message: 'Tidak ada perubahan yang dilakukan',
          title: 'Info',
        );
        return;
      }
      if (!validatePermissionData()) {
        isSaving.value = false;
        return;
      }
      final userId = user!.id;
      for (final entry in zoneChanges.entries) {
        final zoneId = entry.key;
        final isAdded = entry.value;
        try {
          if (isAdded) {
            await _userService.assignUserToZone(userId, zoneId);
            DialogHelper.showSuccessDialog(
              message: 'Berhasil memberikan akses zona',
            );
          } else {
            await _userService.removeUserFromZone(userId, zoneId);
          }
        } catch (e) {
          DialogHelper.showErrorDialog(
            message: 'Gagal mengupdate akses zona: $e',
          );
        }
      }
      for (final entry in permissionChanges.entries) {
        final permId = entry.key;
        final isAdded = entry.value;
        try {
          if (isAdded) {
            await _userService.assignPermissionToUser(userId, permId);
          } else {
            await _userService.removePermissionFromUser(userId, permId);
          }
        } catch (e) {
          throw Exception('Failed to update permission: $e');
        }
      }
      for (final change in zonePermissionChanges) {
        final zoneId = change['zone_id'];
        final key = change['key'];
        final value = change['value'];
        try {
          await _userService.updateZonePermission(userId, zoneId, key, value);
        } catch (e) {
          DialogHelper.showErrorDialog(
            message: 'Gagal mengupdate permission zona: $e',
          );
        }
      }
      zoneChanges.clear();
      permissionChanges.clear();
      zonePermissionChanges.clear();
      hasChanges.value = false;

      DialogHelper.showSuccessDialog(
        title: 'Berhasil',
        message: 'Permission pegawai berhasil diperbarui',
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal menyimpan perubahan: ${e.toString()}',
      );
    } finally {
      isSaving.value = false;
    }
  }

  bool hasUnsavedChanges() {
    return hasChanges.value;
  }

  bool validatePermissionData() {
    final user = selectedUser.value;
    if (user == null) {
      DialogHelper.showSnackBar(
        message: 'Data pengguna tidak valid',
        isError: true,
      );
      return false;
    }
    return true;
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
      return 'Nama harus lebih dari 3 karakter';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 6) {
      return 'Password harus lebih dari 6 karakter';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }

    if (value != passwordController.text) {
      return 'Konfirmasi password tidak sesuai';
    }

    return null;
  }
}
