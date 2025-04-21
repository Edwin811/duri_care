import 'package:duri_care/core/utils/helpers/navigation/navigation_helper.dart';
import 'package:duri_care/features/home/home_controller.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';

final List<GetPage<dynamic>> mainRoute = [
  GetPage(
    name: MainNavigationView.route,
    page: () => MainNavigationView(),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => HomeController(), fenix: true);
      Get.lazyPut(() => ZoneController(), fenix: true);
      Get.lazyPut(() => ProfileController(), fenix: true);
    }),
  ),
];
