import 'package:duri_care/features/error/error_404_view.dart';
import 'package:duri_care/features/error/error_binding.dart';
import 'package:get/get.dart';

final errorRoute = [
  GetPage(
    name: Error404View.route,
    page: () => const Error404View(),
    binding: ErrorBinding(),
  ),
];
