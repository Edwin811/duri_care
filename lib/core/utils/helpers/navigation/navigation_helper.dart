import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/profile/profile_view.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationHelper extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to navigation changes to trigger profile refresh
    ever(currentIndex, (index) {
      if (index == 1 && Get.isRegistered<ProfileController>()) {
        // Profile tab selected, trigger refresh
        final profileController = Get.find<ProfileController>();
        profileController.onProfilePageEntered();
      }
    });
  }

  void resetNavigation() {
    currentIndex.value = 0;
  }

  @override
  void onClose() {
    super.onClose();
    currentIndex.value = 0;
  }

  void resetIndex() {
    currentIndex.value = 0;
  }
}

class MainNavigationView extends GetView<NavigationHelper> {
  const MainNavigationView({super.key});

  static const String route = '/main';

  @override
  Widget build(BuildContext context) {
    final navigationHelper = Get.find<NavigationHelper>();
    final homeController = Get.find<HomeController>();

    final List<Widget> pages = [HomeView(), ProfileView()];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationHelper.currentIndex.value,
          children: pages,
        ),
      ),
      floatingActionButton: Obx(() {
        final userRole = homeController.role.value;
        final isOwner = userRole == 'owner';
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: isOwner ? Offset.zero : const Offset(0, 2),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isOwner ? 1.0 : 0.0,
            child:
                isOwner
                    ? FloatingActionButton(
                      onPressed: () {
                        Get.toNamed('/add-zone');
                      },
                      backgroundColor: AppColor.greenPrimary,
                      child: const Icon(Icons.add, color: AppColor.white),
                    )
                    : const SizedBox.shrink(),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: navigationHelper.currentIndex.value,
            onTap: (index) {
              navigationHelper.currentIndex.value = index;
            },
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.white,
            selectedItemColor: AppColor.greenPrimary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 30),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 30),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
