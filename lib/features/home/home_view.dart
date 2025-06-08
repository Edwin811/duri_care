import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/role_badge.dart';
import 'package:duri_care/core/utils/widgets/sync_button.dart';
import 'package:duri_care/core/utils/widgets/zone_grid.dart';
import 'package:flutter/services.dart';
import 'home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.triggerUIRefresh,
            color: AppColor.greenPrimary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(() {
                          final profilePic = controller.profilePicture.value;
                          final isUrl = profilePic.startsWith('http');
                          final initials = controller.getInitialsFromName(
                            controller.username.value,
                          );

                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColor.greenPrimary,
                            backgroundImage:
                                isUrl ? NetworkImage(profilePic) : null,
                            onBackgroundImageError: isUrl ? (_, __) {} : null,
                            child:
                                !isUrl
                                    ? Text(
                                      initials,
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
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(
                              () => Row(
                                children: [
                                  Text(
                                    'Halo, ${controller.ucapan.value}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  RoleBadge(role: controller.role.value),
                                ],
                              ),
                            ),
                            Obx(
                              () => Text(
                                controller.username.value,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Obx(() {
                      return Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.toNamed('/notification');
                            },
                            icon: const Icon(
                              Icons.notifications_none_outlined,
                              size: 32,
                            ),
                          ),
                          if (controller.hasUnreadNotifications.value)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${controller.unreadCount.value}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 5.0],
                      colors: [AppColor.greenPrimary, AppColor.greenSecondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.8,
                    children: [
                      _buildSensorCard(
                        context,
                        'Sensor Hujan',
                        '75%',
                        Icons.cloudy_snowing,
                      ),
                      _buildSensorCard(
                        context,
                        'Kelembaban Tanah',
                        '68%',
                        Icons.grass_outlined,
                      ),
                      _buildSensorCard(
                        context,
                        'Kelembaban Udara',
                        '82%',
                        Icons.air_outlined,
                      ),
                      _buildSensorCard(
                        context,
                        'Suhu Udara',
                        '28°C',
                        Icons.thermostat_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.greenSecondary.withAlpha(63),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.greenPrimary, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SyncButton(onRefresh: controller.loadUpcomingSchedule),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Jadwal Mendatang:',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Obx(
                              () => Text(
                                controller.upcomingSchedule.value != null
                                    ? controller.scheduleService
                                        .formatScheduleWithZone(
                                          controller.upcomingSchedule.value!,
                                        )
                                    : 'Tidak ada jadwal mendatang',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.greenSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const ZoneGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
