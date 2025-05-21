import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationHelper extends GetxController {
  var currentIndex = 0.obs;

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
      floatingActionButton: FutureBuilder<String>(
        future: homeController.getRoleName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          final userRole = snapshot.data ?? '';
          final isOwner = userRole == 'owner';
          return isOwner
              ? FloatingActionButton(
                onPressed: () {
                  Get.toNamed('/add-zone');
                },
                backgroundColor: AppColor.greenPrimary,
                child: const Icon(Icons.add, color: AppColor.white),
              )
              : const SizedBox.shrink();
        },
      ),
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
