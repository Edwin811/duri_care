import 'package:duri_care/features/error/error_route.dart';
import 'package:duri_care/features/home/home_route.dart';
import 'package:duri_care/features/home/home_view.dart';
import 'package:duri_care/features/login/login_route.dart';
import 'package:duri_care/features/onboarding/onboarding_route.dart';
import 'package:duri_care/features/splashscreen/splashscreen_route.dart';
import 'package:duri_care/features/zone/zone_route.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static String initial = HomeView.route;

  static final List<GetPage<dynamic>> routes = [
    ...splashscreenRoute,
    ...onBoardingRoute,
    ...loginRoute,
    ...homeRoute,
    ...zoneRoute,
    ...errorRoute,
  ];
}