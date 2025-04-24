import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationHelper extends GetxController {
  var currentIndex = 0.obs;

  void resetNavigation() {
    currentIndex.value = 0;
  }
}

class MainNavigationView extends StatelessWidget {
  MainNavigationView({super.key});
  final navigationHelper = Get.find<NavigationHelper>();
  static const String route = '/main';

  final List<Widget> pages = [HomeView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationHelper.currentIndex.value,
          children: pages,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/add-zone');
        },
        backgroundColor: AppColor.greenPrimary,
        child: const Icon(Icons.add, color: AppColor.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
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
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
