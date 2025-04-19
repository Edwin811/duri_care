import 'package:duri_care/core/utils/helpers/tabs.dart';
import 'package:duri_care/features/profile/profile_controller.dart';
import 'package:duri_care/features/zone/zone_controller.dart';
import 'package:get/get.dart';

final List<GetPage<dynamic>> tabsRoute = [
  GetPage(
    name: '/tabs',
    page: () => Tabs(),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => TabsController(), fenix: true);
      Get.lazyPut(() => ZoneController(), fenix: true);
      Get.lazyPut(() => ProfileController(), fenix: true);
    }),
  ),
];
