import 'package:duri_care/core/utils/helpers/navigation/navigation_route.dart';
import 'package:duri_care/features/error/error_route.dart';
import 'package:duri_care/features/history/history_route.dart';
import 'package:duri_care/features/home/home_route.dart';
import 'package:duri_care/features/login/login_route.dart';
import 'package:duri_care/features/management_user/user_management_route.dart';
import 'package:duri_care/features/notification/notification_route.dart';
import 'package:duri_care/features/onboarding/onboarding_route.dart';
import 'package:duri_care/features/profile/profile_route.dart';
import 'package:duri_care/features/splashscreen/splashscreen_route.dart';
import 'package:duri_care/features/splashscreen/splashscreen_view.dart';
import 'package:duri_care/features/zone/zone_route.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static String initial = SplashscreenView.route;

  static final List<GetPage<dynamic>> routes = [
    ...mainRoute,
    ...splashscreenRoute,
    ...onBoardingRoute,
    ...loginRoute,
    ...homeRoute,
    ...zoneRoute,
    ...errorRoute,
    ...addNewZone,
    ...profileRoute,
    ...editProfileRoute,
    ...editZone,
    ...notificationRoute,
    ...historyRoute,
    ...userManagementRoute,
  ];
}
