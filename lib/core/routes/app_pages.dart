import 'package:duri_care/features/onboarding/onboarding_view.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static String initial = OnboardingView.route;

  static final List<GetPage<dynamic>> routes = [
    ...AppPages.routes,
  ];
}