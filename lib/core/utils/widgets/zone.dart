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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Find the current zone data in the controller's zones list
      final zoneIndex = controller.zones.indexWhere(
        (z) => z['id'].toString() == zoneData['id'].toString(),
      );
      final currentZoneData =
          zoneIndex != -1 ? controller.zones[zoneIndex] : zoneData;
      final bool isActiveStatus = currentZoneData['isActive'] ?? false;
      final zoneIdStr = zoneData['id']?.toString() ?? '';

      return InkWell(
        onTap: () {
          onSelectZone?.call();
          Get.toNamed(
            '/zone',
            parameters: {'zoneId': zoneData['id'].toString()},
          );
        },
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            color: isActiveStatus ? AppColor.greenPrimary : AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // power button & timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Call toggleActive with the correct zone ID as string
                        if (zoneIdStr.isNotEmpty) {
                          controller.toggleActive(zoneIdStr);
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/power.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          isActiveStatus ? AppColor.greenOn : AppColor.redOff,
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
                            isActiveStatus
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
                // zone name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    zoneData['name'] ?? 'Unnamed Zone',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color:
                          isActiveStatus
                              ? AppColor.white
                              : AppColor.greenPrimary,
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
                            Icons.water_drop_outlined,
                            color:
                                isActiveStatus
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
                                    text: 'Kelembaban Tanah',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          isActiveStatus
                                              ? AppColor.white
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${zoneData['moisture'] ?? ' 0%'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          isActiveStatus
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
                            Icons.cloud_done_outlined,
                            color:
                                isActiveStatus
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
                                    text: 'Status IoT',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      color:
                                          isActiveStatus
                                              ? AppColor.white
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 4)),
                                  WidgetSpan(
                                    child: Icon(
                                      isActiveStatus
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color:
                                          isActiveStatus
                                              ? AppColor.greenTertiary
                                              : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ],
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
