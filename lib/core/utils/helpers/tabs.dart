import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabsController extends GetxController {
  var currentIndex = 0.obs;
  PageController pageController = PageController();

  void changeTab(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class Tabs extends StatelessWidget {
  Tabs({super.key});

  final TabsController tabController = Get.put(TabsController());

  final List<Widget> pages = [const HomeView(), const ProfileView()];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabsController>(
      init: tabController,
      builder: (controller) {
        return Scaffold(
          body: PageView(
            controller: controller.pageController,
            onPageChanged: (index) => controller.currentIndex.value = index,
            physics: const NeverScrollableScrollPhysics(),
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Obx(
              () => BottomNavigationBar(
                currentIndex: controller.currentIndex.value,
                onTap: controller.changeTab,
                type: BottomNavigationBarType.fixed,
                elevation: 16,
                backgroundColor: Colors.white,
                selectedItemColor: AppColor.greenPrimary,
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                    tooltip: 'Home Page',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                    tooltip: 'Profile Page',
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Obx(
            () =>
                controller.currentIndex.value == 0
                    ? FloatingActionButton(
                      onPressed: () => Get.toNamed('/add-zone'),
                      backgroundColor: AppColor.greenPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                    : const SizedBox(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}
