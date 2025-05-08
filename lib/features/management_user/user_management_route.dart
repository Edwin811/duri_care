import 'package:duri_care/features/management_user/user_management_binding.dart';
import 'package:duri_care/features/management_user/user_management_view.dart';
import 'package:get/get.dart';

final userManagementRoute = [
  GetPage(
    name: UserManagementView.route,
    page: () => const UserManagementView(),
    binding: UserManagementBinding(),
  ),
];
