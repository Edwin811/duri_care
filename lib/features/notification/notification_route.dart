import 'package:duri_care/features/notification/notification_binding.dart';
import 'package:duri_care/features/notification/notification_view.dart';
import 'package:get/get.dart';

final notificationRoute = [
  GetPage(
    name: NotificationView.route,
    page: () => const NotificationView(),
    binding: NotificationBinding(),
  ),
];
