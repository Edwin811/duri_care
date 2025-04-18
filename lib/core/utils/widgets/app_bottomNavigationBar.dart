import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:duri_care/core/resources/resources.dart';

class AppBottomNavigationBar extends StatelessWidget {
  AppBottomNavigationBar({super.key});

  final AppBottomNavigationBarController controller = Get.put(
    AppBottomNavigationBarController(),
  );

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedIndex(Get.currentRoute);
    });

    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.selectedIndex.value,
        selectedItemColor: AppColor.greenPrimary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: controller.changePage,
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
    );
  }
}

class AppBottomNavigationBarController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final List<String> routes = ['/home', '/profile'];

  @override
  void onInit() {
    super.onInit();
    // Set initial index based on current route
    updateSelectedIndex(Get.currentRoute);
    
    // Add route observer to update index when route changes
    ever(Get.routing.obs, (Routing? routing) {
      if (routing != null && routing.current != null) {
        updateSelectedIndex(routing.current);
      }
    });
  }

  void updateSelectedIndex(String route) {
    int index = routes.indexOf(route);
    if (index >= 0) {
      selectedIndex.value = index;
    }
  }

  void changePage(int index) {
    if (selectedIndex.value == index) return;
    
    // Determine the transition direction based on index change
    Transition transition;
    if (index > selectedIndex.value) {
      transition = Transition.rightToLeft; // Moving right in the UI
    } else {
      transition = Transition.leftToRight; // Moving left in the UI
    }
    
    // Update index
    selectedIndex.value = index;
    
    // Navigate to the selected page with proper transition
    String targetRoute = routes[index];
    if (Get.currentRoute != targetRoute) {
      Get.toNamed(
        targetRoute,
        preventDuplicates: true,
      );
    }
  }
}