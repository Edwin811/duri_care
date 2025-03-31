import 'onboarding_binding.dart';
import 'onboarding_view.dart';
import 'package:get/get.dart';

// class OnboardingRoute {
//   static final onBoardingPage = GetPage(
//     name: OnboardingView.route,
//     page: () => const OnboardingView(),
//     binding: OnboardingBinding(),
//   );
// }
final onBoardingRoute = [
  GetPage(
    name: OnboardingView.route,
    page: () => const OnboardingView(),
    binding: OnboardingBinding(),
  ),
];
