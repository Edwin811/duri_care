import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/models/onboarding.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final AuthController authController = Get.find<AuthController>();
  final RxInt currentPage = 0.obs;
  final RxDouble percentage = 0.25.obs;

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
    await authController.completeOnboarding();
    Get.offNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
