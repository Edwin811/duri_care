import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_controller.dart';

class OnboardingBinding implements Bindings {
  @override
  void dependencies() async {
    final prefs = await SharedPreferences.getInstance();
    Get.put(prefs);
    Get.lazyPut(() => OnboardingController(prefs: prefs));
  }
}
