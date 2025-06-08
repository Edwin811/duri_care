import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/themes/app_themes.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/schedule_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zone_controller.dart';

class ZoneView extends GetView<ZoneController> {
  const ZoneView({super.key});
  static const String route = '/zone';

  @override
  Widget build(BuildContext context) {
    final zoneId = Get.parameters['zoneId'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (zoneId != null && zoneId.isNotEmpty) {
        controller.loadZoneById(zoneId);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Get.back(result: result);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.greenPrimary,
          leading: AppBackButton(iconColor: AppColor.white),
          title: Obx(
            () => Text(
              controller.selectedZone.isNotEmpty
                  ? controller.selectedZone['name'] ?? 'Zone Details'
                  : 'Zone Details',
              style:
                  AppThemes.textTheme(context, ColorScheme.dark()).titleLarge,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColor.white),
              tooltip: 'Edit Zone',
              onPressed: () {
                if (zoneId != null) {
                  Get.toNamed('/edit-zone', parameters: {'zoneId': zoneId});
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColor.redOff),
              tooltip: 'Delete Zone',
              onPressed: () {
                if (zoneId != null) {
                  controller.deleteZone(int.parse(zoneId));
                }
              },
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: Obx(
          () =>
              controller.isLoading.value
                  ? Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.grass_outlined,
                                size: 60,
                                color: AppColor.greenPrimary.withAlpha(100),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Memuat data zona...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.greenPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Mohon tunggu sebentar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: AppFilledButton(
                                onPressed: () {
                                  final zoneId =
                                      controller.selectedZone['id']?.toString();
                                  final zoneName =
                                      controller.selectedZone['name']
                                          ?.toString();
                                  if (zoneId != null) {
                                    Get.toNamed(
                                      '/history',
                                      arguments: {
                                        'zoneId': zoneId,
                                        'zoneName': zoneName,
                                      },
                                      parameters: {'zoneId': zoneId},
                                    );
                                  }
                                },
                                icon: Icons.history,
                                text: 'Riwayat',
                                textSize: 16,
                                width: 135,
                                height: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: AppColor.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColor.greenPrimary),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColor.greenPrimary
                                              .withAlpha(70),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.timer,
                                          color: AppColor.greenPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Durasi Penyiraman Manual',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: AppColor.greenPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Atur durasi penyiraman manual untuk zona ini',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.water_drop,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Durasi:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 8.0,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                  enabledThumbRadius: 10.0,
                                                ),
                                          ),
                                          child: Obx(
                                            () => Slider(
                                              value:
                                                  controller
                                                              .manualDuration
                                                              .value <
                                                          1
                                                      ? 1.0
                                                      : controller
                                                              .manualDuration
                                                              .value >
                                                          60
                                                      ? 60.0
                                                      : controller
                                                          .manualDuration
                                                          .value
                                                          .toDouble(),
                                              min: 1,
                                              max: 60,
                                              divisions: 60,
                                              label:
                                                  '${controller.manualDuration.value} menit',
                                              onChanged: (val) {
                                                controller
                                                    .manualDuration
                                                    .value = val.round();
                                              },
                                              activeColor:
                                                  AppColor.greenPrimary,
                                              inactiveColor: AppColor
                                                  .greenPrimary
                                                  .withAlpha(100),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.greenPrimary,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Obx(
                                          () => Text(
                                            '${controller.manualDuration.value} menit',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AppFilledButton(
                                      onPressed: () async {
                                        await controller.saveManualDuration();
                                      },
                                      text: 'Simpan',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SchedulingSectionWidget(controller: controller),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
