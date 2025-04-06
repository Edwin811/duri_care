import 'package:duri_care/features/error/error_404_view.dart';
import 'package:duri_care/features/error/connectivity_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectivityController>();

    return Obx(() {
      if (!controller.isConnected.value) {
        return const Error404View();
      }

      return child;
    });
  }
}
