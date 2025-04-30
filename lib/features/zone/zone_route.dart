import 'package:duri_care/features/zone/add_zone_view.dart';
import 'package:duri_care/features/zone/edit_zone_view.dart';
import 'package:duri_care/features/zone/zone_binding.dart';
import 'package:duri_care/features/zone/zone_view.dart';
import 'package:get/get.dart';

final zoneRoute = [
  GetPage(
    name: ZoneView.route,
    page: () => const ZoneView(),
    binding: ZoneBinding(),
  ),
];
final addNewZone = [
  GetPage(
    name: AddZoneView.route,
    page: () => const AddZoneView(),
    binding: ZoneBinding(),
  ),
];
final editZone = [
  GetPage(
    name: EditZoneView.route,
    page: () => const EditZoneView(),
    binding: ZoneBinding(),
  ),
];
