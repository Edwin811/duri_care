import 'package:duri_care/features/notification/notification_controller.dart';
import 'package:get/get.dart';

class NotificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NotificationController(), permanent: true);
  }
}