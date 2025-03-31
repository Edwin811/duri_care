import 'package:get/get.dart';

class HomeController extends GetxController {
  // Example property to hold a counter value
  var counter = 0.obs;

  // Method to increment the counter
  void incrementCounter() {
    counter++;
  }

  // Method to reset the counter
  void resetCounter() {
    counter.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    // Perform any initialization logic here
    print("HomeController initialized");
  }

  @override
  void onClose() {
    // Cleanup logic here
    print("HomeController disposed");
    super.onClose();
  }
}