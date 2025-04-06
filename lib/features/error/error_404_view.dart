import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:flutter/services.dart';
import 'connectivity_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Error404View extends GetView<ConnectivityController> {
  const Error404View({super.key});
  static const String route = '/error';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/404-Error.svg',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Koneksi Internet Terputus',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pastikan perangkat Anda terhubung ke jaringan Wi-Fi atau data seluler',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppFilledButton(onPressed: () async {
                    await controller.checkConnection();
                    if (controller.isConnected.value) {
                      Get.back();
                    }
                  }, text: 'Refresh')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
