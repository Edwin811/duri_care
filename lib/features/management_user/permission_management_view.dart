import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionManagementView extends GetView<UserManagementController> {
  static const String route = '/permission-management';
  const PermissionManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin Akses Zona'),
        centerTitle: true,
        backgroundColor: AppColor.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: AppBackButton(
          onPressed: () async {
            if (controller.hasUnsavedChanges()) {
              bool shouldSave =
                  await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('Perubahan Belum Disimpan'),
                      content: const Text(
                        'Apakah Anda ingin menyimpan perubahan sebelum keluar?',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Tidak'),
                          onPressed: () => Get.back(result: false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.greenPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => Get.back(result: true),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (shouldSave) {
                await controller.saveChanges();
              }
            }
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = controller.selectedUser.value;
          if (user == null) {
            return const Center(child: Text('Pilih pegawai terlebih dahulu.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(context, user),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Daftar Zona',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final zones = controller.filteredZones;
                  if (zones.isEmpty) {
                    return const Center(child: Text('Tidak ada zona tersedia'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: zones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final zone = zones[idx];
                      return Obx(() {
                        final isAssigned = controller.userZoneIds.contains(
                          zone.id,
                        );

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(25),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color:
                                    isAssigned
                                        ? AppColor.greenPrimary.withAlpha(30)
                                        : Colors.grey.withAlpha(30),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color:
                                            isAssigned
                                                ? AppColor.greenPrimary
                                                : Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          zone.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                isAssigned
                                                    ? AppColor.greenPrimary
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Obx(
                                    () => _buildPermissionSwitch(
                                      'Izinkan Akses Zona',
                                      controller.userZoneIds.contains(zone.id),
                                      Icons.vpn_key_outlined,
                                      (val) => controller.updateZonePermission(
                                        zone.id,
                                        val,
                                      ),
                                    ),
                                  ),

                                  Obx(() {
                                    final isZoneAssigned = controller
                                        .userZoneIds
                                        .contains(zone.id);
                                    return AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child:
                                          isZoneAssigned
                                              ? Column(
                                                children: [
                                                  AnimatedOpacity(
                                                    opacity:
                                                        isZoneAssigned
                                                            ? 1.0
                                                            : 0.0,
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: const Divider(
                                                      height: 24,
                                                    ),
                                                  ),
                                                  AnimatedOpacity(
                                                    opacity:
                                                        isZoneAssigned
                                                            ? 1.0
                                                            : 0.0,
                                                    duration: const Duration(
                                                      milliseconds: 300,
                                                    ),
                                                    child: Obx(() {
                                                      final autoScheduleEnabled =
                                                          controller
                                                              .zonePermissions
                                                              .firstWhereOrNull(
                                                                (p) =>
                                                                    p.zoneId ==
                                                                        zone.id &&
                                                                    p.key ==
                                                                        'allow_auto_schedule',
                                                              )
                                                              ?.value ??
                                                          false;

                                                      return _buildPermissionSwitch(
                                                        'Izinkan Jadwal Otomatis',
                                                        autoScheduleEnabled,
                                                        Icons.schedule,
                                                        (val) => controller
                                                            .toggleZonePermission(
                                                              zone.id,
                                                              'allow_auto_schedule',
                                                              val,
                                                            ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              )
                                              : const SizedBox.shrink(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          backgroundColor:
              controller.hasChanges.value ? AppColor.greenPrimary : Colors.grey,
          icon:
              controller.isSaving.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save, color: Colors.white),
          label: Text(
            controller.isSaving.value ? 'Menyimpan...' : 'Simpan',
            style: const TextStyle(color: Colors.white),
          ),
          onPressed:
              controller.hasChanges.value && !controller.isSaving.value
                  ? () async {
                    await controller.saveChanges();
                    if (!controller.hasChanges.value) Get.back();
                  }
                  : null,
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch(
    String label,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: value ? AppColor.greenPrimary.withAlpha(20) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  value
                      ? AppColor.greenPrimary.withAlpha(25)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? AppColor.greenPrimary : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? AppColor.greenPrimary : Colors.black87,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColor.greenPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.greenPrimary.withAlpha(20),
            AppColor.greenSecondary.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.greenPrimary.withAlpha(30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColor.greenPrimary,
            child: Text(
              (user.fullname != null && user.fullname.isNotEmpty)
                  ? user.fullname[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullname ?? 'No Name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? 'No Email',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.greenPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (user.roleName != null && (user.roleName.toLowerCase() == 'employee'))
                          ? 'Pegawai'
                          : (user.roleName ?? 'No Role'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => _buildStatChip(
                        controller.userZoneIds.length.toString(),
                        'Zona',
                        Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flexible(
                    //   child: Obx(
                    //     () => _buildStatChip(
                    //       controller.userPermissionIds.length.toString(),
                    //       'Permission',
                    //       Icons.verified_user_outlined,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String count, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black54),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$count $label',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
