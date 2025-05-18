import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:duri_care/models/zone_model.dart';
import 'package:duri_care/models/permission_model.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
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

class PermissionManagementController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ZoneService _zoneService = Get.find<ZoneService>();
  final SupabaseClient _supabase = Supabase.instance.client;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<ZoneModel> allZones = <ZoneModel>[].obs;
  final RxList<int> userZoneIds = <int>[].obs;
  final RxList<PermissionModel> allPermissions = <PermissionModel>[].obs;
  final RxList<String> userPermissionIds = <String>[].obs;
  final RxList<ZonePermissionModel> zonePermissions =
      <ZonePermissionModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasChanges = false.obs;

  final RxMap<int, bool> zoneChanges = <int, bool>{}.obs;
  final RxMap<String, bool> permissionChanges = <String, bool>{}.obs;
  final RxList<Map<String, dynamic>> zonePermissionChanges =
      <Map<String, dynamic>>[].obs;

  // Search functionality
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  List<String> get filteredZones {
    if (searchQuery.value.isEmpty) {
      return allZones.map((zone) => zone.name).toList();
    }
    return allZones
        .where(
          (zone) =>
              zone.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .map((zone) => zone.name)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAllZones() async {
    if (user.value == null) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id ?? '';
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Fetch all zones
      final zones = await _zoneService.loadZones(userId);
      allZones.assignAll(zones);

      // Fetch user's zone access
      final zoneUserRows = await _supabase
          .from('zone_users')
          .select('zone_id, allow_auto_schedule')
          .eq('user_id', user.value!.id);

      userZoneIds.clear();
      zonePermissions.clear();

      for (var row in zoneUserRows) {
        final zoneId = row['zone_id'] as int;
        userZoneIds.add(zoneId);

        // Add zone-specific permissions
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

  Future<void> fetchUserPermissions() async {
    if (user.value == null) return;

    try {
      isLoading.value = true;
      final userId = user.value!.id;

      // Fetch all permissions
      final perms = await _userService.getAllPermissions();
      allPermissions.assignAll(
        perms.map<PermissionModel>((p) => PermissionModel.fromMap(p)),
      );

      // Fetch user's permissions
      final userPermRows = await _supabase
          .from('user_permissions')
          .select('permission_id')
          .eq('user_id', userId);

      userPermissionIds.clear();
      userPermissionIds.addAll(
        userPermRows.map<String>((p) => p['permission_id'].toString()),
      );

      // Reset change tracking
      zoneChanges.clear();
      permissionChanges.clear();
      zonePermissionChanges.clear();
      hasChanges.value = false;
    } catch (e) {
      DialogHelper.showErrorDialog(
        title: 'Error',
        message: 'Gagal memuat data permission: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateZonePermission(int zoneId, bool add) async {
    if (user.value == null) return;

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

          // Also remove any zone-specific permissions
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
    // Check if the zone is selected, if not, don't allow permission toggle
    if (!userZoneIds.contains(zoneId)) {
      DialogHelper.showErrorDialog(
        title: 'Akses Ditolak',
        message:
            'Berikan akses ke zona ini terlebih dahulu sebelum mengatur permission.',
      );
      return;
    }

    // Check if permission already exists
    final existingIndex = zonePermissions.indexWhere(
      (p) => p.zoneId == zoneId && p.key == permissionKey,
    );

    if (existingIndex >= 0) {
      // If it exists and new value is different, update it
      if (zonePermissions[existingIndex].value != value) {
        zonePermissions.removeAt(existingIndex);
        zonePermissions.add(
          ZonePermissionModel(zoneId: zoneId, key: permissionKey, value: value),
        );

        // Add to changes
        zonePermissionChanges.add({
          'zone_id': zoneId,
          'key': permissionKey,
          'value': value,
        });

        hasChanges.value = true;
      }
    } else {
      // If it doesn't exist, add it
      zonePermissions.add(
        ZonePermissionModel(zoneId: zoneId, key: permissionKey, value: value),
      );

      // Add to changes
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
    if (user.value == null) return;

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

      final userId = user.value!.id;

      // Process zone access changes
      for (final entry in zoneChanges.entries) {
        final zoneId = entry.key;
        final isAdded = entry.value;

        try {
          if (isAdded) {
            await _userService.assignUserToZone(userId, zoneId);
          } else {
            await _userService.removeUserFromZone(userId, zoneId);
          }
        } catch (e) {
          throw Exception('Failed to update zone access: $e');
        }
      }

      // Process permission changes
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

      // Process zone permission changes
      for (final change in zonePermissionChanges) {
        final zoneId = change['zone_id'];
        final key = change['key'];
        final value = change['value'];

        try {
          await _userService.updateZonePermission(userId, zoneId, key, value);
        } catch (e) {
          throw Exception('Failed to update zone permission: $e');
        }
      }

      // Reset change tracking
      zoneChanges.clear();
      permissionChanges.clear();
      zonePermissionChanges.clear();
      hasChanges.value = false;

      DialogHelper.showSnackBar(
        title: 'Berhasil',
        message: 'Permission pegawai berhasil diperbarui',
        isError: false,
      );
    } catch (e) {
      DialogHelper.showSnackBar(
        title: 'Error',
        message: 'Gagal menyimpan perubahan: ${e.toString()}',
        isError: true,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  bool hasUnsavedChanges() {
    return hasChanges.value;
  }

  bool validatePermissionData() {
    if (user.value == null) {
      DialogHelper.showSnackBar(
        message: 'Data pengguna tidak valid',
        isError: true,
      );
      return false;
    }

    return true;
  }
}
