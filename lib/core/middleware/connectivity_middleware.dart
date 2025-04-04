import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:duri_care/features/error/error_404_view.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ConnectivityMiddleware extends GetMiddleware {
  final Connectivity _connectivity = Connectivity();

  @override
  RouteSettings? redirect(String? route) {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        Get.offAll(() => const Error404View());
      } else {
        Get.offAllNamed(route!);
      }
    });
    return null;
  }
}