import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zone_controller.dart';

class ZoneView extends GetView<ZoneController> {
  final String zoneName;

  const ZoneView({super.key, required this.zoneName});
  static const String route = '/zone';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Get.back(result: result);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(),
          title: Text(zoneName),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Zone Name: $zoneName',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.toggleActive,
                  child: Text(
                    controller.isActive.value
                        ? 'Deactivate Zone'
                        : 'Activate Zone',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
