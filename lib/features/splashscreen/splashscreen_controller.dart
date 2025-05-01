import 'package:duri_care/core/routes/app_navigator.dart';
import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    AppNavigator.handleInitialNavigation();
  }
}
