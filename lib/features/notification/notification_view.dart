import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/themes/app_themes.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/core/utils/widgets/back_button.dart';
import 'package:duri_care/features/notification/notification_controller.dart';
import 'package:duri_care/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});
  static const String route = '/notification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.greenPrimary,
        leading: AppBackButton(iconColor: AppColor.white),
        title: Text(
          'Notifikasi',
          style: AppThemes.textTheme(context, ColorScheme.dark()).titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppColor.white),
            tooltip: 'Tandai semua sebagai dibaca',
            onPressed: () {
              // _showMarkAllAsReadConfirmation(context);
              DialogHelper.showConfirmationDialog(
                title: 'Tandai Semua Dibaca',
                message:
                    'Apakah anda yakin menandai semua notifikasi sebagai dibaca?',
                onConfirm: () {
                  final userId =
                      controller
                          .notificationService
                          .supabase
                          .auth
                          .currentUser
                          ?.id;
                  if (userId != null) {
                    controller.markAllAsRead();
                    controller.loadNotifications();
                  } else {
                    DialogHelper.showErrorDialog(
                      message: 'Gagal menandai semua notifikasi sebagai dibaca',
                    );
                  }
                },
                onCancel: () {
                  Get.back();
                },
              );
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : _buildNotificationList(context),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context) {
    if (controller.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return _buildNotificationCard(context, notification, controller);
        },
      ),
    );
  }
}

Widget _buildNotificationCard(
  BuildContext context,
  NotificationModel notification,
  NotificationController controller,
) {
  final isRead = notification.isRead;
  final createdAt = DateTime.parse(notification.createdAt);
  final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

  // Determine the icon based on the notification content
  IconData notificationIcon = Icons.notifications;
  Color iconColor = AppColor.greenPrimary;
  final messageLower = notification.message.toLowerCase();
  if (messageLower.contains('irigasi')) {
    notificationIcon = Icons.water_drop;
    iconColor = Colors.blue;
  } else if (messageLower.contains('hujan') || messageLower.contains('cuaca')) {
    notificationIcon = Icons.cloud;
    iconColor = Colors.grey;
  } else if (messageLower.contains('jadwal')) {
    notificationIcon = Icons.schedule;
    iconColor = Colors.purple;
  }

  return Card(
    elevation: 0,
    color: isRead ? Colors.white : AppColor.greenPrimary.withAlpha(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color:
            isRead
                ? Colors.grey.withAlpha(40)
                : AppColor.greenPrimary.withAlpha(125),
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (!notification.isRead) {
          controller.markAsRead(notification.id);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withAlpha(50),
              child: Icon(notificationIcon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRead)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColor.greenPrimary,
                    ),
                    onPressed: () => controller.markAsRead(notification.id),
                    tooltip: 'Mark as read',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 8),
                  ),
                IconButton(
                  onPressed:
                      () => controller.showDeleteConfirmation(notification.id),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete notification',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 4),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}