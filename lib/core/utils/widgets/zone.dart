import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Zone extends GetView<ZoneController> {
  const Zone({
    super.key,
    this.onPowerButtonPressed,
    this.onSelectZone,
    required this.zoneData,
  });

  final void Function()? onPowerButtonPressed;
  final void Function()? onSelectZone;
  final Map<String, dynamic> zoneData;
  int _getZoneDuration(Map<String, dynamic> currentZoneData, String zoneIdStr) {
    if (controller.selectedZone.isNotEmpty &&
        controller.selectedZone['id']?.toString() == zoneIdStr) {
      return controller.manualDuration.value;
    }
    return currentZoneData['duration'] ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    final zoneIdStr = zoneData['id']?.toString() ?? '';
    return Obx(() {
      final zoneIndex = controller.zones.indexWhere(
        (z) => z['id'].toString() == zoneIdStr,
      );
      final currentZoneData =
          zoneIndex != -1 ? controller.zones[zoneIndex] : zoneData;
      final bool isStatus = currentZoneData['is_active'] ?? false;

      return InkWell(
        onTap: () {
          onSelectZone?.call();
          Get.toNamed('/zone', parameters: {'zoneId': zoneIdStr});
        },
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            color: isStatus ? AppColor.greenPrimary : AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (zoneIdStr.isNotEmpty) {
                          controller.toggleActive(zoneIdStr);
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/power.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          isStatus ? AppColor.greenOn : AppColor.redOff,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 70,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color:
                            isStatus
                                ? AppColor.greenSecondary
                                : AppColor.greenPrimary,
                      ),
                      alignment: Alignment.center,
                      child: Obx(
                        () => Text(
                          controller.zoneTimers[zoneIdStr]?.value ?? '00:00:00',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    zoneData['name'],
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: isStatus ? AppColor.white : AppColor.greenPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.code,
                            color:
                                isStatus
                                    ? AppColor.yellowPrimary
                                    : AppColor.greenPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Kode Zona: ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          isStatus
                                              ? AppColor.white
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${zoneData['zone_code']}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          isStatus
                                              ? AppColor.greenSecondary
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color:
                                isStatus
                                    ? AppColor.yellowPrimary
                                    : AppColor.greenPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(
                              () => RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Durasi',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color:
                                            isStatus
                                                ? AppColor.white
                                                : AppColor.greenPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${_getZoneDuration(currentZoneData, zoneIdStr)} menit',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        color:
                                            isStatus
                                                ? AppColor.greenSecondary
                                                : AppColor.greenPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
