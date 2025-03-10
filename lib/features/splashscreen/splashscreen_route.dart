import 'package:duri_care/features/splashscreen/splashscreen_binding.dart';
import 'package:duri_care/features/splashscreen/splashscreen_view.dart';
import 'package:get/get.dart';

final splashscreenRoute = [
  GetPage(
    name: SplashscreenView.route,
    page: () => SplashscreenView(),
    binding: SplashscreenBinding(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 500),
  ),
];