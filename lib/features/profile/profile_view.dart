import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/features/profile/edit_profile_view.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context) {
    // Initialize controller once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.forceRefreshProfile();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 25, top: 20),
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppColor.greenPrimary.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Obx(() {
                            final profilePic = controller.profilePicture.value;
                            final isUrl =
                                profilePic.isNotEmpty &&
                                profilePic.startsWith('http');
                            return Container(
                              padding: const EdgeInsets.all(3.0),
                              key: Key('avatar_${controller.avatarKey.value}'),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColor.greenPrimary.withAlpha(100),
                                  width: 4,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: AppColor.greenPrimary
                                    .withAlpha(100),
                                backgroundImage:
                                    isUrl
                                        ? NetworkImage(
                                          profilePic,
                                          headers: {
                                            'Cache-Control': 'no-cache',
                                            'Pragma': 'no-cache',
                                          },
                                        )
                                        : null,
                                child:
                                    !isUrl
                                        ? Text(
                                          profilePic.isNotEmpty
                                              ? profilePic
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        )
                                        : null,
                              ),
                            );
                          }),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                // Sebelum navigasi, refresh profile terlebih dahulu
                                await controller.refreshProfileData();

                                // Navigasi ke halaman edit
                                await Get.toNamed(EditProfileView.route);

                                // Setelah kembali, refresh profile lagi untuk memastikan perubahan terupdate
                                await controller.refreshProfileData();

                                // Tambahkan delay kecil untuk memastikan UI dirender ulang
                                await Future.delayed(
                                  const Duration(milliseconds: 200),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.greenPrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.greenPrimary.withAlpha(
                                        50,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Obx(
                        () => Text(
                          controller.username.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Text(
                          controller.email.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.greenPrimary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            controller.role.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 15, top: 10),
                  child: Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColor.greenPrimary,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Obx(
                          () =>
                              controller.role.value.toLowerCase() == 'owner'
                                  ? Column(
                                    children: [
                                      _buildIOSSettingsItem(
                                        context,
                                        title: 'Manajemen Akun Pegawai',
                                        icon: CupertinoIcons.person_2,
                                        showBorder: true,
                                        onTap: () {
                                          Get.toNamed('/user-management');
                                        },
                                      ),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                AppFilledButton(
                  onPressed: () {
                    controller.logout();
                  },
                  text: 'Keluar',
                  icon: Icons.logout_rounded,
                  color: AppColor.redOff,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSSettingsItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool showBorder = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border:
              showBorder
                  ? Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                  )
                  : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.greenPrimary.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColor.greenPrimary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: Colors.grey,
                ),
          ],
        ),
      ),
    );
  }
}
