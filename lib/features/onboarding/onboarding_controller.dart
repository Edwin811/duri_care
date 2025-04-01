import 'package:duri_care/models/onboarding/data.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxDouble percentage = 0.25.obs;
  SharedPreferences? prefs;

  @override
  void onInit()  async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
  }

  void nextPage() {
    if (currentPage.value < contentsList.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  void skipPage() {
    completeOnboarding();
  }

  void completeOnboarding() async {
    await prefs!.setBool('firstLaunch', false);
    Get.offNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
