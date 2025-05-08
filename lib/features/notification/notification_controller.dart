import 'package:duri_care/core/services/notification_service.dart';
import 'package:duri_care/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Changed to public access so the view can access it
  final NotificationService notificationService = NotificationService.to;

  final RxBool isLoading = true.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      // Assuming we have access to the current user ID
      final userId = notificationService.supabase.auth.currentUser?.id;
      if (userId != null) {
        notifications.value = await notificationService.getUserNotifications(
          userId,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationService.markNotificationAsRead(notificationId);

      // Update local notification list
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification = notifications[index].copyWith(isRead: true);
        notifications[index] = updatedNotification;
        notifications.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read: $e');
    }
  }

  // Helper methods
  Future<void> markAllAsRead() async {
    final userId = notificationService.supabase.auth.currentUser?.id;
    if (userId != null) {
      await notificationService.markAllNotificationsAsRead(userId);
      await loadNotifications();
    }
  }

  String getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'irrigation':
        return 'assets/icons/irrigation.png';
      case 'weather':
        return 'assets/icons/weather.png';
      case 'schedule':
        return 'assets/icons/schedule.png';
      default:
        return 'assets/icons/notification.png';
    }
  }
}
