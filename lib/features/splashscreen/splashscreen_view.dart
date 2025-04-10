import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'splashscreen_controller.dart';

class SplashscreenView extends GetView<SplashscreenController> {
  const SplashscreenView({super.key});
  static const String route = '/splashscreen';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: AppColor.greenPrimary,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset('assets/images/DURICARE-LOGO.png', width: 200),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'For\n',
                  style: ThemeData.light().textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: 'Muzakhar Farm',
                  style: ThemeData.light().textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
