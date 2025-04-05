import 'dart:async';

import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/zone/zone_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Zone extends StatefulWidget {
  const Zone({super.key, this.onPowerButtonPressed, this.onSelectZone});
  final void Function()? onPowerButtonPressed;
  final void Function()? onSelectZone;

  @override
  State<Zone> createState() => _ZoneState();
}

class _ZoneState extends State<Zone> {
  final timer = '00:00:00'.obs;
  final isActive = false.obs;
  Timer? _countdownTimer;

  void _powerButton() {
    isActive.value = !isActive.value;
    if (isActive.value) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    int totalSeconds = 30;

    _countdownTimer = Timer.periodic(oneSecond, (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;
        final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
        this.timer.value = '$hours:$minutes:$seconds';
      } else {
        _stopTimer();
        isActive.value = false;
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    timer.value = '00:00:00';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () {
          widget.onSelectZone?.call();
          Get.toNamed('/zone');
        },
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            color: isActive.value ? AppColor.greenPrimary : AppColor.white,
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
                      onPressed: _powerButton,
                      icon: SvgPicture.asset(
                        'assets/icons/power.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          isActive.value ? AppColor.greenOn : AppColor.redOff,
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
                            isActive.value
                                ? AppColor.greenSecondary
                                : AppColor.greenPrimary,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        timer.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                // zone name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Zona 1',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color:
                          isActive.value
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
                                isActive.value
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
                                          isActive.value
                                              ? AppColor.white
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 60%',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          isActive.value
                                              ? AppColor.greenSecondary
                                              : AppColor.greenPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                                isActive.value
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
                                          isActive.value
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
                                      isActive.value
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color:
                                          isActive.value
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
      ),
    );
  }
}
