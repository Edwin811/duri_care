import 'package:duri_care/core/services/notification_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
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
      final userId = notificationService.supabase.auth.currentUser?.id;
      notifications.value = await notificationService.getUserNotifications(
        userId!,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationService.markNotificationAsRead(notificationId);

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

  Future<void> markAllAsRead() async {
    final userId = notificationService.supabase.auth.currentUser?.id;
    if (userId != null) {
      await notificationService.markAllNotificationsAsRead(userId);
      await loadNotifications();
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await notificationService.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Gagal menghapus notifikasi: $e');
    }
  }

  void showDeleteConfirmation(int notificationId) {
    DialogHelper.showConfirmationDialog(
      title: 'Hapus Notifikasi?',
      message: 'Apakah anda yakin ingin menghapus notifikasi ini?',
      onConfirm: () async {
        await deleteNotification(notificationId);
        Get.back(); // Close the dialog
      },
      onCancel: () {
        Get.back(); // Close the dialog without deleting
      },
    );
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
