import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Obx(() {
                      final profilePic = controller.profilePicture.value;
                      final isUrl = profilePic.startsWith('http');

                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColor.greenPrimary.withAlpha(100),
                        backgroundImage:
                            isUrl ? NetworkImage(profilePic) : null,
                        child:
                            !isUrl
                                ? Text(
                                  profilePic.isNotEmpty ? profilePic : '?',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                )
                                : null,
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(
                      () => Text(
                        controller.username.value,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Text(
                        controller.email.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.greenPrimary,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.greenPrimary.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => Text(
                          controller.role.value,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // _buildInfoCard(
              //   context,
              //   title: 'Nomor Telepon',
              //   value:
              //       controller.phoneNumber.value.isNotEmpty
              //           ? controller.phoneNumber.value
              //           : '-',
              //   icon: Icons.phone_outlined,
              // ),
              const SizedBox(height: 12),
              // _buildInfoCard(
              //   context,
              //   title: 'Alamat',
              //   value:
              //       controller.address.value.isNotEmpty
              //           ? controller.address.value
              //           : '-',
              //   icon: Icons.location_on_outlined,
              // ),
              const SizedBox(height: 24),

              // Settings Section
              _buildSectionHeader(context, 'Pengaturan'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                title: 'Notifikasi',
                icon: Icons.notifications_outlined,
                trailing: Obx(
                  () => Switch(
                    value: controller.isNotificationEnabled.value,
                    onChanged: controller.toggleNotification,
                    activeColor: AppColor.greenPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                title: 'Manajemen Akun Pegawai',
                icon: Icons.people_outline,
                // onTap: () => Get.toNamed('/employee-management'),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                title: 'Bayar Tagihan VPS Duri Care',
                icon: Icons.payment_outlined,
                // onTap: () => Get.toNamed('/employee-management'),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                title: 'Bantuan',
                icon: Icons.help_outline,
                // onTap: () => Get.toNamed('/help'),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                title: 'Tentang Aplikasi',
                icon: Icons.info_outline,
                // onTap: () => Get.toNamed('/about'),
              ),
              const SizedBox(height: 20),
              AppFilledButton(
                onPressed: () {
                  controller.logout();
                },
                icon: Icons.logout_rounded,
                text: 'Keluar',
                color: Colors.red,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColor.greenPrimary,
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColor.greenPrimary.withAlpha(30),
                radius: 25,
                child: Icon(icon, color: AppColor.greenPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
