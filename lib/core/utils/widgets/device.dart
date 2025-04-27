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
  final RxInt total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.4,
      height: screenSize.height * 0.065,
      padding: EdgeInsets.all(screenSize.width * 0.01),
      decoration: BoxDecoration(
        color: AppColor.greenSecondary.withAlpha(76),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: screenSize.width * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColor.white,
                  size: screenSize.width * 0.05,
                ),
                SizedBox(width: screenSize.width * 0.02),
                Obx(
                  () => Text(
                    total.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
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
