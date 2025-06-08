import 'package:duri_care/features/notification/notification_controller.dart';
import 'package:get/get.dart';

class NotificationBinding implements Bindings {
  @override
  void dependencies() {
    // NotificationController is now registered globally in InitialBinding
    // Just ensure it's available (no-op if already registered)
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
  }
}
