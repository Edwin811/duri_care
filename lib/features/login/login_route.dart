import 'package:duri_care/features/login/login_binding.dart';
import 'package:duri_care/features/login/login_view.dart';
import 'package:get/get.dart';

final loginRoute = [
  GetPage(
    name: LoginScreen.route,
    page: () => LoginScreen(),
    binding: LoginBinding(),
  ),
];
