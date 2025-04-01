import 'package:duri_care/core/resources/resources.dart';
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
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                    controller.percentage.value =
                        (index + 1) / contentsList.length;
                  },
                  itemCount: contentsList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(contentsList[index].imagePath, width: 300),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            contentsList.length,
                            (index) => buildDot(index, context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: controller.skipPage,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: AppColor.greenPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.currentPage.value ==
                            contentsList.length - 1) {
                          controller.completeOnboarding();
                        } else {
                          controller.nextPage();
                        }
                      },
                      child: Obx(
                        () => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.grey[300],
                                value: controller.percentage.value,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor.greenPrimary,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: AppColor.greenPrimary,
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
  Widget buildDot(int index, BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: 8,
        width: controller.currentPage.value == index ? 24 : 8,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              controller.currentPage.value == index
                  ? AppColor.greenPrimary
                  : Colors.grey,
        ),
      ),
    );
  }
}
