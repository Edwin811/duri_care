import 'profile_binding.dart';
import 'profile_view.dart';
import 'package:get/get.dart';

final profileRoute = [
  GetPage(
    name: ProfileView.route,
    page: () => ProfileView(),
    binding: ProfileBinding(),
  ),
];