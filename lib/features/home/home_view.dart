import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_bottomNavigationBar.dart';
import 'package:duri_care/core/utils/widgets/device.dart';
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
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() {
                              final profilePic =
                                  controller.profilePicture.value;
                              final isUrl = profilePic.startsWith('http');

                              return CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColor.greenPrimary
                                    .withAlpha(100),
                                backgroundImage:
                                    isUrl ? NetworkImage(profilePic) : null,
                                child:
                                    !isUrl
                                        ? Text(
                                          profilePic.isNotEmpty
                                              ? profilePic
                                              : '?',
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
                                      RoleBadge(role: 'owner'),
                                    ],
                                  ),
                                ),
                                Text(
                                  controller.username.value,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_none_outlined,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // container
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.greenPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Weather Section
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.greenSecondary.withAlpha(76),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '28℃',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.copyWith(
                                              color: Colors.white,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.09,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/cerah.png',
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.15,
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.15,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Cerah',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.05,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Jember, Jawa Timur',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Device Status Section
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: DeviceInfo(
                                    name: 'Total Device',
                                    total: '4',
                                    icon: Icons.device_hub_rounded,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: DeviceInfo(
                                    name: 'Device Aktif',
                                    total: '2',
                                    icon: Icons.lan_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: DeviceInfo(
                                    name: 'Pegawai Terdaftar',
                                    total: '3',
                                    icon: Icons.person_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // info section
                    const SizedBox(height: 20),
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.greenSecondary.withAlpha(63),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColor.greenPrimary,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SyncButton(),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                    Flexible(
                                      child: Text(
                                        'Menghidupkan aktuator di Zona 1 pada 10:00 WIB',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.greenSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // zone section
                ZoneGrid(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-zone'),
        backgroundColor: AppColor.greenPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
