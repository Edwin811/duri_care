import 'package:duri_care/core/routes/app_navigator.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 3), () {
      AppNavigator.handleInitialNavigation();
    });
  });
  }

}
