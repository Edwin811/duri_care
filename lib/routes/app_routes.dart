import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/zone/zone_view.dart';
import 'package:duri_care/features/zone/add_zone_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: HomeView.route, page: () => const HomeView()),
    GetPage(name: ZoneView.route, page: () => const ZoneView()),
    GetPage(name: AddZoneView.route, page: () => const AddZoneView()),
  ];
}
