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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 414;

    // Responsive padding
    final horizontalPadding =
        isSmallScreen
            ? 12.0
            : isLargeScreen
            ? 24.0
            : 16.0;
    final cardPadding = isSmallScreen ? 16.0 : 20.0;

    // Responsive spacing
    final smallSpacing = isSmallScreen ? 8.0 : 12.0;
    final mediumSpacing = isSmallScreen ? 12.0 : 16.0;
    final largeSpacing = isSmallScreen ? 16.0 : 24.0;

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
            FutureBuilder<bool>(
              future: controller.isOwner(),
              builder: (context, snapshot) {
                final isOwner = snapshot.data ?? false;
                if (!isOwner) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColor.white,
                      ),
                      tooltip: 'Edit Zone',
                      onPressed: () {
                        if (zoneId != null) {
                          Get.toNamed(
                            '/edit-zone',
                            parameters: {'zoneId': zoneId},
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColor.redOff,
                      ),
                      tooltip: 'Delete Zone',
                      onPressed: () {
                        if (zoneId != null) {
                          controller.deleteZone(int.parse(zoneId));
                        }
                      },
                    ),
                  ],
                );
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
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: smallSpacing),
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
                                textSize: isSmallScreen ? 14 : 16,
                                width: isSmallScreen ? 120 : 135,
                                height: isSmallScreen ? 36 : 40,
                              ),
                            ),
                          ),
                          SizedBox(height: mediumSpacing),
                          Card(
                            color: AppColor.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 12 : 16,
                              ),
                              side: BorderSide(color: AppColor.greenPrimary),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row - responsive layout
                                  isSmallScreen
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              isSmallScreen ? 8 : 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColor.greenPrimary
                                                  .withAlpha(70),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.timer,
                                              color: AppColor.greenPrimary,
                                              size: isSmallScreen ? 20 : 24,
                                            ),
                                          ),
                                          SizedBox(height: smallSpacing),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Durasi Penyiraman Manual',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      isSmallScreen ? 16 : 18,
                                                  color: AppColor.greenPrimary,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Atur durasi penyiraman manual untuk zona ini',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      : Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              isSmallScreen ? 8 : 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColor.greenPrimary
                                                  .withAlpha(70),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.timer,
                                              color: AppColor.greenPrimary,
                                              size: isSmallScreen ? 20 : 24,
                                            ),
                                          ),
                                          SizedBox(width: mediumSpacing),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Durasi Penyiraman Manual',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        isSmallScreen ? 16 : 18,
                                                    color:
                                                        AppColor.greenPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Atur durasi penyiraman manual untuk zona ini',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 12 : 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  SizedBox(
                                    height: isSmallScreen ? 16 : 20,
                                  ), // Slider section - responsive layout
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.water_drop,
                                            size: isSmallScreen ? 18 : 20,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: smallSpacing),
                                          Text(
                                            'Durasi:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: isSmallScreen ? 14 : 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: smallSpacing),
                                      // Slider with value display
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                trackHeight:
                                                    isSmallScreen ? 6.0 : 8.0,
                                                thumbShape:
                                                    RoundSliderThumbShape(
                                                      enabledThumbRadius:
                                                          isSmallScreen
                                                              ? 8.0
                                                              : 10.0,
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
                                          SizedBox(width: smallSpacing),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  isSmallScreen ? 8 : 10,
                                              vertical: isSmallScreen ? 4 : 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColor.greenPrimary,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Obx(
                                              () => Text(
                                                '${controller.manualDuration.value} menit',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen ? 12 : 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: mediumSpacing),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AppFilledButton(
                                      onPressed: () async {
                                        await controller.saveManualDuration();
                                      },
                                      text: 'Simpan',
                                      textSize: isSmallScreen ? 14 : 16,
                                      height: isSmallScreen ? 40 : 44,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: largeSpacing),
                          SchedulingSectionWidget(controller: controller),
                          SizedBox(
                            height: largeSpacing + (isLargeScreen ? 16 : 0),
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
