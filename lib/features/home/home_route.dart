import 'home_binding.dart';
import 'home_view.dart';
import 'package:get/get.dart';

final homeRoute = [
  GetPage(
  name: HomeView.route,
  page: () => HomeView(),
  binding: HomeBinding(),
  ),
];
