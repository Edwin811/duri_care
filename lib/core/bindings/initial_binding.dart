import 'package:duri_care/core/services/home_service.dart';
import 'package:duri_care/core/services/profile_service.dart';
import 'package:duri_care/core/services/session_service.dart';
import 'package:duri_care/core/services/user_service.dart';
import 'package:duri_care/core/services/zone_service.dart';
import 'package:duri_care/core/utils/helpers/navigation/navigation_helper.dart';
import 'package:duri_care/features/auth/auth_controller.dart';
import 'package:duri_care/features/error/network_controller.dart';
import 'package:get/get.dart';

/// Initializes all required services and controllers when the app starts
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Register Services
    Get.put(SessionService(), permanent: true);
    Get.put(ProfileService(), permanent: true);
    Get.put(ZoneService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(HomeService(), permanent: true);

    // Register Controllers
    Get.put(AuthController(), permanent: true);
    Get.put(NavigationHelper(), permanent: true);
    Get.put(NetworkController(), permanent: true);
  }
}
