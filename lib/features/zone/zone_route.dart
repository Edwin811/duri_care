import 'package:duri_care/features/zone/add_zone_view.dart';
import 'package:duri_care/features/zone/zone_binding.dart';
import 'package:duri_care/features/zone/zone_view.dart';
import 'package:get/get.dart';

String zoneName = 'Zona 1 Tes';
final zoneRoute = [
  GetPage(
    name: ZoneView.route,
    page: () => ZoneView(zoneName: zoneName),
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
