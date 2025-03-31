import 'package:duri_care/models/onboarding/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  static const String route = '/onboarding';
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: (index) => controller.currentPage.value = index,
            itemCount: contentsList.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(contentsList[index].imagePath, width: 300),
                  const SizedBox(height: 20),
                  Text(
                    contentsList[index].title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    contentsList[index].description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Obx(
              () => Visibility(
                visible: controller.currentPage.value < contentsList.length - 1,
                child: TextButton(
                  onPressed: controller.skipPage,
                  child: const Text('Skip'),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.currentPage.value < contentsList.length - 1
                        ? controller.nextPage
                        : controller.completeOnboarding,
                child: Text(
                  controller.currentPage.value < contentsList.length - 1
                      ? 'Next'
                      : 'Finish',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
