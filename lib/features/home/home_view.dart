import 'package:duri_care/features/onboarding/onboarding_view.dart';

import 'home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home View'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Get.offAllNamed('/onboarding');
                Get.toNamed(OnboardingView.route);
              },
              child: const Text('Go to Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
