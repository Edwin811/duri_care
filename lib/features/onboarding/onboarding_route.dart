import 'onboarding_binding.dart';
import 'onboarding_view.dart';
import 'package:get/get.dart';

final onboardingRoute = [
  GetPage(
    name: OnboardingView.route,
    page: () => OnboardingView(),
    binding: OnboardingBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
];
