import 'package:duri_care/features/management_user/user_management_binding.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/features/management_user/user_management_view.dart';
import 'package:duri_care/features/management_user/permission_management_view.dart';
import 'package:get/get.dart';

final userManagementRoute = [
  GetPage(
    name: UserManagementView.route,
    page: () => const UserManagementView(),
    binding: UserManagementBinding(),
  ),
  GetPage(
    name: PermissionManagementView.route,
    page: () => const PermissionManagementView(),
    binding: BindingsBuilder(() {
      if (!Get.isRegistered<UserManagementController>()) {
        Get.put(UserManagementController());
      }
    }),
  ),
];
