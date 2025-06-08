import 'package:duri_care/core/services/notification_service.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/auth/auth_state.dart' as auth_state;
import 'package:duri_care/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationService notificationService = NotificationService.to;

  final RxBool isLoading = true.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AuthController>().authState, _handleAuthStateChange);
    _handleAuthStateChange(Get.find<AuthController>().authState.value);
  }

  void _handleAuthStateChange(auth_state.AuthState? state) {
    if (state == auth_state.AuthState.authenticated) {
      loadNotifications();
    } else {
      notifications.clear();
      unreadCount.value = 0;
    }
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final userId = notificationService.supabase.auth.currentUser?.id;
      if (userId != null) {
        notifications.value = await notificationService.getUserNotifications(
          userId,
        );
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
      unreadCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationService.markNotificationAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !notifications[index].isRead) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = unreadCount.value > 0 ? unreadCount.value - 1 : 0;
        notifications.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final userId = notificationService.supabase.auth.currentUser?.id;
    try {
      if (userId != null) {
        DialogHelper.showConfirmationDialog(
          title: 'Tandai Semua Dibaca',
          message:
              'Apakah anda yakin menandai semua notifikasi sebagai dibaca?',
          onConfirm: () async {
            await notificationService.markAllNotificationsAsRead(userId);
            for (int i = 0; i < notifications.length; i++) {
              if (!notifications[i].isRead) {
                notifications[i] = notifications[i].copyWith(isRead: true);
              }
            }
            unreadCount.value = 0;
            notifications.refresh();
            Get.back();
            DialogHelper.showSuccessDialog(
              message: 'Semua notifikasi telah ditandai sebagai dibaca.',
            );
          },
          onCancel: () {
            Get.back();
          },
        );
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        message: 'Gagal menandai semua notifikasi sebagai dibaca: $e',
      );
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final notification = notifications.firstWhereOrNull(
        (n) => n.id == notificationId,
      );

      DialogHelper.showConfirmationDialog(
        title: 'Hapus Notifikasi',
        message: 'Apakah anda yakin ingin menghapus notifikasi ini?',
        onConfirm: () async {
          await notificationService.deleteNotification(notificationId);
          notifications.removeWhere((n) => n.id == notificationId);
          if (notification != null && !notification.isRead) {
            unreadCount.value =
                unreadCount.value > 0 ? unreadCount.value - 1 : 0;
          }
          Get.back();
          DialogHelper.showSuccessDialog(
            message: 'Notifikasi berhasil dihapus.',
          );
        },
        onCancel: () {
          Get.back();
        },
      );
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Gagal menghapus notifikasi: $e');
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
