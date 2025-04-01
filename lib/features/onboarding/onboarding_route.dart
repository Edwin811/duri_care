import 'onboarding_binding.dart';
import 'onboarding_view.dart';
import 'package:get/get.dart';

final onBoardingRoute = [
  GetPage(
    name: OnboardingView.route,
    page: () => const OnboardingView(),
    binding: OnboardingBinding(),
  ),
];
