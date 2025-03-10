import 'package:duri_care/core/di/controllers_binding.dart';
import 'package:duri_care/features/login/login_view.dart';
import 'package:duri_care/features/onboarding/onboarding_view.dart';
import 'package:duri_care/features/splashscreen/splashscreen_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DuriCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: ControllersBinding(),
      initialRoute: SplashscreenView.route,
      getPages: [
        GetPage(
          name: SplashscreenView.route,
          page: () => const SplashscreenView(),
        ),
        GetPage(name: OnboardingView.route, page: () => const OnboardingView()),
        GetPage(name: LoginScreen.route, page: () => const LoginScreen()),
      ],
    );
  }
}
