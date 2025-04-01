import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Zone extends StatefulWidget {
  const Zone({super.key});

  @override
  State<Zone> createState() => _ZoneState();
}

class _ZoneState extends State<Zone> {
  final timer = '00:00:00'.obs;
  final isActive = false.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        // color: AppColor.greenPrimary,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // power button & timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/icons/power.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      isActive.value ? AppColor.greenTertiary : AppColor.redOff,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 75,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColor.greenPrimary,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '00:00:00',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // zone name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Zona 1',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColor.greenPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: AppColor.greenPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kelembapan Tanah',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColor.greenPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done_outlined,
                        color: AppColor.greenPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status IoT',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColor.greenPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
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
    );
  }
}
