import 'package:duri_care/features/management_user/permission_management_controller.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:duri_care/models/role_model.dart';
import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionManagementView extends GetView<PermissionManagementController> {
  final UserModel user;
  final List<RoleModel> roles;
  final List<String> allZones;
  final List<String> allPermissions;
  final List<String> userZones;
  final List<String> userPermissions;
  final void Function(String zone, bool add) onZonePermissionChanged;
  final void Function(String permission, bool add) onPermissionChanged;

  const PermissionManagementView({
    super.key,
    required this.user,
    required this.roles,
    required this.allZones,
    required this.allPermissions,
    required this.userZones,
    required this.userPermissions,
    required this.onZonePermissionChanged,
    required this.onPermissionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.hasUnsavedChanges()) {
          final result = await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Perubahan Belum Disimpan'),
                  content: const Text(
                    'Apakah Anda ingin menyimpan perubahan sebelum keluar?',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Tidak'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.greenPrimary,
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
          );

          if (result == true) {
            await controller.saveChanges();
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Permission Pegawai'),
          backgroundColor: AppColor.greenPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            Obx(
              () =>
                  controller.hasUnsavedChanges()
                      ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Perubahan belum disimpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      : const SizedBox(),
            ),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(context),
                      const SizedBox(height: 16),
                      // _buildSearchFilter(),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildZonePermissionsHeader(),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              sliver: _buildZoneGrid(),
                            ),
                            // SliverToBoxAdapter(
                            //   child: _buildSpecialPermissionsHeader(),
                            // ),
                            // SliverPadding(
                            //   padding: const EdgeInsets.symmetric(vertical: 8),
                            //   sliver: _buildSpecialPermissionsGrid(),
                            // ),
                            // Add space at the bottom for the floating save button
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 80),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating save button
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildSaveButton(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.greenSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.greenPrimary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColor.greenPrimary,
                child: Text(
                  (user.fullname != null && user.fullname!.isNotEmpty)
                      ? user.fullname![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColor.greenSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullname ?? 'No Name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? 'No Email',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.greenPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.roleName ?? 'No Role',
                        style: TextStyle(
                          color: AppColor.greenPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final zoneCount = controller.userZoneIds.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$zoneCount zona',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ));
                      }),
                    const SizedBox(width: 8),
                    Obx(() {
                      final permCount = controller.userPermissionIds.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 12,
                              color: Colors.purple[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$permCount permission',
                              style: TextStyle(
                                color: Colors.purple[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ));
                      }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSearchFilter() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 12),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: TextField(
  //         controller: controller.searchController,
  //         decoration: InputDecoration(
  //           hintText: 'Cari zona...',
  //           prefixIcon: const Icon(Icons.search, color: Colors.grey),
  //           suffixIcon: Obx(
  //             () => controller.searchQuery.value.isNotEmpty
  //                 ? IconButton(
  //                     icon: const Icon(Icons.close, color: Colors.grey),
  //                     onPressed: () {
  //                       controller.searchController.clear();
  //                       controller.searchQuery.value = '';
  //                     },
  //                   )
  //                 : const SizedBox.shrink(),
  //           ),
  //           border: InputBorder.none,
  //           contentPadding: const EdgeInsets.symmetric(
  //             horizontal: 16,
  //             vertical: 12,
  //           ),
  //         ),
  //         onChanged: (value) {
  //           controller.searchQuery.value = value;
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildZonePermissionsHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.greenPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.map_outlined,
              size: 22,
              color: AppColor.greenPrimary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Akses Zona',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Obx(() {
            final filteredZones = controller.filteredZones;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.greenPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${controller.userZoneIds.length}/${filteredZones.length} zona',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.greenPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildZoneGrid() {
    return Obx(() {
      final filteredZones = controller.filteredZones;

      if (filteredZones.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.location_off_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.searchQuery.value.isEmpty
                      ? 'Tidak ada zona yang tersedia'
                      : 'Tidak ada zona yang sesuai dengan pencarian',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      // Calculate grid columns based on screen width
      final screenWidth = MediaQuery.of(Get.context!).size.width;
      final crossAxisCount = screenWidth > 600 ? 3 : 2;

      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final zone = filteredZones[index];
          final zoneObj = controller.allZones.firstWhere(
            (z) => z.name == zone,
            orElse: () => controller.allZones.first,
          );
          final zoneId = zoneObj.id;
          final checked = controller.userZoneIds.contains(zoneId);

          return _buildZoneCard(zone, zoneId, checked);
        }, childCount: filteredZones.length),
      );
    });
  }

  Widget _buildZoneCard(String zoneName, int zoneId, bool isSelected) {
    return InkWell(
      onTap: () => onZonePermissionChanged(zoneName, !isSelected),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColor.greenSecondary.withOpacity(0.15)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? AppColor.greenPrimary.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color:
                            isSelected
                                ? AppColor.greenPrimary
                                : Colors.grey[500],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          zoneName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color:
                                isSelected
                                    ? AppColor.greenPrimary
                                    : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ID: $zoneId',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  // Space for allow scheduling toggle
                  const SizedBox(height: 10),
                  _buildPermissionToggle(
                    zoneId,
                    'allow_auto_schedule',
                    'Izinkan Penjadwalan',
                  ),
                ],
              ),
            ),
            // Selection checkmark
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColor.greenPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColor.greenPrimary
                            : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionToggle(
    int zoneId,
    String permissionKey,
    String label,
  ) {
    return Obx(() {
      // Check if this zone has this permission enabled
      final hasPermission =
          controller.zonePermissions
              .where((p) => p.zoneId == zoneId && p.key == permissionKey)
              .isNotEmpty;

      return Row(
        children: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: hasPermission,
              onChanged: (value) {
                controller.toggleZonePermission(zoneId, permissionKey, value);
              },
              activeColor: AppColor.greenPrimary,
              activeTrackColor: AppColor.greenSecondary.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: hasPermission ? AppColor.greenPrimary : Colors.grey[600],
                fontWeight: hasPermission ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });
  }

  // Widget _buildSpecialPermissionsHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 24, bottom: 8),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.purple.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(
  //             Icons.admin_panel_settings_outlined,
  //             size: 22,
  //             color: Colors.purple[700],
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         const Text(
  //           'Permission Khusus',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const Spacer(),
  //         Obx(() {
  //           return Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //             decoration: BoxDecoration(
  //               color: Colors.purple.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Text(
  //               '${controller.userPermissionIds.length}/${controller.allPermissions.length} permission',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.purple[700],
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           );
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSpecialPermissionsGrid() {
  //   return Obx(() {
  //     if (controller.allPermissions.isEmpty) {
  //       return SliverToBoxAdapter(
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const SizedBox(height: 24),
  //               Icon(Icons.no_accounts, size: 48, color: Colors.grey[400]),
  //               const SizedBox(height: 16),
  //               Text(
  //                 'Tidak ada permission khusus yang tersedia',
  //                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }

  //     return SliverToBoxAdapter(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         child: Wrap(
  //           spacing: 10,
  //           runSpacing: 12,
  //           children:
  //               controller.allPermissions.map((permission) {
  //                 final permId = permission.id;
  //                 final permName = permission.name;
  //                 final checked = controller.userPermissionIds.contains(permId);

  //                 return GestureDetector(
  //                   onTap: () => onPermissionChanged(permName, !checked),
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 8,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color:
  //                           checked
  //                               ? Colors.purple.withOpacity(0.1)
  //                               : Colors.grey.withOpacity(0.05),
  //                       borderRadius: BorderRadius.circular(20),
  //                       border: Border.all(
  //                         color:
  //                             checked
  //                                 ? Colors.purple.withOpacity(0.5)
  //                                 : Colors.grey.withOpacity(0.2),
  //                         width: checked ? 2 : 1,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Icon(
  //                           checked
  //                               ? Icons.check_circle
  //                               : Icons.radio_button_unchecked,
  //                           size: 18,
  //                           color:
  //                               checked ? Colors.purple[700] : Colors.grey[500],
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Text(
  //                           permName,
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             fontWeight:
  //                                 checked ? FontWeight.w600 : FontWeight.normal,
  //                             color:
  //                                 checked ? Colors.purple[700] : Colors.black87,
  //                           ),
  //                         ),
  //                         if (permission.description.isNotEmpty)
  //                           Tooltip(
  //                             message: permission.description,
  //                             child: Padding(
  //                               padding: const EdgeInsets.only(left: 4),
  //                               child: Icon(
  //                                 Icons.info_outline,
  //                                 size: 16,
  //                                 color:
  //                                     checked
  //                                         ? Colors.purple[700]
  //                                         : Colors.grey[600],
  //                               ),
  //                             ),
  //                           ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               }).toList(),
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget _buildSaveButton() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color:
              controller.hasChanges.value
                  ? AppColor.greenPrimary
                  : AppColor.greenPrimary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  controller.hasChanges.value
                      ? AppColor.greenPrimary.withOpacity(0.3)
                      : Colors.transparent,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                controller.isSaving.value
                    ? null
                    : () async {
                      await controller.saveChanges();
                      if (!controller.hasChanges.value) {
                        Get.back();
                      }
                    },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child:
                  controller.isSaving.value
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Menyimpan Perubahan...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.hasChanges.value
                                ? Icons.save
                                : Icons.save_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            controller.hasChanges.value
                                ? 'Simpan Perubahan ${controller.zoneChanges.length + controller.permissionChanges.length + controller.zonePermissionChanges.length}'
                                : 'Simpan Perubahan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
