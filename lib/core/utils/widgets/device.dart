import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceInfo extends StatelessWidget {
  const DeviceInfo({
    super.key,
    required this.name,
    required this.total,
    required this.icon,
  });
  final String name;
  final String total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.greenSecondary.withAlpha(76),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Icon(icon, color: AppColor.white),
                const SizedBox(width: 8),
                Text(
                  total,
                  style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
