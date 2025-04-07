import 'package:duri_care/core/routes/app_navigator.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  // bool _navigated = false;

  @override
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 3), () {
      AppNavigator.handleInitialNavigation();
    });
  }

}
